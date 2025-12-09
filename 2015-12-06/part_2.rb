#!/usr/bin/env ruby

# https://adventofcode.com/2015/day/6#part2

require "stringio"

require_relative "../lib/grid"

def solve(input)
  grid = Grid.new(1000, 1000) { 0 }
  input.each_line(chomp: true) do |line|
    inst, *cords = line.split(/(turn on|turn off|toggle) (\d+),(\d+) through (\d+),(\d+)/)[1..]
    x1, y1, x2, y2 = cords.map(&:to_i)
    y1.upto(y2) do |y|
      x1.upto(x2) do |x|
        grid[x, y] = case inst
                     when "turn on"  then grid[x, y] + 1
                     when "turn off" then (grid[x, y] - 1).clamp(0, Float::INFINITY)
                     when "toggle"   then grid[x, y] + 2
                     end
      end
    end
  end

  grid.sum { |x, y| grid[x, y] }
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
  puts solve(file)
end
