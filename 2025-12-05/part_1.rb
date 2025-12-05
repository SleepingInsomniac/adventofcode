#!/usr/bin/env ruby

# https://adventofcode.com/2025/day/5

require "stringio"

class FreshDB
  def initialize
    @ranges = []
  end

  def <<(range)
    @ranges << range
  end

  def fresh?(ingredient_id)
    @ranges.any? { |range| range.cover?(ingredient_id) }
  end
end

def solve(input)
  db = FreshDB.new

  loop do
    line = input.gets(chomp: true)
    break if line.empty?

    start, stop = line.split('-').map(&:to_i)
    db << (start..stop)
  end

  fresh_count = 0
  until input.eof?
    id = input.gets(chomp: true).to_i
    fresh_count += 1 if db.fresh?(id)
  end
  fresh_count
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

test_input = StringIO.new(<<~TEST_INPUT)
  3-5
  10-14
  16-20
  12-18

  1
  5
  8
  11
  17
  32
TEST_INPUT

tests = {
  test_input => 3
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
