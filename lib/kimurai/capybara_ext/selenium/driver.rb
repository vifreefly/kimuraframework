require_relative '../driver/base'

class Capybara::Selenium::Driver
  def get_cookies
    browser.manage.all_cookies
  end

  def set_cookie(name, value, options = {})
    options[:name]  ||= name
    options[:value] ||= value

    browser.manage.add_cookie(options)
  end

  def set_cookies(cookies)
    cookies.each do |cookie|
      set_cookie(cookie[:name], cookie[:value], cookie)
    end
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
