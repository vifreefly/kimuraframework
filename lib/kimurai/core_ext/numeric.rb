class Numeric
  # https://stackoverflow.com/a/1679963
  def duration
    secs  = self.to_int
    mins  = secs / 60
    hours = mins / 60
    days  = hours / 24

    if days > 0
      "#{days}d, #{hours % 24}h"
    elsif hours > 0
      "#{hours}h, #{mins % 60}m"
    elsif mins > 0
      "#{mins}m, #{secs % 60}s"
    elsif secs >= 0
      "#{secs}s"
    end
  end
end
