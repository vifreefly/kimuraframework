require 'capybara'
require 'selenium-webdriver'
require_relative '../capybara_configuration'
require_relative '../capybara_ext/selenium/driver'
require_relative '../capybara_ext/session'

module Kimurai::BrowserBuilder
  class SeleniumFirefoxBuilder
    class << self
      attr_accessor :virtual_display
    end

    attr_reader :logger, :spider

    def initialize(config, spider:)
      @config = config
      @spider = spider
      @logger = spider.logger
    end

    def build
      # Register driver
      Capybara.register_driver :selenium_firefox do |app|
        # Create driver options
        driver_options = Selenium::WebDriver::Firefox::Options.new
        driver_options.profile = Selenium::WebDriver::Firefox::Profile.new
        driver_options.profile["browser.link.open_newwindow"] = 3 # open windows in tabs
        driver_options.profile["media.peerconnection.enabled"] = false # disable web rtc

        # Proxy
        if proxy = @config[:proxy].presence
          proxy_string = (proxy.class == Proc ? proxy.call : proxy).strip
          ip, port, type, user, password = proxy_string.split(":")

          if user.nil? && password.nil?
            driver_options.profile["network.proxy.type"] = 1
            if type == "http"
              driver_options.profile["network.proxy.http"] = ip
              driver_options.profile["network.proxy.http_port"] = port.to_i
              driver_options.profile["network.proxy.ssl"] = ip
              driver_options.profile["network.proxy.ssl_port"] = port.to_i

              logger.debug "BrowserBuilder (selenium_firefox): enabled http proxy, ip: #{ip}, port: #{port}"
            elsif type == "socks5"
              driver_options.profile["network.proxy.socks"] = ip
              driver_options.profile["network.proxy.socks_port"] = port.to_i
              driver_options.profile["network.proxy.socks_version"] = 5
              driver_options.profile["network.proxy.socks_remote_dns"] = true

              logger.debug "BrowserBuilder (selenium_firefox): enabled socks5 proxy, ip: #{ip}, port: #{port}"
            else
              logger.error "BrowserBuilder (selenium_firefox): wrong type of proxy: #{type}, skipped"
            end
          else
            logger.error "BrowserBuilder (selenium_firefox): proxy with authentication doesn't supported by selenium, skipped"
          end
        end

        if proxy_bypass_list = @config[:proxy_bypass_list].presence
          if proxy
            driver_options.profile["network.proxy.no_proxies_on"] = proxy_bypass_list.join(", ")
            logger.debug "BrowserBuilder (selenium_firefox): enabled proxy_bypass_list"
          else
            logger.error "BrowserBuilder (selenium_firefox): provide `proxy` to set proxy_bypass_list, skipped"
          end
        end

        # SSL
        if @config[:ignore_ssl_errors].present?
          driver_options.profile.secure_ssl = false
          driver_options.profile.assume_untrusted_certificate_issuer = true
          logger.debug "BrowserBuilder (selenium_firefox): enabled ignore_ssl_errors"
        end

        # Disable images
        if @config[:disable_images].present?
          driver_options.profile["permissions.default.image"] = 2
          logger.debug "BrowserBuilder (selenium_firefox): enabled disable_images"
        end

        # Headers
        if @config[:headers].present?
          logger.warn "BrowserBuilder: (selenium_firefox): custom headers doesn't supported by selenium, skipped"
        end

        if user_agent = @config[:user_agent].presence
          user_agent_string = (user_agent.class == Proc ? user_agent.call : user_agent).strip
          driver_options.profile["general.useragent.override"] = user_agent_string
          logger.debug "BrowserBuilder (selenium_firefox): enabled custom user_agent"
        end

        # Headless mode
        if ENV["HEADLESS"] != "false"
          if @config[:headless_mode] == :virtual_display
            if Gem::Platform.local.os == "linux"
              unless self.class.virtual_display
                require 'headless'
                self.class.virtual_display = Headless.new(reuse: true, destroy_at_exit: false)
                self.class.virtual_display.start
              end

              logger.debug "BrowserBuilder (selenium_firefox): enabled virtual_display headless_mode"
            else
              logger.error "BrowserBuilder (selenium_firefox): virtual_display headless_mode works only " \
                "on Linux platform. Browser will run in normal mode. Set `native` mode instead."
            end
          else
            driver_options.args << "--headless"
            logger.debug "BrowserBuilder (selenium_firefox): enabled native headless_mode"
          end
        end

        Capybara::Selenium::Driver.new(app, browser: :firefox, options: driver_options)
      end

      # Create browser instance (Capybara session)
      @browser = Capybara::Session.new(:selenium_firefox)
      @browser.spider = spider
      logger.debug "BrowserBuilder (selenium_firefox): created browser instance"

      if @config[:extensions].present?
        logger.error "BrowserBuilder (selenium_firefox): `extensions` option not supported by Selenium, skipped"
      end

      # Window size
      if size = @config[:window_size].presence
        @browser.current_window.resize_to(*size)
        logger.debug "BrowserBuilder (selenium_firefox): enabled window_size"
      end

      # Cookies
      if cookies = @config[:cookies].presence
        @browser.config.cookies = cookies
        logger.debug "BrowserBuilder (selenium_firefox): enabled custom cookies"
      end

      # Browser instance options
      # skip_request_errors
      if skip_errors = @config[:skip_request_errors].presence
        @browser.config.skip_request_errors = skip_errors
        logger.debug "BrowserBuilder (selenium_firefox): enabled skip_request_errors"
      end

      # retry_request_errors
      if retry_errors = @config[:retry_request_errors].presence
        @browser.config.retry_request_errors = retry_errors
        logger.debug "BrowserBuilder (selenium_firefox): enabled retry_request_errors"
      end

      # restart_if
      if requests_limit = @config.dig(:restart_if, :requests_limit).presence
        @browser.config.restart_if[:requests_limit] = requests_limit
        logger.debug "BrowserBuilder (selenium_firefox): enabled restart_if.requests_limit >= #{requests_limit}"
      end

      if memory_limit = @config.dig(:restart_if, :memory_limit).presence
        @browser.config.restart_if[:memory_limit] = memory_limit
        logger.debug "BrowserBuilder (selenium_firefox): enabled restart_if.memory_limit >= #{memory_limit}"
      end

      # before_request clear_cookies
      if @config.dig(:before_request, :clear_cookies)
        @browser.config.before_request[:clear_cookies] = true
        logger.debug "BrowserBuilder (selenium_firefox): enabled before_request.clear_cookies"
      end

      # before_request clear_and_set_cookies
      if @config.dig(:before_request, :clear_and_set_cookies)
        if cookies = @config[:cookies].presence
          @browser.config.cookies = cookies
          @browser.config.before_request[:clear_and_set_cookies] = true
          logger.debug "BrowserBuilder (selenium_firefox): enabled before_request.clear_and_set_cookies"
        else
          logger.error "BrowserBuilder (selenium_firefox): cookies should be present to enable before_request.clear_and_set_cookies, skipped"
        end
      end

      # before_request change_user_agent
      if @config.dig(:before_request, :change_user_agent)
        logger.error "BrowserBuilder (selenium_firefox): before_request.change_user_agent option not supported by Selenium, skipped"
      end

      # before_request change_proxy
      if @config.dig(:before_request, :change_proxy)
        logger.error "BrowserBuilder (selenium_firefox): before_request.change_proxy option not supported by Selenium, skipped"
      end

      # before_request delay
      if delay = @config.dig(:before_request, :delay).presence
        @browser.config.before_request[:delay] = delay
        logger.debug "BrowserBuilder (selenium_firefox): enabled before_request.delay"
      end

      # encoding
      if encoding = @config[:encoding]
        @browser.config.encoding = encoding
        logger.debug "BrowserBuilder (selenium_firefox): enabled encoding: #{encoding}"
      end

      # return Capybara session instance
      @browser
    end
  end
end
