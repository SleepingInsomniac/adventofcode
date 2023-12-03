#!/usr/bin/env ruby

require 'set'

class Schematic
  class Part
    attr_accessor :number, :x, :y

    def initialize(number, x, y)
      @number = number
      @x = x
      @y = y
    end

    def eql?(other) = @number == other.number && @x == other.x && @y == other.y
    def hash = [@number, @x, @y].hash
  end

  attr_accessor :width, :height, :data, :parts

  def initialize(width = 140, height = 140)
    @width = width
    @height = height
    @data = File.read(File.join(__dir__, 'input.txt')).gsub(/\s*/, '')
    @parts = Set.new
  end

  def char_at(x, y)
    return '.' if y < 0 || y > @height
    return '.' if x < 0 || x > @width

    @data[y * @width + x]
  end

  def symbol(x, y)
    char = char_at(x, y)
    /[^\d\.]/.match?(char) ? char : nil
  end

  def number(x, y)
    char = char_at(x, y)
    /\d/.match?(char) ? char : nil
  end

  def add_part(x, y)
    if n = number(x, y)
      scan_x = x
      scan_x -= 1 while number(scan_x - 1, y)
      start_x = scan_x
      part_number = []

      while number(scan_x, y)
        part_number << number(scan_x, y)
        scan_x += 1
      end

      @parts << Part.new(part_number.join.to_i, start_x, y)
    end
  end

  def find_parts
    0.upto(@height) do |y|
      0.upto(@width) do |x|
        current_char = char_at(x, y)

        if symbol(x, y)
          [
            [-1, -1], [0, -1], [1, -1],
            [-1,  0],          [1,  0],
            [-1,  1], [0,  1], [1,  1],
          ].each do |ox, oy|
            add_part(x + ox, y + oy)
          end
        end
      end
    end
  end
end

schematic = Schematic.new
schematic.find_parts
puts schematic.parts.sum { |part| part.number }
