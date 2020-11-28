require 'capybara/apparition'
require_relative '../capybara_configuration'
require_relative '../capybara_ext/session'
require_relative '../capybara_ext/apparition/driver'

module Kimurai::BrowserBuilder
  class ApparitionBuilder
    attr_reader :logger, :spider

    def initialize(config, spider:)
      @config = config
      @spider = spider
      @logger = spider.logger
    end

    def build
      # Register driver
      Capybara.register_driver :apparition do |app|
        timeout = ENV.fetch('TIMEOUT', 30).to_i
        driver_options = { js_errors: false, timeout: timeout, debug: ENV['DEBUG'] }

        driver_options[:headless] = ENV.fetch("HEADLESS", "true") == "true"
        logger.debug "BrowserBuilder (apparition): enabled extensions"

        Capybara::Apparition::Driver.new(app, driver_options)
      end

      # Create browser instance (Capybara session)
      @browser = Capybara::Session.new(:apparition)
      @browser.spider = spider
      logger.debug "BrowserBuilder (apparition): created browser instance"

      # Headers
      if headers = @config[:headers].presence
        @browser.driver.headers = headers
        logger.debug "BrowserBuilder (apparition): enabled custom headers"
      end

      if user_agent = @config[:user_agent].presence
        user_agent_string = (user_agent.class == Proc ? user_agent.call : user_agent).strip

        @browser.driver.add_header("User-Agent", user_agent_string)
        logger.debug "BrowserBuilder (apparition): enabled custom user_agent"
      end

      # Cookies
      if cookies = @config[:cookies].presence
        cookies.each do |cookie|
          @browser.driver.set_cookie(cookie[:name], cookie[:value], cookie)
        end

        logger.debug "BrowserBuilder (apparition): enabled custom cookies"
      end

      @browser
    end
  end
end
