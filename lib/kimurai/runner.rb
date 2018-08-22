require 'pmap'

module Kimurai
  class Runner
    attr_reader :jobs, :spiders

    def initialize(parallel_jobs:)
      @jobs = parallel_jobs
      @spiders = Kimurai.list

      if time_zone = Kimurai.configuration.time_zone
        Kimurai.time_zone = time_zone
      end
    end

    def run!
      start_time = Time.now
      run_id = start_time.to_i
      running_pids = []

      ENV.store("RBCAT_COLORIZER", "false")

      run_info = {
        id: run_id,
        status: :processing,
        start_time: start_time,
        stop_time: nil,
        environment: Kimurai.env,
        concurrent_jobs: jobs,
        spiders: spiders.keys
      }

      at_exit do
        # Prevent queue to process new intems while executing at_exit body
        Thread.list.each { |t| t.kill if t != Thread.main }
        # Kill currently running spiders
        running_pids.each { |pid| Process.kill("INT", pid) }

        error = $!
        stop_time = Time.now

        if error.nil?
          run_info.merge!(status: :completed, stop_time: stop_time)
        else
          run_info.merge!(status: :failed, error: error.inspect, stop_time: stop_time)
        end

        if at_stop_callback = Kimurai.configuration.runner_at_stop_callback
          at_stop_callback.call(run_info)
        end
        puts "<<< Runner: stopped: #{run_info}"
      end

      puts ">>> Runner: started: #{run_info}"
      if at_start_callback = Kimurai.configuration.runner_at_start_callback
        at_start_callback.call(run_info)
      end

      spiders.peach_with_index(jobs) do |spider, i|
        spider_name = spider[0]
        puts "> Runner: started spider: #{spider_name}, index: #{i}"

        pid = spawn("bundle", "exec", "kimurai", "crawl", spider_name, [:out, :err] => "log/#{spider_name}.log")
        running_pids << pid
        Process.wait pid

        running_pids.delete(pid)
        puts "< Runner: stopped spider: #{spider_name}, index: #{i}"
      end
    end
  end
end
