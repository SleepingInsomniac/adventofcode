#!/usr/bin/env crystal

file = {% if flag?(:release) %}
         "input.txt"
       {% else %}
         "test_input.txt"
       {% end %}

class Grid(T)
  property data : T
  property width : Int32
  property height : Int32

  def initialize(@data, @width, @height)
  end

  def []?(x, y)
    return nil if x < 0 || x >= width || y < 0 || y >= height
    @data[y * width + x]
  end

  def word?(word, x, y, dx, dy) : Bool
    word.chars.each_with_index.all? do |char, i|
      self[x + dx * i, y + dy * i]? == char
    end
  end
end

lines = File.read_lines(File.join(__DIR__, file)).map(&.chomp)

grid = Grid.new(lines.join.chomp, lines.first.size, lines.size)
count = 0

0.upto(grid.height) do |y|
  0.upto(grid.width) do |x|
    (-1..1).each do |dy|
      (-1..1).each do |dx|
        count += 1 if grid.word?("XMAS", x, y, dx, dy)
      end
    end
  end
end

puts count
