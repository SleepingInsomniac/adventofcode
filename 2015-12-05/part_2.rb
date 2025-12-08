#!/usr/bin/env ruby

# https://adventofcode.com/2015/day/5#part2

require "stringio"

class Item
  def initialize(value)
    @value = value
  end

  def nice? = two_non_overlapping_letter_pairs? && letter_sandwich?
  def two_non_overlapping_letter_pairs? = @value.match?(/(..).*\1/)
  def letter_sandwich? = @value.match?(/(.).\1/)
end

def solve(input)
  total = 0
  until input.eof?
    total += 1 if Item.new(input.readline(chomp: true)).nice?
  end
  total
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

raise "fail" unless Item.new("xyxy").two_non_overlapping_letter_pairs?
raise "fail" if Item.new("aaa").two_non_overlapping_letter_pairs?

raise "fail" unless Item.new("xyx").letter_sandwich?
raise "fail" unless Item.new("abcdefeghi").letter_sandwich?
raise "fail" unless Item.new("efe").letter_sandwich?
raise "fail" unless Item.new("aaa").letter_sandwich?

raise "fail" unless Item.new("qjhvhtzxzqqjkmpb").nice?
raise "fail" unless Item.new("xxyxx").nice?

raise "fail" if Item.new("uurcxstgmygtbstg").nice?
raise "fail" if Item.new("ieodomkazucvgmuy").nice?

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
  puts solve(file)
end
