### Settings ###
require 'tzinfo'

# Export current PATH to the cron
env :PATH, ENV["PATH"]

# Use 24 hour format when using `at:` option
set :chronic_options, hours24: true

# Use local_to_utc helper to setup execution time using your local timezone instead
# of server's timezone (which is probably and should be UTC, to check run `$ timedatectl`).
# Also maybe you'll want to set same timezone in kimurai as well (use `Kimurai.configuration.time_zone =` for that),
# to have spiders logs in a specific time zone format.
# Example usage of helper:
# every 1.day, at: local_to_utc("7:00", zone: "Europe/Moscow") do
#   crawl "google_spider.com", output: "log/google_spider.com.log"
# end
def local_to_utc(time_string, zone:)
  TZInfo::Timezone.get(zone).local_to_utc(Time.parse(time_string))
end

# Note: by default Whenever exports cron commands with :environment == "production".
# Note: Whenever can only append log data to a log file (>>). If you want
# to overwrite (>) log file before each run, pass lambda:
# crawl "google_spider.com", output: -> { "> log/google_spider.com.log 2>&1" }

# Project job types
job_type :crawl,  "cd :path && KIMURAI_ENV=:environment bundle exec kimurai crawl :task :output"
job_type :runner, "cd :path && KIMURAI_ENV=:environment bundle exec kimurai runner --jobs :task :output"

# Single file job type
job_type :single, "cd :path && KIMURAI_ENV=:environment ruby :task :output"
# Single with bundle exec
job_type :single_bundle, "cd :path && KIMURAI_ENV=:environment bundle exec ruby :task :output"

### Schedule ###
# Usage (check examples here https://github.com/javan/whenever#example-schedulerb-file):
# every 1.day do
  # Example to schedule a single spider in the project:
  # crawl "google_spider.com", output: "log/google_spider.com.log"

  # Example to schedule all spiders in the project using runner. Each spider will write
  # it's own output to the `log/spider_name.log` file (handled by a runner itself).
  # Runner output will be written to log/runner.log file.
  # Argument number it's a count of concurrent jobs:
  # runner 3, output:"log/runner.log"

  # Example to schedule single spider (without project):
  # single "single_spider.rb", output: "single_spider.log"
# end

### How to set a cron schedule ###
# Run: `$ whenever --update-crontab --load-file config/schedule.rb`.
# If you don't have whenever command, install the gem: `$ gem install whenever`.

### How to cancel a schedule ###
# Run: `$ whenever --clear-crontab --load-file config/schedule.rb`.
