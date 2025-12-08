#!/usr/bin/env ruby

# https://adventofcode.com/2025/day/7#part2

require "stringio"
require "set"
require_relative "../lib/terminal"
require_relative "../lib/dot_display"

$term = Terminal.new

class Manifold
  include Enumerable

  def self.parse(input)
    lines = input.readlines(chomp: true)
    width = lines.first.size
    height = lines.size
    field = lines.join.chars
    new(width, height, field)
  end

  attr_reader :width, :height

  def initialize(width, height, field)
    @width, @height, @field = width, height, field
    @disp = DotDisplay.new(width, height)
  end

  def start = find { |x, y| self[x, y] == "S" }
  def in_bounds?(x, y) = x >= 0 && x < @width && y >= 0 && y < @height

  def [](x, y)
    return nil unless in_bounds?(x, y)
    @field[y * @width + x] 
  end

  def []=(x, y, value)
    return unless in_bounds?(x, y)
    @field[y * @width + x] = value
  end

  def each = 0.upto(@height - 1) { |y| 0.upto(@width - 1) { |x| yield x, y } }

  def to_s
    s = +""
    0.upto(@height - 1) do |y|
      0.upto(@width - 1) do |x|
        s += case self[x, y]
            when '^' then '▲'
            else ' '
            end
      end
      s += "\n"
    end
    s
  end

  def propagate(x, y, paths = {}, dir = :center)
    return 1 unless in_bounds?(x, y)

    key = "#{x},#{y}"
    return paths[key] if paths.key?(key)

    $term.home

    paths[key] =
      case self[x, y]
      when "^"
        propagate(x - 1, y, paths, :left) + propagate(x + 1, y, paths, :right)
      else
        if dir == :left
          $term[x, y] = "╭"
        elsif dir == :right
          $term[x, y] = "╮"
        else
          $term[x, y] = "│"
        end
        @disp[x, y] = true
        propagate(x, y + 1, paths)
      end
  end
end

def solve(input)
  $term.in_alt_buffer do
    $term.hidden_cursor do
      m = Manifold.parse(input)
      $term.with_color([200,0,0]) { print m }
      m.propagate(*m.start)
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
  test_input => 40
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
