#!/usr/bin/env crystal

# https://adventofcode.com/2025/day/12

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

require "bit_array"
require "../lib/dot_display"

struct Shape(W, H)
  include Enumerable(Tuple(Int32, Int32))

  @shape : BitArray

  def initialize(&block : Int32 -> _)
    @shape = BitArray.new(W * H, &block)
  end

  def initialize(@shape : BitArray)
  end

  def [](x, y)
    @shape[y * W + x]
  end

  def []=(x, y, value)
    @shape[y * W + x] = value
  end

  def volume
    @shape.count { |b| b }
  end

  def rotate(turns = 1)
    self.class.new do |i|
      y, x = i.divmod(H)
      dest = case turns % 4
               # x = y'
               # y = (W - 1) - x'
             when 1 then (W - 1 - x) * W + (y)
               # x = (W - 1) - x'
               # y = (H - 1) - y'
             when 2 then ((H - 1) - y) * W + ((W - 1) - x)
               # x = (W - 1) - y'
               # y = x'
             when 3 then (x) * W + ((W - 1) - y)
             else i
             end

      @shape[dest]
    end
  end

  def flip_h
    self.class.new do |i|
      y, x = i.divmod(H)
      # x = (W - 1) - x'
      # y = y'
      @shape[y * W + (W - 1) - x]
    end
  end

  def flip_v
    self.class.new do |i|
      y, x = i.divmod(H)
      # x = x'
      # y = (H - 1) - y'
      @shape[(H - 1 - y) * W + x]
    end
  end

  def each
    (0...H).each { |y| (0...W).each { |x| yield({x, y}) } }
  end

  def to_s(io)
    i = 0
    (0...H).each do |y|
      (0...W).each do |x|
        io << (self[x, y] ? "██" : "  ")
        i += 1
      end
      io << "\n"
    end
  end
end

alias Present = Shape(3, 3)

class Region
  getter width : Int32
  getter height : Int32
  getter presents : Array(Tuple(Present, Int32))

  def initialize(@width, @height, @presents)
  end

  def area
    @width * @height
  end

  def presents_fit?
    return false if @presents.sum { |p, c| p.volume * c } > area
    true
  end
end

def solve(input)
  presents = [] of Present
  regions = [] of Region

  while line = input.gets(chomp: true)
    if line =~ /\d+:$/
      layout = input.read_line(chomp: true) + input.read_line(chomp: true) + input.read_line(chomp: true)
      presents << Present.new { |i| layout[i] == '#' }
    elsif line =~ /\d+x\d+/
      size, counts = line.split(": ")
      width, height = size.split("x").map(&.to_i)
      regions << Region.new(width, height, counts.split(" ").map(&.to_i).map_with_index do |count, i|
        {presents[i], count}
      end)
    end
  end

  # regions.each do |r|
  #   puts "#{r.width}x#{r.height} = #{r.area}"
  #   puts "------"
  #   r.presents.each_with_index { |(p, c), i| puts "#{i}: #{p.volume}x#{c} = #{p.volume * c}" }
  #   puts
  # end

  regions.select { |r| r.presents_fit? }.size
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

test_input = IO::Memory.new(<<-TEST_INPUT)
0:
###
##.
##.

1:
###
##.
.##

2:
.##
###
##.

3:
##.
###
##.

4:
###
#..
###

5:
###
.#.
###

4x4: 0 0 0 0 2 0
12x5: 1 0 1 0 2 2
12x5: 1 0 1 0 3 2
TEST_INPUT

# tests = {
#   test_input => 2
# }.each do |(input, expectation)|
#   result = solve(input)
#   unless result == expectation
#     STDERR.puts <<-ERROR
#       Expected: #{expectation}
#         Actual: #{result}
#     ERROR
#
#     exit 1
#   end
# end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  puts solve(file)
end
