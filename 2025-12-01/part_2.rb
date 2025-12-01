#!/usr/bin/env ruby

require "stringio"

# https://adventofcode.com/2025/day/1#part2

def solve(input, size = 100)
  pointer = 50
  zeros = 0

  until input.eof?
    rotation = input.readline&.chomp
    dist = rotation.gsub('L', '-').gsub('R', '').to_i
    prev_pointer = pointer
    pointer += dist
    crossings, pointer = pointer.divmod(size)
    crossings = crossings.abs

    crossings -= 1 if pointer == 0 && dist.positive?
    crossings -= 1 if prev_pointer == 0 && dist.negative?
    crossings += 1 if pointer == 0

    zeros += crossings
  end

  zeros
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

testfile1 = StringIO.new(<<~INPUT)
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

testfile2 = StringIO.new(<<~INPUT)
  R1000 # +10 (50) 10
  L1000 # +10 (50) 20
  L50   # +1  (0)  21
  R1    # +0  (1)  21
  L1    # +1  (0)  22
  L1    # +0  (99) 22
  R1    # +1  (0)  23
  R100  # +1  (0)  24
  R1    # +0  (1)  24
INPUT

tests = {
  testfile1 => 6,
  testfile2 => 24,
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
