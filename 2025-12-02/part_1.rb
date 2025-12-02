#!/usr/bin/env ruby

require "stringio"

# https://adventofcode.com/2025/day/2

class IDRange
  def self.parse(file)
    return nil if file.eof?
    IDRange.new(*file.gets(',').gsub(/,$/, '').split('-'))
  end

  def initialize(start, stop)
    @start, @stop = start.to_i, stop.to_i
  end

  def range = (@start..@stop)
  def invalid_ids = range.select { |n| n.to_s =~ /^(\d+)\1$/ }
  def to_s = "#{start}-#{stop}"
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def solve(input)
  total = 0
  while range = IDRange.parse(input)
    total += range.invalid_ids.sum
  end
  total
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

test_input = StringIO.new("11-22,95-115,998-1012,1188511880-1188511890,222220-222224," \
                          "1698522-1698528,446443-446449,38593856-38593862,565653-565659," \
                          "824824821-824824827,2121212118-2121212124")

tests = {
  test_input => 1227775554
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
