module Kimurai
  class BrowserBuilder
    AVAILABLE_ENGINES = [
      :mechanize,
      :mechanize_standalone,
      :poltergeist_phantomjs,
      :selenium_firefox,
      :selenium_chrome
    ]

    def self.build(engine, config = {}, spider:)
      unless AVAILABLE_ENGINES.include? engine
        raise "BrowserBuilder: wrong name of engine, available engines: #{AVAILABLE_ENGINES.join(', ')}"
      end

      case engine
      when :mechanize
        require_relative 'browser_builder/mechanize_builder'
        MechanizeBuilder.new(config, spider: spider).build
      when :selenium_chrome
        require_relative 'browser_builder/selenium_chrome_builder'
        SeleniumChromeBuilder.new(config, spider: spider).build
      when :poltergeist_phantomjs
        require_relative 'browser_builder/poltergeist_phantomjs_builder'
        PoltergeistPhantomJSBuilder.new(config, spider: spider).build
      end
    end
  end
end
