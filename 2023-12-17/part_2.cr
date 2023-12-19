#!/usr/bin/env crystal

require "colorize"
require "set"

require "./lib/display"
require "./lib/point"

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class Search
  getter city : City
  getter open_list : PQueue(Node)
  getter closed_list = Set(Tuple(Point(Int32), Point(Int32), Point(Int32))).new
  getter start : Point(Int32)
  property dest : Point(Int32)

  def initialize(@city, @start, @dest)
    @open_list = PQueue(Node).new { |a, b| cost(a) > cost(b) }
    @open_list << Node.new(@start, @city[@start])
  end

  def cost(node)
    node.cost + node.pos.dist(@dest)
  end

  def neighbors(node)
    [
      node.pos + Point[1, 0],
      node.pos + Point[0, 1],
      node.pos + Point[-1, 0],
      node.pos + Point[0, -1],
    ]
      .reject { |pos| @city[pos]?.nil? }                           # Out of bounds
      .reject { |pos| node.prev && node.prev.not_nil!.pos == pos } # Reverses direction
      .map { |p| Node.new(p, @city[p], node) }                     #
      .reject(&.too_long?)                                         # Length too long
      .reject(&.too_short?)                                        # Length too short
  end

  def step
    node = @open_list.pop
    if @closed_list.includes?({node.pos, node.direction, node.run})
      node.draw(:black, :dark_gray)
      return nil
    end
    @closed_list << {node.pos, node.direction, node.run}

    return node if node.pos == @dest

    neighbors(node).each do |next_node|
      next_node.draw(:cyan, :black)
      @open_list << next_node
    end

    nil
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class City
  property width : Int32
  property height : Int32
  property blocks : Array(UInt8)

  def initialize(@width, @height, @blocks)
  end

  def draw(fore = :green, back = :black)
    0.upto(@height - 1) do |y|
      Display.move_to(0, y)
      Display.trunc
      0.upto(@width - 1) do |x|
        Display.text(x, y, self[Point[x, y]].to_s.colorize.fore(fore).back(back))
      end
    end
  end

  def index(pos : Point)
    pos.y * @width + pos.x
  end

  def in_bounds?(pos : Point)
    pos.x >= 0 && pos.x < @width && pos.y >= 0 && pos.y < @height
  end

  def []?(pos : Point)
    in_bounds?(pos) ? @blocks[index(pos)] : nil
  end

  def [](pos : Point)
    raise "Out of bounds" unless in_bounds?(pos)

    @blocks[index(pos)]
  end

  def search(start = Point[0, 0], dest = Point[@width - 1, @height - 1])
    s = Search.new(self, start, dest)

    until node = s.step
    end

    node
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class PQueue(T)
  property array = [] of T
  @block : T, T -> Bool

  delegate shift, shift?, pop, pop?, size, find, delete_at, bsearch_index, :select, to: @array

  def initialize(&block : T, T -> Bool)
    @block = block
  end

  def index(item)
    @array.bsearch_index { |n| @block.call(item, n) }
  end

  def <<(item)
    @array.insert(index(item) || @array.size, item)
  end

  def [](index)
    @array[index]
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class Node
  property value : UInt8
  getter cost = 0
  getter pos : Point(Int32)
  getter prev : Node?
  getter run : Point(Int32) = Point[0, 0]

  def initialize(@pos, @value, @prev : Node? = nil)
    if p = @prev
      @cost = p.cost + @value

      if p.pos.y == @pos.y
        @run = Point[p.run.x + 1, 0]
      else
        @run = Point[0, p.run.y + 1]
      end
    end
  end

  def draw(back = :black, fore = :dark_gray, as_direction = false)
    s = as_direction ? direction_char : @value.to_s
    Display.text(pos.x, pos.y, s.colorize.back(back).fore(fore))
  end

  def direction
    if p = @prev
      @pos - p.pos
    else
      Point[0, 0]
    end
  end

  def from
    if p = @prev
      if @pos.y == p.pos.y
        p.pos.x < @pos.x ? :left : :right
      else
        p.pos.y < @pos.y ? :up : :down
      end
    else
      :none
    end
  end

  def too_short?(n = 4)
    if p = @prev
      (p.run.x > 0 && p.run.x < n && @run.x == 0) ||
        (p.run.y > 0 && p.run.y < n && @run.y == 0)
    else
      false
    end
  end

  def too_long?(n = 10)
    @run.x > n || @run.y > n
  end

  def to_s
    @prev.to_s + " > #{@block}"
  end

  def direction_char
    case from
    when :none  then "⊛"
    when :left  then "▶︎"
    when :right then "◀︎"
    when :up    then "▼"
    when :down  then "▲"
    else             value.to_s
    end
  end

  def draw_path(back = :yellow, fore = :black)
    node = self
    loop do
      Display.text(node.pos.x, node.pos.y, node.direction_char.colorize.fore(fore).back(back))

      break unless node = node.prev
    end
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

file = {% if flag?(:release) %}
         "input.txt"
       {% else %}
         "test_input.txt"
       {% end %}

lines = File.read_lines(File.join(__DIR__, file)).map(&.chomp)
width = lines[0].size
height = lines.size
blocks = lines.map { |l| l.chars.map { |c| c.to_u8 } }.flatten

at_exit { Display.cursor_on }
Signal::INT.trap do
  Display.move_to(0, height + 2)
  Display.cursor_on
  exit(130)
end
Display.cursor_off

city = City.new(width, height, blocks)
city.draw
node = city.search

# city.draw(fore: :dark_gray, back: :black)
node.draw_path(back: :red)
Display.text(0, height + 1, "Heatloss: #{node.cost}", true)
Display.move_to(0, height + 2)
