require_relative '../driver/base'

module Capybara::Poltergeist
  class Driver
    def pid
      client_pid
    end

    def port
      server.port
    end
  end
end
