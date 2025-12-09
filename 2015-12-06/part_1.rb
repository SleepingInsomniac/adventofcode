#!/usr/bin/env ruby

# https://adventofcode.com/2015/day/6

require "stringio"
require_relative "../lib/terminal"
require_relative "../lib/dot_display"

def solve(input)
  grid = DotDisplay.new(1000, 1000)
  term = Terminal.new

  term.in_alt_buffer do
    term.hidden_cursor do

      input.each_line(chomp: true) do |line|
        term.home
        inst, *cords = line.split(/(turn on|turn off|toggle) (\d+),(\d+) through (\d+),(\d+)/)[1..]
        x1, y1, x2, y2 = cords.map(&:to_i)
        y1.upto(y2) do |y|
          x1.upto(x2) do |x|
            grid[x, y] = case inst
                         when "turn on"  then true
                         when "turn off" then false
                         when "toggle"   then !grid[x, y]
                         end
            term[x / 2, y / 4] = grid.char_at(x, y)
          end
        end
      end

      gets
    end
  end

  grid.count { |x, y| grid[x, y] }
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
  puts solve(file)
end
