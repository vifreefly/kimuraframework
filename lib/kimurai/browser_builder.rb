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
      end
    end
  end
end
