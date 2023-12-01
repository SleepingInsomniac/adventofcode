#!/usr/bin/env ruby

# Get the first and last digit from the string on each line
#  - Some lines only have 1 digit, therefore that's the first AND last

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
