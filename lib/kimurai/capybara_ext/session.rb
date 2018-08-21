require 'capybara'
require 'nokogiri'
require_relative 'session/config'

module Capybara
  class Session
    attr_accessor :spider

    def current_response
      Nokogiri::HTML(body)
    end

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
        rescue *config.retry_request_errors => e
          logger.error "Browser: request visit error: #{e.inspect}, url: #{visit_uri}"

          if (retries += 1) < max_retries
            logger.info "Browser: sleep #{(sleep_interval += 15)} seconds and process retry № #{retries} to the url: #{visit_uri}"
            sleep sleep_interval and retry
          else
            logger.error "Browser: all retries (#{retries}) to the url `#{visit_uri}` are gone"
            raise e
          end
        else
          driver.responses += 1 and logger.info "Browser: finished get request to: #{visit_uri}"
          spider.class.update(:visits, :responses) if spider.with_info
          driver.visited = true unless driver.visited
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
        @driver.quit
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

    private

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
      spider&.logger
    end
  end
end
