require 'capybara'
require 'selenium-webdriver'
require_relative '../capybara_configuration'
require_relative '../capybara_ext/selenium/driver'
require_relative '../capybara_ext/session'

module Kimurai::BrowserBuilder
  class SeleniumChromeBuilder
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
      Capybara.register_driver :selenium_chrome do |app|
        # Create driver options
        opts = { args: %w[--disable-gpu --no-sandbox --disable-translate] }

        # Provide custom chrome browser path:
        if chrome_path = Kimurai.configuration.selenium_chrome_path
          opts.merge!(binary: chrome_path)
        end

        # See all options here: https://seleniumhq.github.io/selenium/docs/api/rb/Selenium/WebDriver/Chrome/Options.html
        driver_options = Selenium::WebDriver::Chrome::Options.new(opts)

        # Window size
        if size = @config[:window_size].presence
          driver_options.args << "--window-size=#{size.join(',')}"
          logger.debug "BrowserBuilder (selenium_chrome): enabled window_size"
        end

        # Proxy
        if proxy = @config[:proxy].presence
          proxy_string = (proxy.class == Proc ? proxy.call : proxy).strip
          ip, port, type, user, password = proxy_string.split(":")

          if %w(http socks5).include?(type)
            if user.nil? && password.nil?
              driver_options.args << "--proxy-server=#{type}://#{ip}:#{port}"
              logger.debug "BrowserBuilder (selenium_chrome): enabled #{type} proxy, ip: #{ip}, port: #{port}"
            else
              logger.error "BrowserBuilder (selenium_chrome): proxy with authentication doesn't supported by selenium, skipped"
            end
          else
            logger.error "BrowserBuilder (selenium_chrome): wrong type of proxy: #{type}, skipped"
          end
        end

        if proxy_bypass_list = @config[:proxy_bypass_list].presence
          if proxy
            driver_options.args << "--proxy-bypass-list=#{proxy_bypass_list.join(';')}"
            logger.debug "BrowserBuilder (selenium_chrome): enabled proxy_bypass_list"
          else
            logger.error "BrowserBuilder (selenium_chrome): provide `proxy` to set proxy_bypass_list, skipped"
          end
        end

        # SSL
        if @config[:ignore_ssl_errors].present?
          driver_options.args << "--ignore-certificate-errors"
          driver_options.args << "--allow-insecure-localhost"
          logger.debug "BrowserBuilder (selenium_chrome): enabled ignore_ssl_errors"
        end

        # Disable images
        if @config[:disable_images].present?
          driver_options.prefs["profile.managed_default_content_settings.images"] = 2
          logger.debug "BrowserBuilder (selenium_chrome): enabled disable_images"
        end

        # Headers
        if @config[:headers].present?
          logger.warn "BrowserBuilder: (selenium_chrome): custom headers doesn't supported by selenium, skipped"
        end

        if user_agent = @config[:user_agent].presence
          user_agent_string = (user_agent.class == Proc ? user_agent.call : user_agent).strip
          driver_options.args << "--user-agent='#{user_agent_string}'"
          logger.debug "BrowserBuilder (selenium_chrome): enabled custom user_agent"
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

              logger.debug "BrowserBuilder (selenium_chrome): enabled virtual_display headless_mode"
            else
              logger.error "BrowserBuilder (selenium_chrome): virtual_display headless_mode works only " \
                "on Linux platform. Browser will run in normal mode. Set `native` mode instead."
            end
          else
            driver_options.args << "--headless"
            logger.debug "BrowserBuilder (selenium_chrome): enabled native headless_mode"
          end
        end

        chromedriver_path = Kimurai.configuration.chromedriver_path || "/usr/local/bin/chromedriver"
        Capybara::Selenium::Driver.new(app, browser: :chrome, options: driver_options, driver_path: chromedriver_path)
      end

      # Create browser instance (Capybara session)
      @browser = Capybara::Session.new(:selenium_chrome)
      @browser.spider = spider
      logger.debug "BrowserBuilder (selenium_chrome): created browser instance"

      if @config[:extensions].present?
        logger.error "BrowserBuilder (selenium_chrome): `extensions` option not supported by Selenium, skipped"
      end

      # Cookies
      if cookies = @config[:cookies].presence
        @browser.config.cookies = cookies
        logger.debug "BrowserBuilder (selenium_chrome): enabled custom cookies"
      end

      # Browser instance options
      # skip_request_errors
      if skip_errors = @config[:skip_request_errors].presence
        @browser.config.skip_request_errors = skip_errors
        logger.debug "BrowserBuilder (selenium_chrome): enabled skip_request_errors"
      end

      # retry_request_errors
      if retry_errors = @config[:retry_request_errors].presence
        @browser.config.retry_request_errors = retry_errors
        logger.debug "BrowserBuilder (selenium_chrome): enabled retry_request_errors"
      end

      # restart_if
      if requests_limit = @config.dig(:restart_if, :requests_limit).presence
        @browser.config.restart_if[:requests_limit] = requests_limit
        logger.debug "BrowserBuilder (selenium_chrome): enabled restart_if.requests_limit >= #{requests_limit}"
      end

      if memory_limit = @config.dig(:restart_if, :memory_limit).presence
        @browser.config.restart_if[:memory_limit] = memory_limit
        logger.debug "BrowserBuilder (selenium_chrome): enabled restart_if.memory_limit >= #{memory_limit}"
      end

      # before_request clear_cookies
      if @config.dig(:before_request, :clear_cookies)
        @browser.config.before_request[:clear_cookies] = true
        logger.debug "BrowserBuilder (selenium_chrome): enabled before_request.clear_cookies"
      end

      # before_request clear_and_set_cookies
      if @config.dig(:before_request, :clear_and_set_cookies)
        if cookies = @config[:cookies].presence
          @browser.config.cookies = cookies
          @browser.config.before_request[:clear_and_set_cookies] = true
          logger.debug "BrowserBuilder (selenium_chrome): enabled before_request.clear_and_set_cookies"
        else
          logger.error "BrowserBuilder (selenium_chrome): cookies should be present to enable before_request.clear_and_set_cookies, skipped"
        end
      end

      # before_request change_user_agent
      if @config.dig(:before_request, :change_user_agent)
        logger.error "BrowserBuilder (selenium_chrome): before_request.change_user_agent option not supported by Selenium, skipped"
      end

      # before_request change_proxy
      if @config.dig(:before_request, :change_proxy)
        logger.error "BrowserBuilder (selenium_chrome): before_request.change_proxy option not supported by Selenium, skipped"
      end

      # before_request delay
      if delay = @config.dig(:before_request, :delay).presence
        @browser.config.before_request[:delay] = delay
        logger.debug "BrowserBuilder (selenium_chrome): enabled before_request.delay"
      end

      # encoding
      if encoding = @config[:encoding]
        @browser.config.encoding = encoding
        logger.debug "BrowserBuilder (selenium_chrome): enabled encoding: #{encoding}"
      end

      # return Capybara session instance
      @browser
    end
  end
end
