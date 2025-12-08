#!/usr/bin/env ruby

# https://adventofcode.com/2025/day/7

require "stringio"
require_relative "../lib/terminal"

$t = Terminal.new

class Manifold
  include Enumerable

  def self.parse(input)
    lines = input.readlines(chomp: true)
    width = lines.first.size
    height = lines.size
    field = lines.join.chars
    new(width, height, field)
  end

  def initialize(width, height, field)
    @width, @height, @field = width, height, field
  end

  def in_bounds?(x, y) = x >= 0 && x < @width && y >= 0 && y < @height

  def [](x, y)
    return nil unless in_bounds?(x, y)
    @field[y * @width + x] 
  end

  def []=(x, y, value)
    return unless in_bounds?(x, y)
    $t[x, y] = "|"
    @field[y * @width + x] = value
  end

  def each = 0.upto(@height - 1) { |y| 0.upto(@width - 1) { |x| yield x, y } }

  def to_s
    s = +""
    0.upto(@height - 1) do |y|
      0.upto(@width - 1) do |x|
        s += self[x, y]
      end
      s += "\n"
    end
    s
  end

  def propagate
    @splits = 0
    puts self
    each_slice(@width) do |row|
      row.each do |x, y|
        case self[x, y]
        when "S", "|" then split(x, y + 1)
        end
      end
      sleep 0.2
    end
    @splits
  end

  def split(x, y)
    if self[x, y] == "^"
      @splits += 1
      $t[0, @height + 1] = "#{@splits}"
      split(x - 1, y) unless self[x - 1, y] == "|"
      split(x + 1, y)
    else
      self[x, y] = "|"
    end
  end
end

def solve(input)
  $t.in_alt_buffer do
    $t.hidden_cursor do
      m = Manifold.parse(input)
      m.propagate
    end
  end
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

test_input = StringIO.new(<<~TEST_INPUT)
.......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
...............
TEST_INPUT

tests = {
  test_input => 21
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
