module Kimurai
  class Pipeline
    class DropItemError < StandardError; end
    def self.name
      self.to_s.sub(/.*?::/, "").underscore.to_sym
    end

    attr_accessor :spider

    def name
      self.class.name
    end

    def unique?(scope, value)
      spider.unique?(scope, value)
    end

    def save_to(path, item, format:, position: true)
      spider.save_to(path, item, format: format, position: position)
    end
  end
end
