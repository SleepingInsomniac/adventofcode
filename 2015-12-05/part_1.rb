#!/usr/bin/env ruby

# https://adventofcode.com/2015/day/5

require "stringio"

class Item
  def initialize(name)
    @name = name
  end

  def nice? = has_three_vowels? && has_double_letter? && has_no_bad_strings?
  def has_three_vowels? = @name.chars.select { |c| "aoeui".chars.include?(c) }.count >= 3
  def has_double_letter? = @name.match?(/(.)\1/)
  def has_no_bad_strings? = !@name.match(/(ab|cd|pq|xy)/)
end

def solve(input)
  total = 0
  until input.eof?
    total += 1 if Item.new(input.readline(chomp: true)).nice?
  end
  total
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tests = {
  "ugknbfddgicrmopn" => true,
  "aaa"              => true,
  "jchzalrnumimnmhp" => false,
  "haegwjzuvuyypxyu" => false,
  "dvszwmarrgswjxmb" => false,
}.each do |(input, expectation)|
  result = Item.new(input).nice?
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
