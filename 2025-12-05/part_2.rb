#!/usr/bin/env ruby

# https://adventofcode.com/2025/day/5#part2

require "stringio"

class FreshDB
  def initialize
    @ranges = []
  end

  def <<(range)
    return if @ranges.any? { |r| r.cover?(range) }

    @ranges.reject! { |r| range.cover?(r) }

    if index = @ranges.index { |r| r.cover?(range.begin) }
      updatable = @ranges.delete_at(index)
      b = range.begin < updatable.begin ? range.begin : updatable.begin
      self << (b..range.end)
    elsif index = @ranges.index { |r| r.cover?(range.end) }
      updatable = @ranges.delete_at(index)
      e = range.end > updatable.end ? range.end : updatable.end
      self << (range.begin..e)
    else
      @ranges << range
    end
  end

  def fresh_total
    @ranges.reduce(0) { |m, r| m + r.count }
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

  db.fresh_total
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

test_input1 = StringIO.new(<<~TEST_INPUT)
  3-5
  10-14
  16-20
  12-18

TEST_INPUT

# First range covers entire second range
test_input2 = StringIO.new(<<~TEST_INPUT)
  10-20
  12-18

TEST_INPUT

# Second range within first range
test_input3 = StringIO.new(<<~TEST_INPUT)
  12-18
  10-20

TEST_INPUT

tests = {
  test_input1 => 14,
  test_input2 => 11,
  test_input3 => 11,
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
