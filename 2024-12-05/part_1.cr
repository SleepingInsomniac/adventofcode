#!/usr/bin/env crystal

input_path = File.join(__DIR__, {% if flag?(:release) %} "input.txt" {% else %} "test_input.txt" {% end %})

orderings = [] of Tuple(Int32, Int32)
updates = [] of Array(Int32)

File.open(input_path, "r") do |file|
  while line = file.gets
    break if line.blank?

    l, r = line.split('|').map(&.to_i32)
    orderings << {l, r}
  end

  while line = file.gets
    updates << line.split(',').map(&.to_i32)
  end
end

valid_updates = updates.select do |update|
  orderings.all? do |(left, right)|
    passed_left = false
    passed_right = false
    update.all? do |page_number|
      passed_left = true if page_number == left
      passed_right = true if page_number == right

      case
      when page_number == left && passed_right then false
      when page_number == right && passed_left then true
      else                                          true
      end
    end
  end
end

puts valid_updates.reduce(0) { |t, u| t + u[u.size // 2] }
