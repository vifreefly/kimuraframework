require 'pmap'

module Kimurai
  class Runner
    attr_reader :jobs, :spiders, :session_info

    def initialize(spiders, parallel_jobs)
      @jobs = parallel_jobs
      @spiders = spiders
      @start_time = Time.now

      @session_info = {
        id: @start_time.to_i,
        status: :processing,
        start_time: @start_time,
        stop_time: nil,
        environment: Kimurai.env,
        concurrent_jobs: @jobs,
        spiders: @spiders
      }

      if time_zone = Kimurai.configuration.time_zone
        Kimurai.time_zone = time_zone
      end

      ENV.store("SESSION_ID", @start_time.to_i.to_s)
      ENV.store("RBCAT_COLORIZER", "false")
    end

    def run!(exception_on_fail: true)
      puts ">>> Runner: started: #{session_info}"
      if at_start_callback = Kimurai.configuration.runner_at_start_callback
        at_start_callback.call(session_info)
      end

      running = true
      spiders.peach_with_index(jobs) do |spider, i|
        next unless running

        puts "> Runner: started spider: #{spider}, index: #{i}"
        pid = spawn("bundle", "exec", "kimurai", "crawl", spider, [:out, :err] => "log/#{spider}.log")
        Process.wait pid

        puts "< Runner: stopped spider: #{spider}, index: #{i}"
      end
    rescue StandardError, SignalException, SystemExit => e
      running = false

      session_info.merge!(status: :failed, error: e.inspect, stop_time: Time.now)
      exception_on_fail ? raise(e) : [session_info, e]
    else
      session_info.merge!(status: :completed, stop_time: Time.now)
    ensure
      if at_stop_callback = Kimurai.configuration.runner_at_stop_callback
        at_stop_callback.call(session_info)
      end
      puts "<<< Runner: stopped: #{session_info}"
    end
  end
end
