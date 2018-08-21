require 'ostruct'
require_relative 'kimurai/version'

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

# require_relative 'kimurai/default_configuration'
