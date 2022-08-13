module Tanakai
  module BrowserBuilder
    def self.build(engine, config = {}, spider:)
      if config[:browser].present?
        raise "++++++ BrowserBuilder: browser option is depricated. Now all sub-options inside " \
          "`browser` should be placed right into `@config` hash, without `browser` parent key.\n" \
          "See more here: https://github.com/vifreefly/kimuraframework/blob/master/CHANGELOG.md#breaking-changes-110 ++++++"
      end

      begin
        require "tanakai/browser_builder/#{engine}_builder"
      rescue LoadError => e
      end

      builder_class_name = "#{engine}_builder".classify
      builder = "Tanakai::BrowserBuilder::#{builder_class_name}".constantize
      builder.new(config, spider: spider).build
    end
  end
end
