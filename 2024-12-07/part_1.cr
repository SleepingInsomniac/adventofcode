#!/usr/bin/env crystal
input_path = File.join(__DIR__, {% if flag?(:release) %} "input.txt" {% else %} "test_input.txt" {% end %})
lines = File.read_lines(input_path).map(&.chomp)

operators = ['+', '*']

valid = lines.select do |line|
  answer_string, parts = line.split(/:\s+/)
  answer = answer_string.to_i32
  numbers = parts.split(/\s+/).map(&.to_i32)

  results = Array.new(operators.size ** (numbers.size - 1)) { |i| numbers[i % numbers.size] }
  puts results
  i = 0
  (1...numbers.size).each do |n|
    operators.each do |op|
      case
      when '+'
        puts "#{results[i]} + #{numbers[n]}"
        results[i] += numbers[n]
      when '*'
        puts "#{results[i]} * #{numbers[n]}"
        results[i] *= numbers[n]
      else raise "kaboom"
      end
      i += 1
    end
  end

  puts results
  puts
end

puts valid
