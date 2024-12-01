#!/usr/bin/env crystal

file = {% if flag?(:release) %}
         "input.txt"
       {% else %}
         "test_input.txt"
       {% end %}

list_left = [] of Int32
list_right = [] of Int32

File.read_lines(File.join(__DIR__, file)).each do |line|
  left, right = line.chomp.split(/\s+/).map(&.to_i32)
  list_left << left
  list_right << right
end

list_left.sort!
list_right.sort!

dist = list_left.zip(list_right).map { |(l, r)| (r - l).abs }.sum

puts dist
