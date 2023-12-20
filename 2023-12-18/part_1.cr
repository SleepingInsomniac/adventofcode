#!/usr/bin/env crystal

@[Flags]
enum D : UInt8
  North; East; South; West
end

struct Instruction
  property dist : P(Int32)
  property color : String

  def initialize(dir : String, dist : String, @color)
    @dist =
      case dir
      when "U" then P[0, -dist.to_i]
      when "R" then P[dist.to_i, 0]
      when "D" then P[0, dist.to_i]
      when "L" then P[-dist.to_i, 0]
      else          raise "bad input"
      end
  end
end

struct P(T)
  macro [](x, y)
    P(typeof({{x}})).new({{x}},{{y}})
  end

  property x : T
  property y : T

  def initialize(@x, @y)
  end

  def ==(other)
    @x == other.x && @y == other.y
  end

  {% for op in %w[* / // + - % **] %}
    def {{ op.id }}(other)
      P[@x {{op.id}} other.x, @y {{op.id}} other.y]
    end
  {% end %}
end

struct Hole
  property depth : UInt8
  property from : D
  property to : D

  def initialize(@depth = 0, @from = D::None, @to = D::None)
  end
end

class Lagoon
  property instructions = [] of Instruction
  property dirt = [[Hole.new(1)]]
  property size = P(Int32).new(1, 1)
  property offset = P(Int32).new(0, 0)

  def initialize(@instructions)
  end

  def [](pos : P)
    coord = (pos + @offset)
    @dirt[coord.y][coord.x]
  end

  def []=(pos : P, value)
    coord = (pos + @offset)
    @dirt[coord.y][coord.x] = value
  end

  def dig_trench
    pos = P[0, 0]

    @instructions.each do |instr|
      dest = pos + instr.dist
      expand_to(dest)

      d = case
          when pos.x < dest.x then D::East
          when pos.x > dest.x then D::West
          when pos.y < dest.y then D::South
          when pos.y > dest.y then D::North
          else                     D::None
          end

      while pos != dest
        hole = self[pos]
        hole.to |= d
        self[pos] = hole

        pos += P[1, 0] if dest.x > pos.x
        pos += P[-1, 0] if dest.x < pos.x
        pos += P[0, 1] if dest.y > pos.y
        pos += P[0, -1] if dest.y < pos.y

        hole = self[pos]
        hole.from |= D::West if d.east?
        hole.from |= D::East if d.west?
        hole.from |= D::North if d.south?
        hole.from |= D::South if d.north?
        hole.depth = 1
        self[pos] = hole
      end
    end
  end

  def expand_to(pos : P)
    # Add cols to the left
    while pos.x + @offset.x < 0
      @dirt.each { |row| row.unshift(Hole.new) }
      @offset.x += 1
      @size.x += 1
    end

    # Add col to the right
    while pos.x + @offset.x + 1 > @size.x
      @dirt.each { |row| row << Hole.new }
      @size.x += 1
    end

    # Add rows to the top
    while pos.y + @offset.y < 0
      @dirt.unshift(Array(Hole).new(@size.x + @offset.x) { Hole.new })
      @offset.y += 1
      @size.y += 1
    end

    # Add rows to the bottom
    while pos.y + @offset.y + 1 > @size.y
      @dirt << Array(Hole).new(@size.x + @offset.x) { Hole.new }
      @size.y += 1
    end
  end

  def dig_out
    @dirt.each do |row|
      in_trench = false

      row.map! do |hole|
        in_trench = true if hole.from.south?
        in_trench = false if hole.to.south?

        hole.depth = 1 if in_trench
        hole
      end
    end
  end

  def capacity
    @dirt.map(&.map(&.depth.to_u32).sum).sum
  end

  def draw
    @dirt.each do |row|
      row.each do |hole|
        print case
        when hole.from.south? && hole.to.north? then '↑'
        when hole.from.north? && hole.to.south? then '↓'
        when hole.from.east? && hole.to.west?   then '←'
        when hole.from.west? && hole.to.east?   then '→'
        when hole.from.west? && hole.to.north?  then '┘'
        when hole.from.west? && hole.to.south?  then '┐'
        when hole.from.east? && hole.to.north?  then '└'
        when hole.from.east? && hole.to.south?  then '┌'
        when hole.from.north? && hole.to.west?  then '┘'
        when hole.from.south? && hole.to.east?  then '┌'
        when hole.from.north? && hole.to.east?  then '└'
        when hole.from.south? && hole.to.west?  then '┐'
        else                                         hole.depth > 0 ? '#' : '.'
        end
      end
      puts
    end
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

file = {% if flag?(:release) %}
         "input.txt"
       {% else %}
         "test_input.txt"
       {% end %}

instructions = File.read_lines(File.join(__DIR__, file))
  .map(&.chomp.split)
  .map { |l| Instruction.new(l[0], l[1], l[2]) }

lagoon = Lagoon.new(instructions)
lagoon.dig_trench
lagoon.dig_out
lagoon.draw
puts lagoon.capacity
