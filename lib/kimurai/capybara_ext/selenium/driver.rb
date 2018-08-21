class Capybara::Selenium::Driver
  def set_cookie(name, value, options = {})
    options[:name]  ||= name
    options[:value] ||= value

    browser.manage.add_cookie(options)
  end

  def clear_cookies
    browser.manage.delete_all_cookies
  end
end
