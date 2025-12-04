#!/usr/bin/env ruby

# https://adventofcode.com/2025/day/4#part2

require "colorize"
require "stringio"

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "terminal"
$term = Terminal.new

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

  def to_s                  = @data.each_slice(@width).map.with_index { |row, i| "#{i.to_s(16)} ".rjust(4) + row.join }.join("\n")
  def accessible?(x, y)     = count_neighbors(x, y) < 4
  def each                  = 0.upto(@height - 1) { |y| 0.upto(@width - 1) { |x| yield x, y } }

  def count_accessible
    count { |x, y| roll?(x, y) && accessible?(x, y) }
  end

  def accessible_rolls
    select { |x, y| roll?(x, y) && accessible?(x, y) }
  end

  def remove(rolls)
    rolls.each { |x, y| self[x, y] = "." }
  end
end

def solve(input)
  lines = input.readlines(chomp: true)
  width = lines.first.size
  height = lines.size

  grid = Grid.new(lines.join.chars, width, height)
  total = 0
  loop do
    removable = grid.accessible_rolls
    break if removable.empty?
    $term.home
    removable.each { |x, y| grid[x, y] = grid[x, y].colorize(:red) }
    puts grid
    sleep 0.2
    total += removable.count
    grid.remove(removable)
  end
  total
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
  test_input => 43
}.map do |(input, expectation)|
  result = solve(input)
  unless result == expectation
    $stderr.puts "Failure! #{result} != #{expectation}"
    exit(1)
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
  puts solve(file)
end
