require_relative '../driver/base'

module Capybara::Apparition
  class Driver
    def pid
      # client_pid
      nil # not implemented
    end

    def port
      # server.port
      nil # not implemented
    end
  end
end
