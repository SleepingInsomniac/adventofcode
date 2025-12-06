#!/usr/bin/env ruby

# https://adventofcode.com/2025/day/6#part2

require "stringio"

def solve(input)
  lines = input.readlines(chomp: true)
  ops = lines.pop.scan(/[^\s]\s+/)
  start, stop = 0, 0
  ranges = ops.map.with_index { |op, i| stop += op.size ; (start...(i == ops.size - 1 ? stop : stop - 1)).tap { start = stop } }
  ops.map! { it.strip.to_sym }
  lines.map { |l| ranges.map { |r| l[r].chars } }.transpose.map.with_index { |r, i| r.transpose.reverse.map { it.join.to_i }.reduce(ops[i]) }.sum
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

test_input = StringIO.new(<<~TEST_INPUT)
  123 328  51 64 
   45 64  387 23 
    6 98  215 314
  *   +   *   +  
TEST_INPUT

tests = {
  test_input => 3263827
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
