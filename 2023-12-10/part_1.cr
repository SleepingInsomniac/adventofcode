#!/usr/bin/env crystal

@[Flags]
enum D : UInt8
  North; East; South; West

  def self.c(char : Char)
    case char
    when 'F' then D::South | D::East
    when '7' then D::West | D::South
    when 'J' then D::North | D::West
    when 'L' then D::North | D::East
    when '-' then D::East | D::West
    when '|' then D::North | D::South
    when 'S' then D::All
    else          D::None
    end
  end

  def connect?(other : D)
    (~self & other).none?
  end

  def follow(from : D)
    self ^ from
  end

  def xy(x : Int = 0, y : Int = 0)
    y -= 1 if north?
    x += 1 if east?
    y += 1 if south?
    x -= 1 if west?
    {x, y}
  end
end

class Plumbing(T)
  property pipes : Array(Array(Char))
  property width : T
  property height : T

  def initialize(@pipes)
    @width = pipes[0].size - 1
    @height = pipes.size - 1
  end

  def [](x : T, y : T)
    return '.' if x < 0 || x > @width || y < 0 || y > @height
    @pipes[y][x]
  end

  def find(shape : Char)
    fx, fy = 0, 0

    @pipes.each_with_index do |row, y|
      row.each_with_index do |char, x|
        if char == 'S'
          fx, fy = x, y
          break
        end
      end
    end

    {fx, fy}
  end

  getter start : Tuple(T, T) do
    find('S')
  end

  def travel(x, y, fx, fy)
    char = self[x, y]
    print "From: #{self[fx, fy]} ... At: #{char} ... "
    curr = D.c(char)

    c_north = self[x, y - 1]
    if y - 1 != fy && curr.north? && D.c(c_north).south?
      puts "Going North => #{c_north}"
      return {x, y - 1}
    end

    c_east = self[x + 1, y]
    if x + 1 != fx && curr.east? && D.c(c_east).west?
      puts "Going East => #{c_east}"
      return {x + 1, y}
    end

    c_south = self[x, y + 1]
    if y + 1 != fy && curr.south? && D.c(c_south).north?
      puts "Going South => #{c_south}"
      return {x, y + 1}
    end

    c_west = self[x - 1, y]
    if x - 1 != fx && curr.west? && D.c(c_west).east?
      puts "Going West => #{c_west}"
      return {x - 1, y}
    end

    raise "Nowhere to go!"
  end

  def loop_size
    sx, sy = start
    x, y = sx, sy
    fx, fy = sx, sy

    count = 0
    loop do
      nx, ny = travel(x, y, fx, fy)
      fx, fy = x, y
      x, y = nx, ny
      count += 1
      break if x == sx && y == sy
    end
    count
  end
end

map = Plumbing(Int32).new(File.read_lines(File.join(__DIR__, "input.txt")).map(&.chars))
pp map.loop_size // 2
