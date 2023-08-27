require 'capybara/cuprite'
require_relative '../capybara_configuration'
require_relative '../capybara_ext/session'
require_relative '../capybara_ext/cuprite/driver'

module Kimurai::BrowserBuilder
  class CupriteBuilder
    attr_reader :logger, :spider

    def initialize(config, spider:)
      @config = config
      @spider = spider
      @logger = spider.logger
    end

    def build
      # Register driver
      Capybara.register_driver :cuprite do |app|
        driver_options = { headless: ENV.fetch("HEADLESS", "true") == "true" }
        logger.debug "BrowserBuilder (cuprite): enabled extensions"

        Capybara::Cuprite::Driver.new(app, driver_options)
      end

      # Create browser instance (Capybara session)
      @browser = Capybara::Session.new(:cuprite)
      @browser.spider = spider
      logger.debug "BrowserBuilder (cuprite): created browser instance"

      # Headers
      if headers = @config[:headers].presence
        @browser.driver.headers = headers
        logger.debug "BrowserBuilder (cuprite): enabled custom headers"
      end

      if user_agent = @config[:user_agent].presence
        user_agent_string = (user_agent.class == Proc ? user_agent.call : user_agent).strip
        @browser.driver.headers = {"User-Agent" => user_agent_string}
        logger.debug "BrowserBuilder (cuprite): enabled custom user_agent"
      end

      # Cookies
      if cookies = @config[:cookies].presence
        cookies.each do |cookie|
          @browser.driver.set_cookie(cookie[:name], cookie[:value], cookie)
        end

        logger.debug "BrowserBuilder (cuprite): enabled custom cookies"
      end

      @browser
    end
  end
end
