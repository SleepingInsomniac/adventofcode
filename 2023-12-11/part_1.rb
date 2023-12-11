#!/usr/bin/env ruby

require 'set'

class Galaxy
  def self.next_id = @gid = (@gid || 0) + 1

  attr_accessor :x, :y, :id

  def initialize(x, y)
    @x, @y, @id = x, y, Galaxy.next_id
  end

  def dist(other) = (other.x - @x).abs + (other.y - @y).abs
end

class Cosmos
  include Enumerable

  attr_accessor :width, :height, :data

  def initialize(width, height, data)
    @width, @height, @data = width, height, data
  end

  def [](x, y)
    return '.' if (x < 0 || x > @width) || (y < 0 || y > @height)
    @data[index(x, y)]
  end

  def index(x, y) = y * @width + x

  def each
    0.upto(@height - 1) { |y| 0.upto(@width - 1) { |x| yield x, y, self[x, y] } }
  end

  def galaxies
    @galaxies ||= select { |x, y, c| c == '#' }.map { |x, y, c| Galaxy.new(x, y) }
  end

  def expand!
    @galaxies = nil

    expansion_x = (0...@width).select do |x|
      (0...@height).all? { |y| self[x, y] == '.' }
    end

    expanded = @data.chars.each_slice(@width).map do |slice|
      expansion_x.each_with_index { |x, i| slice.insert(x + i, '.') }
      slice.join
    end

    expanded.size.times do |y|
      row = expanded.shift
      expanded.push(row.dup) if /^\.+$/.match?(row)
      expanded.push(row)
    end

    @width, @height, @data = expanded.first.size, expanded.size, expanded.join
  end
end

data = File.readlines(File.join(__dir__, 'input.txt')).map(&:chomp)
cosmos = Cosmos.new(data[0].size, data.size, data.join)

cosmos.expand!
galaxy_pairs = Set.new
sum = 0
cosmos.galaxies.each do |g1|
  cosmos.galaxies.each do |g2|
    next if g1.id == g2.id

    pair = Set.new([g1.id, g2.id])

    unless galaxy_pairs.include?(pair)
      galaxy_pairs << pair
      sum += g1.dist(g2)
    end
  end
end

puts sum
