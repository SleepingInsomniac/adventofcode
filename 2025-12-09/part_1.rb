#!/usr/bin/env ruby

# https://adventofcode.com/2025/day/9

require "stringio"

def solve(input)
  coords = []
  until input.eof?
    coords << input.readline.split(',').map(&:to_i)
  end

  largest = 0

  0.upto(coords.size - 1) do |i1|
    (i1 + 1).upto(coords.size - 1) do |i2|
      x1,y1 = coords[i1]
      x2,y2 = coords[i2]
      size = area(x1, y1, x2, y2)
      largest = size if size > largest
    end
  end

  largest
end

def area(x1, y1, x2, y2)
  ((x1 - x2).abs + 1) * ((y1 - y2).abs + 1)
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

test_input = StringIO.new(<<~TEST_INPUT)
  7,1
  11,1
  11,7
  9,7
  9,5
  2,5
  2,3
  7,3
TEST_INPUT

tests = {
  test_input => 50
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
