#!/usr/bin/env crystal

file = {% if flag?(:release) %}
         "input.txt"
       {% else %}
         "test_input.txt"
       {% end %}

reports = File.read_lines(File.join(__DIR__, file)).map(&.chomp.split(/\s+/).map(&.to_i32))

safe_count = reports.select do |report|
  increasing = report[1] > report[0]

  report.each_cons(2).all? do |(n1, n2)|
    (increasing ? n1 < n2 : n1 > n2) && (n2 - n1).abs.in?(1..3)
  end
end.size

puts safe_count
