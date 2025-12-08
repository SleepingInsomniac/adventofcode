#!/usr/bin/env crystal

# https://adventofcode.com/2025/day/8#part2

require "colorize"

struct JBox(T)
  property x : T
  property y : T
  property z : T

  def initialize(@x, @y, @z)
  end

  def dist(other : JBox)
    Math.sqrt((@x - other.x) ** 2 + (@y - other.y) ** 2 + (@z - other.z) ** 2)
  end

  def to_s(io)
    bg = :dark_gray
    w = 3
    io << "JBox(".colorize(bg) <<
      x.to_s.rjust(w).colorize(:red)   << ", ".colorize(bg) <<
      y.to_s.rjust(w).colorize(:green) << ", ".colorize(bg) <<
      z.to_s.rjust(w).colorize(:blue)  <<  ")".colorize(bg)
  end

  def inspect(io)
    to_s(io)
  end
end

class UnionFind(T)
  getter parent : Array(T)
  getter size   : Array(T)
  getter count : Int32

  def initialize(n : T)
    @parent = Array.new(n) { |i| i }
    @size   = Array.new(n, 1)
    @count = n
  end

  def find(x : T) : T
    if parent[x] != x
      parent[x] = find(parent[x])
    end
    parent[x]
  end

  def union(a : T, b : T)
    ra, rb = find(a), find(b)
    return false if ra == rb

    if size[ra] < size[rb]
      ra, rb = rb, ra
    end

    parent[rb] = ra
    size[ra] += size[rb]
    @count -= 1
    true
   end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def solve(input)
  boxes = [] of JBox(Int64)

  while line = input.gets(chomp: true)
    x, y, z = line.split(",").map(&.to_i64)
    boxes << JBox(Int64).new(x, y, z)
  end

  edges = [] of Tuple(Int32, Int32, Float64)
  (0...boxes.size).each do |i1|
    ((i1 + 1)...boxes.size).each do |i2|
      edges << {i1, i2, boxes[i1].dist(boxes[i2])}
    end
  end

  edges.sort_by! { |_, _, dist| dist }
  sets = UnionFind(Int32).new(boxes.size)

  last_union = {0, 0}
  edges.each do |i1, i2, dist|
    if sets.union(i1, i2)
      last_union = {i1, i2}
      break if sets.count == 1
    end
  end

  b1, b2 = boxes[last_union[0]], boxes[last_union[1]]
  b1.x * b2.x
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

test_input = IO::Memory.new(<<-TEST_INPUT)
  162,817,812
  57,618,57
  906,360,560
  592,479,940
  352,342,300
  466,668,158
  542,29,236
  431,825,988
  739,650,466
  52,470,668
  216,146,977
  819,987,18
  117,168,530
  805,96,715
  346,949,466
  970,615,88
  941,993,340
  862,61,35
  984,92,344
  425,690,689
TEST_INPUT

tests = {
  test_input => 25272
}.each do |(input, expectation)|
  result = solve(input)
  unless result == expectation
    STDERR.puts <<-ERROR
      Expected: #{expectation}
        Actual: #{result}
    ERROR

    exit 1
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  puts solve(file)
end
