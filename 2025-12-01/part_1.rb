#!/usr/bin/env ruby

require "stringio"

# https://adventofcode.com/2025/day/1

def solve(input)
  pointer = 50
  zeros = 0

  while rotation = input.readline&.chomp
    dir, dist = rotation.split(/(\d+)/)
    pointer += case dir
               when 'L' then -dist.to_i
               when 'R' then dist.to_i
               else
                 raise "Invalid direction: #{dir}"
               end

    pointer %= 100
    zeros += 1 if pointer == 0

    break if input.eof?
  end

  zeros
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

testfile = StringIO.new(<<~INPUT)
  L68
  L30
  R48
  L5
  R60
  L55
  L1
  L99
  R14
  L82
INPUT

tests = {
  testfile => 3
}.map do |(input, expectation)|
  result = solve(input)
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
