module Kimurai
  module BrowserBuilder
    def self.build(engine, config = {}, spider:)
      begin
        require "kimurai/browser_builder/#{engine}_builder"
      rescue LoadError
      end

      builder_class_name = "#{engine}_builder".classify
      builder = "Kimurai::BrowserBuilder::#{builder_class_name}".constantize
      builder.new(config, spider: spider).build
    end
  end
end
