#!/usr/bin/env crystal

file = {% if flag?(:release) %}
         "input.txt"
       {% else %}
         "test_input.txt"
       {% end %}

list = [] of Int32
tally = {} of Int32 => Int32

File.read_lines(File.join(__DIR__, file)).each do |line|
  left, right = line.chomp.split(/\s+/).map(&.to_i32)
  list << left
  tally[right] ||= 0
  tally[right] += 1
end

dist = list.reduce(0) { |d, n| d += n * (tally[n]? || 0) }
puts dist
