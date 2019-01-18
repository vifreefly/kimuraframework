require 'capybara'
require 'capybara/mechanize'
require_relative '../capybara_configuration'
require_relative '../capybara_ext/mechanize/driver'
require_relative '../capybara_ext/session'

module Kimurai::BrowserBuilder
  class MechanizeBuilder
    attr_reader :logger, :spider

    def initialize(config, spider:)
      @config = config
      @spider = spider
      @logger = spider.logger
    end

    def build
      # Register driver
      Capybara.register_driver :mechanize do |app|
        driver = Capybara::Mechanize::Driver.new("app")
        # keep the history as small as possible (by default it's unlimited)
        driver.configure { |a| a.history.max_size = 2 }
        driver
      end

      # Create browser instance (Capybara session)
      @browser = Capybara::Session.new(:mechanize)
      @browser.spider = spider
      logger.debug "BrowserBuilder (mechanize): created browser instance"

      if @config[:extensions].present?
        logger.error "BrowserBuilder (mechanize): `extensions` option not supported, skipped"
      end

      # Proxy
      if proxy = @config[:proxy].presence
        proxy_string = (proxy.class == Proc ? proxy.call : proxy).strip
        ip, port, type = proxy_string.split(":")

        if type == "http"
          @browser.driver.set_proxy(*proxy_string.split(":"))
          logger.debug "BrowserBuilder (mechanize): enabled http proxy, ip: #{ip}, port: #{port}"
        else
          logger.error "BrowserBuilder (mechanize): can't set #{type} proxy (not supported), skipped"
        end
      end

      # SSL
      if ssl_cert_path = @config[:ssl_cert_path].presence
        @browser.driver.browser.agent.http.ca_file = ssl_cert_path
        logger.debug "BrowserBuilder (mechanize): enabled custom ssl_cert"
      end

      if @config[:ignore_ssl_errors].present?
        @browser.driver.browser.agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
        logger.debug "BrowserBuilder (mechanize): enabled ignore_ssl_errors"
      end

      # Headers
      if headers = @config[:headers].presence
        @browser.driver.headers = headers
        logger.debug "BrowserBuilder (mechanize): enabled custom headers"
      end

      if user_agent = @config[:user_agent].presence
        user_agent_string = (user_agent.class == Proc ? user_agent.call : user_agent).strip

        @browser.driver.add_header("User-Agent", user_agent_string)
        logger.debug "BrowserBuilder (mechanize): enabled custom user_agent"
      end

      # Cookies
      if cookies = @config[:cookies].presence
        cookies.each do |cookie|
          @browser.driver.set_cookie(cookie[:name], cookie[:value], cookie)
        end

        logger.debug "BrowserBuilder (mechanize): enabled custom cookies"
      end

      # Browser instance options
      # skip_request_errors
      if skip_errors = @config[:skip_request_errors].presence
        @browser.config.skip_request_errors = skip_errors
        logger.debug "BrowserBuilder (mechanize): enabled skip_request_errors"
      end

      # retry_request_errors
      if retry_errors = @config[:retry_request_errors].presence
        @browser.config.retry_request_errors = retry_errors
        logger.debug "BrowserBuilder (mechanize): enabled retry_request_errors"
      end

      # restart_if
      if @config[:restart_if].present?
        logger.warn "BrowserBuilder (mechanize): restart_if options not supported by Mechanize, skipped"
      end

      # before_request clear_cookies
      if @config.dig(:before_request, :clear_cookies)
        @browser.config.before_request[:clear_cookies] = true
        logger.debug "BrowserBuilder (mechanize): enabled before_request.clear_cookies"
      end

      # before_request clear_and_set_cookies
      if @config.dig(:before_request, :clear_and_set_cookies)
        if cookies = @config[:cookies].presence
          @browser.config.cookies = cookies
          @browser.config.before_request[:clear_and_set_cookies] = true
          logger.debug "BrowserBuilder (mechanize): enabled before_request.clear_and_set_cookies"
        else
          logger.error "BrowserBuilder (mechanize): cookies should be present to enable before_request.clear_and_set_cookies, skipped"
        end
      end

      # before_request change_user_agent
      if @config.dig(:before_request, :change_user_agent)
        if @config[:user_agent].present? && @config[:user_agent].class == Proc
          @browser.config.user_agent = @config[:user_agent]
          @browser.config.before_request[:change_user_agent] = true
          logger.debug "BrowserBuilder (mechanize): enabled before_request.change_user_agent"
        else
          logger.error "BrowserBuilder (mechanize): user_agent should be present and has lambda format to enable before_request.change_user_agent, skipped"
        end
      end

      # before_request change_proxy
      if @config.dig(:before_request, :change_proxy)
        if @config[:proxy].present? && @config[:proxy].class == Proc
          @browser.config.proxy = @config[:proxy]
          @browser.config.before_request[:change_proxy] = true
          logger.debug "BrowserBuilder (mechanize): enabled before_request.change_proxy"
        else
          logger.error "BrowserBuilder (mechanize): proxy should be present and has lambda format to enable before_request.change_proxy, skipped"
        end
      end

      # before_request delay
      if delay = @config.dig(:before_request, :delay).presence
        @browser.config.before_request[:delay] = delay
        logger.debug "BrowserBuilder (mechanize): enabled before_request.delay"
      end

      # encoding
      if encoding = @config[:encoding]
        @browser.config.encoding = encoding
        logger.debug "BrowserBuilder (mechanize): enabled encoding: #{encoding}"
      end

      # return Capybara session instance
      @browser
    end
  end
end
