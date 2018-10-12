require 'mechanize'
require_relative '../driver/base'

class Capybara::Mechanize::Driver
  # Extend capybara-mechnize to support Poltergeist-like methods
  # https://www.rubydoc.info/gems/poltergeist/Capybara/Poltergeist/Driver

  def set_proxy(ip, port, type, user = nil, password = nil)
    # type is always "http", "socks" is not supported (yet)
    browser.agent.set_proxy(ip, port, user, password)
  end

  ###

  def headers
    browser.agent.request_headers
  end

  def headers=(headers)
    browser.agent.request_headers = headers
  end

  def add_header(name, value)
    browser.agent.request_headers[name] = value
  end

  ###

  def get_cookies
    browser.agent.cookies
  end

  def set_cookie(name, value, options = {})
    options[:name]  ||= name
    options[:value] ||= value

    cookie = Mechanize::Cookie.new(options.merge path: "/")
    browser.agent.cookie_jar << cookie
  end

  def set_cookies(cookies)
    cookies.each do |cookie|
      set_cookie(cookie[:name], cookie[:value], cookie)
    end
  end

  def clear_cookies
    browser.agent.cookie_jar.clear!
  end

  ###

  def quit
    browser.agent.shutdown
  end

  ###

  # Reset parent method `current_memory` for mechanize (we can't measure memory of Mechanize driver)
  def current_memory
    nil
  end

  def pid
    nil
  end

  def port
    nil
  end
end
