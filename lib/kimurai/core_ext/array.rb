class Array
  def in_sorted_groups(number, fill_width = nil)
    sorted_groups = Array.new(number) { |_a| a = [] }

    in_groups_of(number, fill_width).each do |group|
      number.times do |i|
        begin
          group.fetch(i)
        rescue StandardError
          next
        end

        sorted_groups[i] << group[i]
      end
    end

    sorted_groups
  end
end
