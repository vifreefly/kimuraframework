require 'pathname'

class Capybara::Driver::Base
  attr_accessor :visited
  attr_writer :requests, :responses

  def requests
    @requests ||= 0
  end

  def responses
    @responses ||= 0
  end

  def current_memory
    driver_pid = pid
    # if #driver hasn't been called yet, driver_pid will be nil.
    # In this case we need to set memory to zero
    # return 0 unless driver_pid
    all = (get_descendant_processes(driver_pid) << driver_pid).uniq

    # fix error, sometimes in get_descendant_processes appears pid of the command
    # itself (ps -eo pid,ppid). Of course it's gone already when GetProcessMem
    # tryining to find this process proc
    all.map { |pid| get_process_memory(pid) }.sum
  end

  private

  def get_descendant_processes(base)
    descendants = Hash.new { |ht, k| ht[k] = [k] }
    Hash[*`ps -eo pid,ppid`.scan(/\d+/).map(&:to_i)].each do |pid, ppid|
      descendants[ppid] << descendants[pid]
    end

    descendants[base].flatten - [base]
  end

  # https://github.com/schneems/get_process_mem
  # Note: for Linux takes PSS (not RSS) memory (I think PSS better fit in this case)
  def get_process_memory(pid)
    case @platform ||= Gem::Platform.local.os
    when "linux"
      begin
        file = Pathname.new "/proc/#{pid}/smaps"
        return 0 unless file.exist?

        lines = file.each_line.select { |line| line.match(/^Pss/) }
        return 0 if lines.empty?

        lines.reduce(0) do |sum, line|
          line.match(/(?<value>(\d*\.{0,1}\d+))\s+(?<unit>\w\w)/) do |m|
            sum += m[:value].to_i
          end

          sum
        end
      rescue Errno::EACCES
        0
      end
    when "darwin"
      mem = `ps -o rss= -p #{pid}`.strip
      mem.empty? ? 0 : mem.to_i
    else
      raise "Can't check process memory, wrong type of platform: #{@platform}"
    end
  end
end
