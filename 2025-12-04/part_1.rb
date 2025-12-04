#!/usr/bin/env ruby

# https://adventofcode.com/2025/day/4

require "stringio"

class Grid
  include Enumerable

  def initialize(data, width, height)
    @data, @width, @height = data, width, height
  end

  def neighbors(x, y)
    [
      [-1, -1], [0, -1], [1, -1],
      [-1,  0],          [1,  0],
      [-1,  1], [0,  1], [1,  1],
    ]
      .map { |dx, dy| [x + dx, y + dy] }
      .reject { |x, y| x < 0 || y < 0 || x >= @width || y >= @height }
  end

  def roll?(x, y)           = self[x, y] != '.'
  def count_neighbors(x, y) = neighbors(x, y).count { |x, y| roll?(x, y) }
  def [](x, y)              = @data[y * @width + x]

  def []=(x, y, value)
    @data[y * @width + x] = value
  end

  def accessible?(x, y) = count_neighbors(x, y) < 4
  def each              = 0.upto(@height - 1) { |y| 0.upto(@width - 1) { |x| yield x, y, self[x, y] } }
  def count_accessible  = count { |x, y, value| roll?(x, y) && accessible?(x, y) }
end

def solve(input)
  lines = input.readlines(chomp: true)
  width = lines.first.size
  height = lines.size
  grid = Grid.new(lines.join.chars, width, height)
  grid.count_accessible
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

test_input = StringIO.new(<<~INPUT)
  ..@@.@@@@.
  @@@.@.@.@@
  @@@@@.@.@@
  @.@@@@..@.
  @@.@@@@.@@
  .@@@@@@@.@
  .@.@.@.@@@
  @.@@@.@@@@
  .@@@@@@@@.
  @.@.@@@.@.
INPUT

tests = {
  test_input => 13
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
