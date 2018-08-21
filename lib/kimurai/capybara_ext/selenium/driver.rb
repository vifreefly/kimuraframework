require_relative '../driver/base'

class Capybara::Selenium::Driver
  def set_cookie(name, value, options = {})
    options[:name]  ||= name
    options[:value] ||= value

    browser.manage.add_cookie(options)
  end

  def clear_cookies
    browser.manage.delete_all_cookies
  end

  ###

  def pid
    @pid ||= `lsof -i tcp:#{port} -t`.strip.to_i
  end

  def port
    @port ||= browser.send(:bridge).instance_variable_get("@http").instance_variable_get("@server_url").port
  end
end
