module Kimurai
  class Pipeline
    class DropItemError < StandardError; end
    def self.name
      self.to_s.sub(/.*?::/, "").underscore.to_sym
    end

    include BaseHelper
    attr_accessor :spider

    def name
      self.class.name
    end

    ###

    def storage
      spider.storage
    end

    def unique?(scope, value)
      spider.unique?(scope, value)
    end

    def save_to(path, item, format:, position: true, append: false)
      spider.save_to(path, item, format: format, position: position, append: append)
    end

    def logger
      spider.logger
    end
  end
end
