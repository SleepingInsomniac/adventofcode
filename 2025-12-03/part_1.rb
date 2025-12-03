#!/usr/bin/env ruby

# https://adventofcode.com/2025/day/3

class Bank
  def initialize(values)
    @values = values.chars.map(&:to_i)
  end

  def max
    d1, d2 = 0, 0
    @values.each_cons(2) do |v1, v2|
      if v1 > d1
        d1, d2 = v1, v2
      elsif v2 > d2
        d2 = v2
      end
    end
    d1 * 10 + d2
  end
end

def solve(input)
  total = 0
  until input.eof?
    total += Bank.new(input.gets.chomp).max
  end
  total
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tests = {
  "987654321111111" => 98,
  "811111111111119" => 89,
  "234234234234278" => 78,
  "818181911112111" => 92,
}.map do |(input, expectation)|
  result = Bank.new(input).max
  [input, [result == expectation, "Expected #{result} to equal #{expectation}"]]
end.to_h

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if tests.values.all? { |v| v[0] }
  File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
    puts solve(file)
  end
else
  $stderr.puts tests
end
