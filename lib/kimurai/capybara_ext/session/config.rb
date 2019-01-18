module Capybara
  class SessionConfig
    attr_accessor :cookies, :proxy, :user_agent, :encoding
    attr_writer :retry_request_errors, :skip_request_errors

    def retry_request_errors
      @retry_request_errors ||= []
    end

    def skip_request_errors
      @skip_request_errors ||= []
    end

    def restart_if
      @restart_if ||= {}
    end

    def before_request
      @before_request ||= {}
    end
  end
end
