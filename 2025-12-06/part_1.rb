#!/usr/bin/env ruby

# https://adventofcode.com/2025/day/6

require "stringio"

def solve(input)
  lines = input.readlines(chomp: true)
  ops = lines.pop.split(/\s+/).map(&:to_sym)
  numbers = lines.map { |l| l.strip.split(/\s+/).map(&:to_i) }
    .transpose.map.with_index { |col, i| col.reduce(ops[i]) }.sum
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

test_input = StringIO.new(<<~TEST_INPUT)
  123 328 51 64 
   45 64 387 23 
    6 98 215 314
  * + * +
TEST_INPUT

tests = {
  test_input => 4277556
}.each do |(input, expectation)|
  result = solve(input)
  unless result == expectation
    $stderr.puts <<~ERROR
      Expected: #{expectation}
        Actual: #{result}
    ERROR

    exit 1
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
  puts solve(file)
end
