#!/usr/bin/env ruby

sum = 0

File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
  loop do
    break if file.eof?

    line = file.readline
    digits = line.gsub(/[^\d]+/, '')
    first = digits[0]
    last = digits[-1]

    value = (first + last).to_i
    sum += value
  end
end

puts sum
