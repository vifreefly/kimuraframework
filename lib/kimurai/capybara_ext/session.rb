require 'capybara'
require 'nokogiri'
require 'json'
require_relative 'session/config'

module Capybara
  class Session
    attr_accessor :spider

    alias_method :original_visit, :visit
    def visit(visit_uri, delay: config.before_request[:delay], skip_request_options: false, max_retries: 3)
      if spider
        process_delay(delay) if delay
        retries, sleep_interval = 0, 0

        begin
          check_request_options(visit_uri) unless skip_request_options
          driver.requests += 1 and logger.info "Browser: started get request to: #{visit_uri}"
          spider.class.update(:visits, :requests) if spider.with_info

          original_visit(visit_uri)
        rescue => e
          if match_error?(e, type: :to_skip)
            logger.error "Browser: skip request error: #{e.inspect}, url: #{visit_uri}"
            spider.add_event(:requests_errors, e.inspect) if spider.with_info
            false
          elsif match_error?(e, type: :to_retry)
            logger.error "Browser: retry request error: #{e.inspect}, url: #{visit_uri}"
            spider.add_event(:requests_errors, e.inspect) if spider.with_info

            if (retries += 1) <= max_retries
              logger.info "Browser: sleep #{(sleep_interval += 15)} seconds and process retry № #{retries} to the url: #{visit_uri}"
              sleep sleep_interval and retry
            else
              logger.error "Browser: all retries (#{retries - 1}) to the url #{visit_uri} are gone"
              raise e unless skip_error_on_failure?(e)
            end
          else
            raise e
          end
        else
          driver.responses += 1 and logger.info "Browser: finished get request to: #{visit_uri}"
          spider.class.update(:visits, :responses) if spider.with_info
          driver.visited = true unless driver.visited
          true
        ensure
          if spider.with_info
            logger.info "Info: visits: requests: #{spider.class.visits[:requests]}, responses: #{spider.class.visits[:responses]}"
          end

          if memory = driver.current_memory
            logger.debug "Browser: driver.current_memory: #{memory}"
          end
        end
      else
        original_visit(visit_uri)
      end
    end

    def destroy_driver!
      if @driver
        begin
          @driver.quit
        # handle Net::ReadTimeout error for Selenium like drivers
        rescue Net::ReadTimeout => e
          @driver.quit
        end

        @driver = nil
        logger.info "Browser: driver #{mode} has been destroyed"
      else
        logger.warn "Browser: driver #{mode} is not present"
      end
    end

    def restart!
      if mode.match?(/poltergeist/)
        @driver.browser.restart
        @driver.requests, @driver.responses = 0, 0
      else
        destroy_driver!
        driver
      end

      logger.info "Browser: driver has been restarted: name: #{mode}, pid: #{driver.pid}, port: #{driver.port}"
    end

    def current_response(response_type = :html)
      case response_type
      when :html
        if config.encoding
          if config.encoding == :auto
            charset = body.force_encoding("ISO-8859-1").encode("UTF-8")[/<meta.*?charset=["]?([\w+\d+\-]*)/i, 1]
            Nokogiri::HTML(body, nil, charset)
          else
            Nokogiri::HTML(body, nil, config.encoding)
          end
        else
          Nokogiri::HTML(body)
        end
      when :json
        JSON.parse(body)
      end
    end

    ###

    # Handy method to perform some processing in the new tab within block and then automatically close this tab:
    # Usage (url):
    # browser.within_new_window_by(url: "https://google.com") do
      # do some stuff and then automatically close this tab and return back to the first tab
    # end
    # Usage (action) (when new tab opening by some action, for example by clicking
    # on a particular element):
    # action = -> { browser.find("//some/element/path").click }
    # browser.within_new_window_by(action: action) do
      # do some stuff and then automatically close this tab and return back to the first tab
    # end
    def within_new_window_by(action: nil, url: nil)
      case
      when action
        opened_window = window_opened_by { action.call }
        within_window(opened_window) do
          yield
          current_window.close
        end
      when url
        within_window(open_new_window) do
          visit(url)

          yield
          current_window.close
        end
      end
    end

    ###

    def scroll_to_bottom
      execute_script("window.scrollBy(0,10000)")
    end

    private

    def skip_error_on_failure?(e)
      config.retry_request_errors.any? do |error|
        error[:skip_on_failure] && e.class.ancestors.include?(error[:error]) if error.kind_of?(Hash)
      end
    end

    def match_error?(e, type:)
      errors =
        case type
        when :to_retry then config.retry_request_errors
        when :to_skip then config.skip_request_errors
        end

      errors.any? do |error|
        if error.kind_of?(Hash)
          match_class = e.class.ancestors.include?(error[:error])
          if error[:message].present?
            if error[:message].kind_of?(Regexp)
              e.message&.match?(error[:message])
            else
              e.message&.include?(error[:message])
            end && match_class
          else
            match_class
          end
        else
          e.class.ancestors.include?(error)
        end
      end
    end

    def process_delay(delay)
      interval = (delay.class == Range ? rand(delay) : delay)
      logger.debug "Browser: sleep #{interval.round(2)} #{'second'.pluralize(interval)} before request..."
      sleep interval
    end

    def check_request_options(url_to_visit)
      # restart_if
      if memory_limit = config.restart_if[:memory_limit]
        memory = driver.current_memory
        if memory && memory >= memory_limit
          logger.warn "Browser: memory_limit #{memory_limit} of driver.current_memory (#{memory}) is exceeded (engine: #{mode})"
          restart!
        end
      end

      if requests_limit = config.restart_if[:requests_limit]
        requests = driver.requests
        if requests >= requests_limit
          logger.warn "Browser: requests_limit #{requests_limit} of driver.requests (#{requests}) is exceeded (engine: #{mode})"
          restart!
        end
      end

      # cookies
      # (Selenium only) if config.cookies present and browser was just created,
      # visit url_to_visit first and only then set cookies:
      if driver.visited.nil? && config.cookies && mode.match?(/selenium/)
        visit(url_to_visit, skip_request_options: true)
        config.cookies.each do |cookie|
          driver.set_cookie(cookie[:name], cookie[:value], cookie)
        end
      end

      if config.before_request[:clear_cookies]
        driver.clear_cookies
        logger.debug "Browser: cleared cookies before request"
      end

      if config.before_request[:clear_and_set_cookies]
        driver.clear_cookies

        # (Selenium only) if browser is not visited yet any page, visit url_to_visit
        # first and then set cookies (needs after browser restart):
        if driver.visited.nil? && mode.match?(/selenium/)
          visit(url_to_visit, skip_request_options: true)
        end

        config.cookies.each do |cookie|
          driver.set_cookie(cookie[:name], cookie[:value], cookie)
        end

        logger.debug "Browser: cleared and set cookies before request"
      end

      # user_agent
      if config.before_request[:change_user_agent]
        driver.add_header("User-Agent", config.user_agent.call)
        logger.debug "Browser: changed user_agent before request"
      end

      # proxy
      if config.before_request[:change_proxy]
        proxy_string = config.proxy.call
        driver.set_proxy(*proxy_string.split(":"))
        logger.debug "Browser: changed proxy before request"
      end
    end

    def logger
      spider.logger
    end
  end
end
