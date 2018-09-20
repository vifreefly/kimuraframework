Kimurai.configure do |config|
  # Default logger has colored mode in development.
  # If you would like to disable it, set `colorize_logger` to false.
  # config.colorize_logger = false

  # Logger level for default logger:
  # config.log_level = :info

  # Custom logger:
  # config.logger = Logger.new(STDOUT)

  # Custom time zone (for logs):
  # config.time_zone = "UTC"
  # config.time_zone = "Europe/Moscow"

  # At start callback for a runner. Accepts argument with info as hash with
  # keys: id, status, start_time, environment, concurrent_jobs, spiders list.
  # For example, you can use this callback to send notification when runner was started:
  # config.runner_at_start_callback = lambda do |info|
  #   json = JSON.pretty_generate(info)
  #   Sender.send_notification("Started session: #{json}")
  # end

  # At stop callback for a runner. Accepts argument with info as hash with
  # all `runner_at_start_callback` keys plus additional `stop_time` key. Also `status` contains
  # stop status of a runner (completed or failed).
  # You can use this callback to send notification when runner has been stopped:
  # config.runner_at_stop_callback = lambda do |info|
  #   json = JSON.pretty_generate(info)
  #   Sender.send_notification("Stopped session: #{json}")
  # end

  # Provide custom chrome binary path (default is any available chrome/chromium in the PATH):
  # config.selenium_chrome_path = "/usr/bin/chromium-browser"
  # Provide custom selenium chromedriver path (default is "/usr/local/bin/chromedriver"):
  # config.chromedriver_path = "/usr/local/bin/chromedriver"
end
