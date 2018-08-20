require 'capybara'

Capybara.configure do |config|
  config.run_server = false
  config.default_selector = :xpath
  config.save_path = "tmp"
  config.default_max_wait_time = 10
  config.ignore_hidden_elements = false
  config.threadsafe = true
end
