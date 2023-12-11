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
    curr = D.c(char)

    return {x, y - 1} if y - 1 != fy && curr.north? && D.c(self[x, y - 1]).south?
    return {x + 1, y} if x + 1 != fx && curr.east? && D.c(self[x + 1, y]).west?
    return {x, y + 1} if y + 1 != fy && curr.south? && D.c(self[x, y + 1]).north?
    return {x - 1, y} if x - 1 != fx && curr.west? && D.c(self[x - 1, y]).east?

    raise "Nowhere to go!"
  end

  def find_loop
    sx, sy = start
    x, y = sx, sy
    fx, fy = sx, sy

    loop_pipes = Array(Array(Char)).new(@height + 1) do
      Array(Char).new(@width + 1, '.')
    end

    loop do
      loop_pipes[y][x] = self[x, y]
      nx, ny = travel(x, y, fx, fy)
      fx, fy = x, y
      x, y = nx, ny
      break if x == sx && y == sy
    end

    Plumbing(Int32).new(loop_pipes)
  end

  def replace_start
    x, y = start
    s = D.c(self[x, y])

    north = D.c(self[x, y - 1])
    east = D.c(self[x + 1, y])
    south = D.c(self[x, y + 1])
    west = D.c(self[x - 1, y])

    @pipes[y][x] =
      case
      when east.west? && south.north?   then 'F'
      when west.east? && south.north?   then '7'
      when north.south? && west.east?   then 'J'
      when north.south? && east.west?   then 'L'
      when east.west? && west.east?     then '-'
      when north.south? && south.north? then '|'
      else                                   '*'
      end
  end

  def at(x, y, bold = true)
    case self[x, y]
    when 'F' then bold ? '┏' : '┌'
    when '7' then bold ? '┓' : '┐'
    when 'J' then bold ? '┛' : '┘'
    when 'L' then bold ? '┗' : '└'
    when '-' then bold ? '━' : '─'
    when '|' then bold ? '┃' : '│'
    when 'S' then '@'
    else          '.'
    end
  end

  def draw
    0.upto(@height) do |y|
      0.upto(@width) do |x|
        print at(x, y)
      end
      puts
    end
  end
end

map = Plumbing(Int32).new(File.read_lines(File.join(__DIR__, "input.txt")).map(&.chars))
map = map.find_loop

map.replace_start
count = 0

0.upto(map.height) do |y|
  on_border = false
  in_loop = false
  from = D::None

  0.upto(map.width) do |x|
    d = D.c(map[x, y])

    if d.none?
      on_border = false

      if in_loop
        print '█'
        count += 1
      else
        print "."
      end
    else
      if !on_border
        on_border = true
        from = d
      end

      unless d.east?
        on_border = false

        if (from.north? && d.south?) || (from.south? && d.north?)
          in_loop = !in_loop
        end
      end

      print map.at(x, y, in_loop)
    end
  end

  puts
end

puts count
