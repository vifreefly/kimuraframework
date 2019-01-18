require 'capybara'
require 'capybara/poltergeist'
require_relative '../capybara_configuration'
require_relative '../capybara_ext/poltergeist/driver'
require_relative '../capybara_ext/session'

module Kimurai::BrowserBuilder
  class PoltergeistPhantomjsBuilder
    attr_reader :logger, :spider

    def initialize(config, spider:)
      @config = config
      @spider = spider
      @logger = spider.logger
    end

    def build
      # Register driver
      Capybara.register_driver :poltergeist_phantomjs do |app|
        # Create driver options
        driver_options = {
          js_errors: false, debug: false, inspector: false, phantomjs_options: []
        }

        if extensions = @config[:extensions].presence
          driver_options[:extensions] = extensions
          logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled extensions"
        end

        # Window size
        if size = @config[:window_size].presence
          driver_options[:window_size] = size
          logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled window_size"
        end

        # SSL
        if ssl_cert_path = @config[:ssl_cert_path].presence
          driver_options[:phantomjs_options] << "--ssl-certificates-path=#{ssl_cert_path}"
          logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled custom ssl_cert"
        end

        if @config[:ignore_ssl_errors].present?
          driver_options[:phantomjs_options].push("--ignore-ssl-errors=yes", "--ssl-protocol=any")
          logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled ignore_ssl_errors"
        end

        # Disable images
        if @config[:disable_images].present?
          driver_options[:phantomjs_options] << "--load-images=no"
          logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled disable_images"
        end

        Capybara::Poltergeist::Driver.new(app, driver_options)
      end

      # Create browser instance (Capybara session)
      @browser = Capybara::Session.new(:poltergeist_phantomjs)
      @browser.spider = spider
      logger.debug "BrowserBuilder (poltergeist_phantomjs): created browser instance"

      # Proxy
      if proxy = @config[:proxy].presence
        proxy_string = (proxy.class == Proc ? proxy.call : proxy).strip
        ip, port, type = proxy_string.split(":")

        if %w(http socks5).include?(type)
          @browser.driver.set_proxy(*proxy_string.split(":"))
          logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled #{type} proxy, ip: #{ip}, port: #{port}"
        else
          logger.error "BrowserBuilder (poltergeist_phantomjs): wrong type of proxy: #{type}, skipped"
        end
      end

      # Headers
      if headers = @config[:headers].presence
        @browser.driver.headers = headers
        logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled custom headers"
      end

      if user_agent = @config[:user_agent].presence
        user_agent_string = (user_agent.class == Proc ? user_agent.call : user_agent).strip

        @browser.driver.add_header("User-Agent", user_agent_string)
        logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled custom user_agent"
      end

      # Cookies
      if cookies = @config[:cookies].presence
        cookies.each do |cookie|
          @browser.driver.set_cookie(cookie[:name], cookie[:value], cookie)
        end

        logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled custom cookies"
      end

      # Browser instance options
      # skip_request_errors
      if skip_errors = @config[:skip_request_errors].presence
        @browser.config.skip_request_errors = skip_errors
        logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled skip_request_errors"
      end

      # retry_request_errors
      if retry_errors = @config[:retry_request_errors].presence
        @browser.config.retry_request_errors = retry_errors
        logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled retry_request_errors"
      end

      # restart_if
      if requests_limit = @config.dig(:restart_if, :requests_limit).presence
        @browser.config.restart_if[:requests_limit] = requests_limit
        logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled restart_if.requests_limit >= #{requests_limit}"
      end

      if memory_limit = @config.dig(:restart_if, :memory_limit).presence
        @browser.config.restart_if[:memory_limit] = memory_limit
        logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled restart_if.memory_limit >= #{memory_limit}"
      end

      # before_request clear_cookies
      if @config.dig(:before_request, :clear_cookies)
        @browser.config.before_request[:clear_cookies] = true
        logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled before_request.clear_cookies"
      end

      # before_request clear_and_set_cookies
      if @config.dig(:before_request, :clear_and_set_cookies)
        if cookies = @config[:cookies].presence
          @browser.config.cookies = cookies
          @browser.config.before_request[:clear_and_set_cookies] = true
          logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled before_request.clear_and_set_cookies"
        else
          logger.error "BrowserBuilder (poltergeist_phantomjs): cookies should be present to enable before_request.clear_and_set_cookies, skipped"
        end
      end

      # before_request change_user_agent
      if @config.dig(:before_request, :change_user_agent)
        if @config[:user_agent].present? && @config[:user_agent].class == Proc
          @browser.config.user_agent = @config[:user_agent]
          @browser.config.before_request[:change_user_agent] = true
          logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled before_request.change_user_agent"
        else
          logger.error "BrowserBuilder (poltergeist_phantomjs): user_agent should be present and has lambda format to enable before_request.change_user_agent, skipped"
        end
      end

      # before_request change_proxy
      if @config.dig(:before_request, :change_proxy)
        if @config[:proxy].present? && @config[:proxy].class == Proc
          @browser.config.proxy = @config[:proxy]
          @browser.config.before_request[:change_proxy] = true
          logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled before_request.change_proxy"
        else
          logger.error "BrowserBuilder (poltergeist_phantomjs): proxy should be present and has lambda format to enable before_request.change_proxy, skipped"
        end
      end

      # before_request delay
      if delay = @config.dig(:before_request, :delay).presence
        @browser.config.before_request[:delay] = delay
        logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled before_request.delay"
      end

      # encoding
      if encoding = @config[:encoding]
        @browser.config.encoding = encoding
        logger.debug "BrowserBuilder (poltergeist_phantomjs): enabled encoding: #{encoding}"
      end

      # return Capybara session instance
      @browser
    end
  end
end
