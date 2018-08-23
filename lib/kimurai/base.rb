require_relative 'base/simple_saver'
require_relative 'base/uniq_checker'

module Kimurai
  class Base
    LoggerFormatter = proc do |severity, datetime, progname, msg|
      current_thread_id = Thread.current.object_id
      thread_type = Thread.main == Thread.current ? "M" : "C"
      output = "%s, [%s#%d] [%s: %s] %5s -- %s: %s\n"
        .freeze % [severity[0..0], datetime, $$, thread_type, current_thread_id, severity, progname, msg]

      if Kimurai.configuration.colorize_logger != false && Kimurai.env == "development"
        Rbcat.colorize(output, predefined: [:jsonhash, :logger])
      else
        output
      end
    end

    include BaseHelper

    ###

    class << self
      attr_reader :run_info
    end

    def self.running?
      @run_info && @run_info[:status] == :running
    end

    def self.completed?
      @run_info && @run_info[:status] == :completed
    end

    def self.failed?
      @run_info && @run_info[:status] == :failed
    end

    def self.visits
      @run_info && @run_info[:visits]
    end

    def self.items
      @run_info && @run_info[:items]
    end

    def self.update(type, subtype)
      return unless @run_info

      (@update_mutex ||= Mutex.new).synchronize do
        @run_info[type][subtype] += 1
      end
    end

    ###

    @engine = :mechanize
    @pipelines = []
    @config = {}

    ###

    def self.name
      @name
    end

    def self.engine
      @engine ||= superclass.engine
    end

    def self.pipelines
      @pipelines ||= superclass.pipelines
    end

    def self.start_urls
      @start_urls
    end

    def self.config
      superclass.equal?(::Object) ? @config : superclass.config.deep_merge(@config || {})
    end

    ###

    def self.logger
      @logger ||= Kimurai.configuration.logger || begin
        log_level = (ENV["LOG_LEVEL"] || Kimurai.configuration.log_level || "DEBUG").upcase
        log_level = "Logger::#{log_level}".constantize
        Logger.new(STDOUT, formatter: LoggerFormatter, level: log_level, progname: name)
      end
    end

    ###

    def self.checker
      @checker ||= UniqChecker.new
    end

    def unique?(scope, value)
      self.class.checker.unique?(scope, value)
    end

    def self.saver
      @saver ||= SimpleSaver.new
    end

    def save_to(path, item, format:, position: true)
      self.class.saver.save(path, item, format: format, position: position)
    end

    ###

    def self.crawl!
      logger.error "Spider: already running: #{name}" and return false if running?
      @run_info = {
        spider_name: name, status: :running, environment: Kimurai.env,
        start_time: Time.new, stop_time: nil, running_time: nil,
        visits: { requests: 0, responses: 0 }, items: { sent: 0, processed: 0 }, error: nil
      }

      logger.info "Spider: started: #{name}"
      open_spider if self.respond_to? :open_spider

      spider = self.new
      spider.with_info = true
      if start_urls
        start_urls.each do |start_url|
          spider.request_to(:parse, url: start_url)
        end
      else
        spider.parse
      end
    rescue StandardError, SignalException => e
      @run_info.merge!(status: :failed, error: e.inspect)
      raise e
    else
      @run_info[:status] = :completed
      @run_info
    ensure
      if spider
        spider.browser.destroy_driver!

        stop_time  = Time.now
        total_time = (stop_time - @run_info[:start_time]).round(3)
        @run_info.merge!(stop_time: stop_time, running_time: total_time)

        close_spider if self.respond_to? :close_spider
        message = "Spider: stopped: #{@run_info.merge(running_time: @run_info[:running_time]&.duration)}"
        failed? ? @logger.fatal(message) : @logger.info(message)

        @run_info, @checker, @saver = nil
      end
    end

    def self.parse!(handler, engine = nil, url: nil, data: {})
      spider = engine ? self.new(engine) : self.new
      url.present? ? spider.request_to(handler, url: url, data: data) : spider.public_send(handler)
    ensure
      spider.browser.destroy_driver!
    end

    ###

    attr_reader :logger
    attr_accessor :with_info

    def initialize(engine = self.class.engine, config: {})
      @engine = engine
      @config = self.class.config.deep_merge(config)
      @pipelines = self.class.pipelines.map do |pipeline_name|
        klass = Pipeline.descendants.find { |kl| kl.name == pipeline_name }
        instance = klass.new
        instance.spider = self
        [pipeline_name, instance]
      end.to_h

      @logger = self.class.logger
    end

    def browser
      @browser ||= BrowserBuilder.build(@engine, @config, spider: self)
    end

    def request_to(handler, delay = nil, url:, data: {})
      request_data = { url: url, data: data }
      delay ? browser.visit(url, delay: delay) : browser.visit(url)
      public_send(handler, browser.current_response, request_data)
    end

    def console(response = nil, url: nil, data: {})
      binding.pry
    end

    private

    def send_item(item, options = {})
      logger.debug "Pipeline: starting processing item through #{@pipelines.size} #{'pipeline'.pluralize(@pipelines.size)}..."
      self.class.update(:items, :sent) if self.with_info

      @pipelines.each do |name, instance|
        item = options[name] ? instance.process_item(item, options: options[name]) : instance.process_item(item)
      end
    rescue => e
      logger.error "Pipeline: dropped: #{e.inspect}, item: #{item}"
      false
    else
      self.class.update(:items, :processed) if self.with_info
      logger.info "Pipeline: processed: #{JSON.generate(item)}"
      true
    ensure
      if self.with_info
        logger.info "Info: items: sent: #{self.class.items[:sent]}, processed: #{self.class.items[:processed]}"
      end
    end

    def in_parallel(handler, urls, threads:, data: {}, delay: nil, engine: @engine, config: {})
      parts = urls.in_sorted_groups(threads, false)
      urls_count = urls.size

      all = []
      start_time = Time.now
      logger.info "Spider: in_parallel: starting processing #{urls_count} urls within #{threads} threads"

      parts.each do |part|
        all << Thread.new(part) do |part|
          Thread.current.abort_on_exception = true

          spider = self.class.new(engine, config: config)
          spider.with_info = true if self.with_info

          part.each do |url_data|
            if url_data.class == Hash
              spider.request_to(handler, delay, url_data)
            else
              spider.request_to(handler, delay, url: url_data, data: data)
            end
          end
        ensure
          spider.browser.destroy_driver!
        end

        sleep 0.5
      end

      all.each(&:join)
      logger.info "Spider: in_parallel: stopped processing #{urls_count} urls within #{threads} threads, total time: #{(Time.now - start_time).duration}"
    end
  end
end
