#!/usr/bin/env crystal

# https://adventofcode.com/2025/day/8

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

  def initialize(n : T)
    @parent = Array.new(n) { |i| i }
    @size   = Array.new(n, 1)
  end

  def find(x : T) : T
    if parent[x] != x
      parent[x] = find(parent[x])
    end
    parent[x]
  end

  def union(a : T, b : T)
    ra, rb = find(a), find(b)
    return if ra == rb

    if size[ra] < size[rb]
      ra, rb = rb, ra
    end

    parent[rb] = ra
    size[ra] += size[rb]
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def solve(input, connections)
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

  connections.times do |i|
    i1, i2, dist = edges[i]
    sets.union(i1, i2)
  end

  counts = Hash(Int32, Int32).new(0)
  (0...boxes.size).each do |i|
    root = sets.find(i)
    counts[root] += 1
  end

  sizes = counts.values.sort.reverse
  (sizes[0].to_i64 * sizes[1] * sizes[2])
end

# 1: 162,817,812 >> 425,690,689
#    162,817,812 - 425,690,689
#    = 2 / 18
# 2: 162,817,812 >> 431,825,988
#    162,817,812 - 425,690,689
#                - 431,825,988
#    = 3 / 17
# 3: 906,360,560 >> 805,96,715
#    906,360,560 - 805,96,715
#    = 3 / 2 / 15
# 4: 431,825,988 >> 425,690,689
#    = 3 / 2 / 15

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
  test_input => 40
}.each do |(input, expectation)|
  result = solve(input, 10)
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
  puts solve(file, 1000)
end
