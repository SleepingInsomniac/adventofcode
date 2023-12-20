#!/usr/bin/env crystal

struct Instruction
  property dist : P(Int64)

  def initialize(hex : String)
    dir = hex[-2]
    dist = hex[2..-3].to_i64(16)

    @dist =
      case dir
      when '0' then P[dist, 0_i64]
      when '1' then P[0_i64, dist]
      when '2' then P[-dist, 0_i64]
      when '3' then P[0_i64, -dist]
      else          raise "bad input"
      end
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class Lagoon
  property verticies = [] of P(Int64)

  def initialize(instructions : Array(Instruction))
    pos = P[0_i64, 0_i64]

    instructions.each do |instr|
      @verticies << pos
      pos += instr.dist
    end
  end

  def area
    count = @verticies.size
    area = 0_i64
    border = 0_i64

    (0...count).each do |i|
      p1 = @verticies[i]
      p2 = @verticies[(i + 1) % count]

      edge = (p2 - p1)
      border += (edge.x + edge.y).abs

      area += p1.x * p2.y - p2.x * p1.y
    end

    border // 2 + area.abs // 2 + 1 # <- I wouldn't worry about that little guy
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
  .map { |l| Instruction.new(l[2]) }

lagoon = Lagoon.new(instructions)
puts lagoon.area
