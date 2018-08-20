require 'capybara'
require 'nokogiri'
require 'murmurhash3'
require_relative 'session/config'

module Capybara
  class Session
    attr_accessor :spider

    def logger
      spider.logger
    end
  end
end
