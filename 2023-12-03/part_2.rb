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

  def gear(x, y)
    char = char_at(x, y)
    char == '*' ? char : nil
  end

  def number(x, y)
    char = char_at(x, y)
    /\d/.match?(char) ? char : nil
  end

  def get_part(x, y)
    if n = number(x, y)
      scan_x = x
      scan_x -= 1 while number(scan_x - 1, y)
      start_x = scan_x
      part_number = []

      while number(scan_x, y)
        part_number << number(scan_x, y)
        scan_x += 1
      end

      Part.new(part_number.join.to_i, start_x, y)
    end
  end

  def sum_gears
    sum = 0

    0.upto(@height) do |y|
      0.upto(@width) do |x|
        current_char = char_at(x, y)

        if gear(x, y)
          parts = Set.new

          [
            [-1, -1], [0, -1], [1, -1],
            [-1,  0],          [1,  0],
            [-1,  1], [0,  1], [1,  1],
          ].each do |ox, oy|
            if part = get_part(x + ox, y + oy)
              parts << part
            end
          end

          parts = parts.to_a
          sum += parts[0].number * parts[1].number if parts.size == 2
        end
      end
    end

    sum
  end
end

puts Schematic.new.sum_gears
