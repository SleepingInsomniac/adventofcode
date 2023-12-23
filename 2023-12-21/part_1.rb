#!/usr/bin/env ruby

require 'set'

module Display
  def self.text(x, y, string = "", truncate = false)
    move_to(x, y)
    trunc if truncate
    print string
  end

  def self.move_to(x, y) = print "\033[#{y + 1};#{x + 1}H"
  def self.clear = print "\033[2J"
  def self.home = print "\033[H"
  def self.cursor_off = print "\033[?25l"
  def self.cursor_on = print "\033[?25h"
  def self.trunc = print "\033[K"
end


class Garden
  def initialize(width, height, plots)
    @width, @height, @plots = width, height, plots
  end

  def index(x, y)
    y * @width + x
  end

  def draw
    0.upto(@height - 1) do |y|
      0.upto(@width - 1) do |x|
        Display.text(x, y, @plots[index(x, y)], true)
      end
    end
  end

  def start
    @start ||= @plots.index('S').divmod(@width)
  end

  def neighbors(x, y)
    [[x, y - 1], [x -1, y], [x + 1, y], [x, y + 1]].reject do |(x, y)|
      @plots[index(x, y)] == '#'
    end
  end

  def step(positions = [start])
    positions.each_with_object(Set.new) { |p, o| neighbors(*p).each { |n| o << n } }
  end

  def walk(goal)
    positions = Set.new
    positions << start
    goal.times do |n|
      positions = step(positions)
      draw
      positions.each { |(x, y)| Display.text(x, y, 'O') }
      Display.text(0, @height + 1, positions.size, true)
    end
    positions
  end
end

lines = File.readlines(File.join(__dir__, 'input.txt')).map(&:chomp)
width = lines[0].size
height = lines.size

at_exit { Display.cursor_on }
Display.cursor_off

garden = Garden.new(width, height, lines.join)

positions = garden.walk(64)

Display.move_to(0, height + 1)
puts positions.count
