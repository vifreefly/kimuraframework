require 'capybara'
require 'capybara/apparition'
require_relative '../capybara_configuration'
require_relative '../capybara_ext/apparition/driver'
require_relative '../capybara_ext/session'

module Kimurai::BrowserBuilder
  class ApparitionChromeBuilder
    attr_reader :logger, :spider

    def initialize(config, spider:)
      @config = config
      @spider = spider
      @logger = spider.logger
    end

    def build
      # Register driver
      Capybara.register_driver :apparition_chrome do |app|
        # Create driver options
        driver_options = { js_errors: false, debug: false, inspector: false }

        if extensions = @config[:extensions].presence
          driver_options[:extensions] = extensions
          logger.debug "BrowserBuilder (apparition_chrome): enabled extensions"
        end

        # Window size
        if size = @config[:window_size].presence
          driver_options[:window_size] = size
          logger.debug "BrowserBuilder (apparition_chrome): enabled window_size"
        end

        # SSL
        if ssl_cert_path = @config[:ssl_cert_path].presence
          # driver_options[:phantomjs_options] << "--ssl-certificates-path=#{ssl_cert_path}"
          # logger.debug "BrowserBuilder (apparition_chrome): enabled custom ssl_cert"
          logger.error "BrowserBuilder (apparition_chrome): enabled custom ssl_cert --- NOT IMPLEMENTED!"
        end

        if @config[:ignore_ssl_errors].present?
          driver_options[:ignore_https_errors] = true
          logger.debug "BrowserBuilder (apparition_chrome): enabled ignore_ssl_errors"
        end

        # Disable images
        if @config[:disable_images].present?
          driver_options[:skip_image_loading] = true
          logger.debug "BrowserBuilder (apparition_chrome): enabled disable_images"
        end

        if ENV["HEADLESS"] == "false"
          driver_options[:headless] = false
          logger.debug "BrowserBuilder (apparition_chrome): enabled visual mode (not headless)"
        else
          logger.debug "BrowserBuilder (apparition_chrome): enabled default headless mode (native)"
        end

        # Headless mode
        # if ENV["HEADLESS"] != "false"
        #   if @config[:headless_mode] == :virtual_display
        #     if Gem::Platform.local.os == "linux"
        #       unless self.class.virtual_display
        #         require 'headless'
        #         self.class.virtual_display = Headless.new(reuse: true, destroy_at_exit: false)
        #         self.class.virtual_display.start
        #       end

        #       logger.debug "BrowserBuilder (apparition_chrome): enabled virtual_display headless_mode"
        #     else
        #       logger.error "BrowserBuilder (apparition_chrome): virtual_display headless_mode works only " \
        #         "on Linux platform. Browser will run in normal mode. Set `native` mode instead."
        #     end
        #   else
        #     # driver_options[:headless] = true
        #     logger.debug "BrowserBuilder (apparition_chrome): enabled headless_mode (default)"
        #   end
        # end

        Capybara::Apparition::Driver.new(app, driver_options)
      end


      # Create browser instance (Capybara session)
      @browser = Capybara::Session.new(:apparition_chrome)
      @browser.spider = spider
      logger.debug "BrowserBuilder (apparition_chrome): created browser instance"

      # Proxy (Not TESTED)
      if proxy = @config[:proxy].presence
        proxy_string = (proxy.class == Proc ? proxy.call : proxy).strip
        ip, port, type = proxy_string.split(":")

        if %w(http socks5).include?(type)
          @browser.driver.set_proxy(*proxy_string.split(":"))
          logger.debug "BrowserBuilder (apparition_chrome): enabled #{type} proxy, ip: #{ip}, port: #{port}"
        else
          logger.error "BrowserBuilder (apparition_chrome): wrong type of proxy: #{type}, skipped"
        end
      end

      # Headers (NOT TESTED)
      if headers = @config[:headers].presence
        @browser.driver.headers = headers
        logger.debug "BrowserBuilder (apparition_chrome): enabled custom headers"
      end

      if user_agent = @config[:user_agent].presence
        user_agent_string = (user_agent.class == Proc ? user_agent.call : user_agent).strip

        @browser.driver.add_header("User-Agent", user_agent_string)
        logger.debug "BrowserBuilder (apparition_chrome): enabled custom user_agent"
      end

      # Cookies (NOT TESTED)
      if cookies = @config[:cookies].presence
        cookies.each do |cookie|
          @browser.driver.set_cookie(cookie[:name], cookie[:value], cookie)
        end

        logger.debug "BrowserBuilder (apparition_chrome): enabled custom cookies"
      end

      # Browser instance options
      # skip_request_errors
      if skip_errors = @config[:skip_request_errors].presence
        @browser.config.skip_request_errors = skip_errors
        logger.debug "BrowserBuilder (apparition_chrome): enabled skip_request_errors"
      end

      # retry_request_errors
      if retry_errors = @config[:retry_request_errors].presence
        @browser.config.retry_request_errors = retry_errors
        logger.debug "BrowserBuilder (apparition_chrome): enabled retry_request_errors"
      end

      # restart_if
      if requests_limit = @config.dig(:restart_if, :requests_limit).presence
        @browser.config.restart_if[:requests_limit] = requests_limit
        logger.debug "BrowserBuilder (apparition_chrome): enabled restart_if.requests_limit >= #{requests_limit}"
      end

      if memory_limit = @config.dig(:restart_if, :memory_limit).presence
        @browser.config.restart_if[:memory_limit] = memory_limit
        logger.debug "BrowserBuilder (apparition_chrome): enabled restart_if.memory_limit >= #{memory_limit}"
      end

      # before_request clear_cookies
      if @config.dig(:before_request, :clear_cookies)
        @browser.config.before_request[:clear_cookies] = true
        logger.debug "BrowserBuilder (apparition_chrome): enabled before_request.clear_cookies"
      end

      # before_request clear_and_set_cookies
      if @config.dig(:before_request, :clear_and_set_cookies)
        if cookies = @config[:cookies].presence
          @browser.config.cookies = cookies
          @browser.config.before_request[:clear_and_set_cookies] = true
          logger.debug "BrowserBuilder (apparition_chrome): enabled before_request.clear_and_set_cookies"
        else
          logger.error "BrowserBuilder (apparition_chrome): cookies should be present to enable before_request.clear_and_set_cookies, skipped"
        end
      end

      # before_request change_user_agent
      if @config.dig(:before_request, :change_user_agent)
        if @config[:user_agent].present? && @config[:user_agent].class == Proc
          @browser.config.user_agent = @config[:user_agent]
          @browser.config.before_request[:change_user_agent] = true
          logger.debug "BrowserBuilder (apparition_chrome): enabled before_request.change_user_agent"
        else
          logger.error "BrowserBuilder (apparition_chrome): user_agent should be present and has lambda format to enable before_request.change_user_agent, skipped"
        end
      end

      # before_request change_proxy
      if @config.dig(:before_request, :change_proxy)
        if @config[:proxy].present? && @config[:proxy].class == Proc
          @browser.config.proxy = @config[:proxy]
          @browser.config.before_request[:change_proxy] = true
          logger.debug "BrowserBuilder (apparition_chrome): enabled before_request.change_proxy"
        else
          logger.error "BrowserBuilder (apparition_chrome): proxy should be present and has lambda format to enable before_request.change_proxy, skipped"
        end
      end

      # before_request delay
      if delay = @config.dig(:before_request, :delay).presence
        @browser.config.before_request[:delay] = delay
        logger.debug "BrowserBuilder (apparition_chrome): enabled before_request.delay"
      end

      # encoding
      if encoding = @config[:encoding]
        @browser.config.encoding = encoding
        logger.debug "BrowserBuilder (apparition_chrome): enabled encoding: #{encoding}"
      end

      # return Capybara session instance
      @browser
    end
  end
end
