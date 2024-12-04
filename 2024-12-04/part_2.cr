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

  def xmas?(x, y)
    {
      {x - 1, y - 1, 1, 1},
      {x + 1, y - 1, -1, 1},
      {x - 1, y + 1, 1, -1},
      {x + 1, y + 1, -1, -1},
    }.count do |(x, y, dx, dy)|
      word?("MAS", x, y, dx, dy)
    end == 2
  end
end

lines = File.read_lines(File.join(__DIR__, file)).map(&.chomp)

grid = Grid.new(lines.join.chomp, lines.first.size, lines.size)
count = 0

0.upto(grid.height) do |y|
  0.upto(grid.width) do |x|
    count += 1 if grid.xmas?(x, y)
  end
end

puts count
