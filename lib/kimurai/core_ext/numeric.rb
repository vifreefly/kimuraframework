# frozen_string_literal: true

class Numeric
  # https://stackoverflow.com/a/1679963
  def duration
    secs  = to_int
    mins  = secs / 60
    hours = mins / 60
    days  = hours / 24

    if days.positive?
      "#{days}d, #{hours % 24}h"
    elsif hours.positive?
      "#{hours}h, #{mins % 60}m"
    elsif mins.positive?
      "#{mins}m, #{secs % 60}s"
    elsif secs >= 0
      "#{secs}s"
    end
  end
end
