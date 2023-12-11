#!/usr/bin/env ruby

require 'set'

class Galaxy
  def self.next_id = @gid = (@gid || 0) + 1

  attr_accessor :x, :y, :id

  def initialize(x, y)
    @x, @y, @id = x, y, Galaxy.next_id
  end

  def dist(other, expansion, e_times = 1)
    x1, x2 = @x < other.x ? [@x, other.x] : [other.x, @x]
    y1, y2 = @y < other.y ? [@y, other.y] : [other.y, @y]

    exp_x = expansion[0].reduce(0) do |t, e|
      x1 < e && x2 > e ? t + (e_times - 1) : t
    end

    exp_y = expansion[1].reduce(0) do |t, e|
      y1 < e && y2 > e ? t + (e_times - 1) : t
    end

    (x2 - x1) + (y2 - y1) + exp_y + exp_x
  end
end

class Cosmos
  include Enumerable

  attr_accessor :width, :height, :data, :galaxies

  def initialize(width, height, data)
    @width, @height, @data = width, height, data
    @galaxies ||= select { |x, y, c| c == '#' }.map { |x, y, c| Galaxy.new(x, y) }
  end

  def [](x, y)
    return '.' if (x < 0 || x > @width) || (y < 0 || y > @height)
    @data[index(x, y)]
  end

  def index(x, y) = y * @width + x

  def each
    0.upto(@height - 1) { |y| 0.upto(@width - 1) { |x| yield x, y, self[x, y] } }
  end

  def expansion
    @expansion ||= begin
      [
        (0...@width).select do |x|
          (0...@height).all? { |y| self[x, y] == '.' }
        end,
        (0...@height).select do |y|
          (0...@width).all? { |x| self[x, y] == '.' }
        end
      ]
    end
  end
end

data = File.readlines(File.join(__dir__, 'input.txt')).map(&:chomp)
cosmos = Cosmos.new(data[0].size, data.size, data.join)

# pp cosmos.expansion

galaxy_pairs = Set.new
sum = 0
cosmos.galaxies.each do |g1|
  cosmos.galaxies.each do |g2|
    next if g1.id == g2.id

    pair = Set.new([g1.id, g2.id])

    unless galaxy_pairs.include?(pair)
      galaxy_pairs << pair
      sum += g1.dist(g2, cosmos.expansion, 1_000_000)
    end
  end
end

puts sum
