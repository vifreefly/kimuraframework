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
  end
end
