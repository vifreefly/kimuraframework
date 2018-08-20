require 'logger'
require 'rbcat'

module Kimurai
  class Base
    LoggerFormatter =
      proc do |severity, datetime, progname, msg|
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

    @run_info = {
      crawler_name: name,
      status: :running,
      environment: Kimurai.env,
      start_time: Time.new,
      stop_time: nil,
      running_time: nil,
      visits: {
        requests: 0,
        responses: 0,
        requests_errors: Hash.new(0)
      },
      items: {
        sent: 0,
        processed: 0,
        drop_errors: Hash.new(0)
      },
      error: nil
    }

    def self.running?
      run_info[:status] == :running
    end

    def self.completed?
      run_info[:status] == :completed
    end

    def self.failed?
      run_info[:status] == :failed
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
        STDOUT.sync = true

        log_level = (ENV["LOG_LEVEL"] || Kimurai.configuration.log_level || "DEBUG").upcase
        log_level = "Logger::#{log_level}".constantize
        Logger.new(STDOUT, formatter: LoggerFormatter,
                           level: log_level,
                           progname: ENV["CURRENT_CRAWLER"]) # fix it
      end
    end

    ######

    def initialize(engine: self.class.engine, config: {})
      @engine = engine
      @config = self.class.config.deep_merge(config)
      @pipelines = self.class.pipelines.map do |pipeline_name|
        klass = Pipeline.descendants.find { |kl| kl.name == pipeline_name }
        [pipeline_name, klass.new]
      end.to_h
    end

    def browser
      @browser ||= BrowserBuilder.new(@engine, config: @config).build
    end

    def request_to(handler, delay = nil, url:, data: {})
      request_data = { url: url, data: data }

      delay ? browser.visit(url, delay: delay) : browser.visit(url)
      public_send(handler, browser.current_response, request_data)
    end

    def console(response = nil, url: nil, data: {})
      binding.pry
    end

    def logger
      self.class.logger
    end
  end
end
