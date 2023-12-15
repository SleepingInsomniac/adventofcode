#!/usr/bin/env ruby

sequence = File.read(File.join(__dir__, 'input.txt')).chomp.split(',')

t = sequence.reduce(0) do |total, string|
  current_value = 0

  string.chars.each do |char|
    current_value += char.ord
    current_value *= 17
    current_value %= 256
  end

  total + current_value
end

puts t
