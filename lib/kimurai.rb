require 'ostruct'
require 'logger'
require 'json'
require 'active_support'
require 'active_support/core_ext'
require 'rbcat'

require_relative 'kimurai/version'

require_relative 'kimurai/core_ext/numeric'
require_relative 'kimurai/core_ext/string'
require_relative 'kimurai/core_ext/array'
require_relative 'kimurai/core_ext/hash'

require_relative 'kimurai/browser_builder'
require_relative 'kimurai/base_helper'
require_relative 'kimurai/pipeline'
require_relative 'kimurai/base'

module Kimurai
  class << self
    def configuration
      @configuration ||= OpenStruct.new
    end

    def configure
      yield(configuration)
    end

    def env
      ENV.fetch("KIMURAI_ENV") { "development" }
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
