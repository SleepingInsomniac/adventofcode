#!/usr/bin/env crystal

struct Platform
  property width : Int32
  property height : Int32
  property field : Array(Char)

  def initialize(@width, @height)
    @field = Array(Char).new(@width * @height) { '.' }
  end

  def index(x, y)
    y * @width + x
  end

  def [](x, y)
    @field[index(x, y)]
  end

  def []=(x, y, value)
    @field[index(x, y)] = value
  end

  def draw
    0.upto(@height - 1) do |y|
      0.upto(@width - 1) do |x|
        if cell = self[x, y]
          print cell.to_s
        else
          print '.'
        end
      end
      puts
    end
  end

  def tilt_upward
    0.upto(@height - 1) do |y|
      0.upto(@width - 1) do |x|
        roll_upward(x, y) if self[x, y] == 'O'
      end
    end
  end

  def roll_upward(x, y)
    while y > 0 && self[x, y - 1] == '.'
      boulder = self[x, y]
      self[x, y] = '.'
      y -= 1
      self[x, y] = boulder
    end
  end

  def load
    load = 0

    0.upto(@height - 1) do |y|
      0.upto(@width - 1) do |x|
        if self[x, y] == 'O'
          load += (@height - y)
        end
      end
    end

    load
  end
end

platform = Platform.new(100, 100)

File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  y = 0
  while line = file.gets("\n", true)
    line.chars.each_with_index do |char, x|
      platform[x, y] = char
    end

    y += 1
  end
end

platform.tilt_upward
platform.draw
puts platform.load
