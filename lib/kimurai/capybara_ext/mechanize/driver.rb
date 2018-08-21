require 'mechanize'
require_relative '../driver/base'

# Extend capybara-mechnize to support Poltergeist-like methods
# https://www.rubydoc.info/gems/poltergeist/Capybara/Poltergeist/Driver
class Capybara::Mechanize::Driver
  def set_proxy(ip, port, type, user, password)
    # type is always "http", "socks" is not supported (yet)
    browser.agent.set_proxy(ip, port, user, password)
  end

  def headers
    browser.agent.request_headers
  end

  def headers=(headers)
    browser.agent.request_headers = headers
  end

  def add_header(name, value)
    browser.agent.request_headers[name] = value
  end

  def set_cookie(name, value, options = {})
    options[:name]  ||= name
    options[:value] ||= value

    cookie = Mechanize::Cookie.new(options.merge path: "/")
    browser.agent.cookie_jar << cookie
  end

  def clear_cookies
    browser.agent.cookie_jar.clear!
  end

  def quit
    browser.agent.shutdown
  end

  ###

  # Reset parent method `current_memory` for mechanize (we can't measure memory of mechanize engine)
  def current_memory
    nil
  end
end
