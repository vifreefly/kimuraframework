require 'ostruct'
require 'logger'
require 'json'
require 'active_support'
require 'active_support/core_ext'
require 'rbcat'

require_relative 'tanakai/version'

require_relative 'tanakai/core_ext/numeric'
require_relative 'tanakai/core_ext/string'
require_relative 'tanakai/core_ext/array'
require_relative 'tanakai/core_ext/hash'

require_relative 'tanakai/browser_builder'
require_relative 'tanakai/base_helper'
require_relative 'tanakai/pipeline'
require_relative 'tanakai/base'

module Tanakai
  class << self
    def configuration
      @configuration ||= OpenStruct.new
    end

    def configure
      yield(configuration)
    end

    def env
      ENV.fetch("TANAKAI_ENV") { "development" }
    end

    def time_zone
      ENV["TZ"]
    end

    def time_zone=(value)
      ENV.store("TZ", value)
    end

    def list
      Base.descendants.map do |klass|
        next unless klass.name
        [klass.name, klass]
      end.compact.to_h
    end

    def find_by_name(name)
      return unless name
      Base.descendants.find { |klass| klass.name == name }
    end
  end
end
