#!/usr/bin/env ruby

# https://adventofcode.com/2025/day/9#part2

require "stringio"

def parse(input)
  width, height = 0, 0
  coords = []
  until input.eof?
    x, y = input.readline.split(',').map(&:to_i)
    width = x if x > width
    height = y if y > height
    coords << [x, y]
  end
  [width, height, coords]
end

class Shape
  def initialize(coords)
    @coords = coords
    @edges = create_edges
    @memo = {}
  end

  def inside?(x, y)
    key = :"#{x},#{y}"
    return @memo[key] if @memo.key?(key)
    crossings = 0

    @edges.each do |ex, ey1, ey2|
      break if ex > x

      if ey1 > ey2
        crossings += 1 if y >= ey2 && y <= ey1
      else
        crossings -= 1 if y >= ey1 && y <= ey2
      end
    end

    crossings.odd?.tap { |r| @memo[key] = r }
  end

  private

  def create_edges
    edges = []
    0.upto(@coords.size - 1) do |i|
      x1, y1 = @coords[i]
      x2, y2 = @coords[(i + 1) % @coords.size]

      next unless x1 == x2

      px, py = @coords[(i - 1) % @coords.size]
      nx, ny = @coords[(i + 2) % @coords.size]

      # right_up
      if px < x1 && y1 > y2
        y1 -= 1
      end

      # up_left
      if y1 > y2 && x1 > nx
        y2 += 1
      end

      # Shift to the right to make inclusive
      if y2 > y1
        x1 += 1
      end

      edges << [x1, y1, y2]
    end
    edges.sort_by { |x, _, _| x }
  end
end

def area(x1, y1, x2, y2)
  ((x1 - x2).abs + 1) * ((y1 - y2).abs + 1)
end

def solve(input)
  width, height, coords = parse(input)
  largest = 0

  shape = Shape.new(coords)

  0.upto(coords.size - 1) do |i1|
    (i1 + 1).upto(coords.size - 1) do |i2|
      x1,y1 = coords[i1]
      x2,y2 = coords[i2]
      x1, x2 = x2, x1 if x2 < x1
      y1, y2 = y2, y1 if y2 < y1

      size = area(x1, y1, x2, y2)
      next if size <= largest

      valid = (y1..y2).all? do |y|
        shape.inside?(x1, y) && shape.inside?(x2, y)
      end

      valid = valid && (x1..x2).all? do |x|
        shape.inside?(x, y1) && shape.inside?(x, y2)
      end

      largest = size if valid && size > largest
    end
  end

  largest
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

test_input = StringIO.new(<<~TEST_INPUT)
  7,1
  11,1
  11,7
  9,7
  9,5
  2,5
  2,3
  7,3
TEST_INPUT

tests = {
  test_input => 24
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
