#!/usr/bin/env crystal

input_path = File.join(__DIR__, {% if flag?(:release) %} "input.txt" {% else %} "test_input.txt" {% end %})
lines = File.read_lines(input_path).map(&.chomp)

class Guard
  property x : Int32
  property y : Int32
  property d : Int32

  def initialize(@x, @y, @d)
  end
end

class Grid
  property width : Int32
  property height : Int32
  property data : Slice(Char)
  property guard = Guard.new(0, 0, 0)
  property obs_count = 0

  def initialize(lines : Array(String))
    @width = lines[0].size
    @height = lines.size
    @data = Slice(Char).new(@width * @height) { '.' }
    lines.each_with_index do |line, y|
      line.chars.each_with_index do |char, x|
        self[x, y] = char
        @guard = Guard.new(x, y, "^>v<".chars.index(char).not_nil!) if "^>v<".chars.includes?(char)
      end
    end
  end

  def [](x, y)
    return nil if x < 0 || x >= @width || y < 0 || y >= @height
    @data[y * @width + x]
  end

  def []=(x, y, v)
    return nil if x < 0 || x >= @width || y < 0 || y >= @height
    @data[y * @width + x] = v
  end

  def move_guard
    self[@guard.x, @guard.y] = "^>v<"[@guard.d]
    next_pos : Tuple(Int32, Int32)

    loop do
      next_pos = case @guard.d
                 when 0 then {@guard.x, @guard.y - 1}
                 when 1 then {@guard.x + 1, @guard.y}
                 when 2 then {@guard.x, @guard.y + 1}
                 when 3 then {@guard.x - 1, @guard.y}
                 else        raise "guard direction out of bounds"
                 end

      next_tile = self[next_pos[0], next_pos[1]]
      if next_tile == '#'
        @guard.d = (@guard.d + 1) % 4
      else
        @obs_count += 1 if next_tile == 'X'

        @guard.x = next_pos[0]
        @guard.y = next_pos[1]
        self[@guard.x, @guard.y] = "^>v<"[@guard.d]
        break
      end
    end
  end

  def moves
    @data.count { |d| d == 'X' }
  end

  def to_s(io)
    0.upto(@height) do |y|
      0.upto(@width) do |x|
        io << self[x, y]
      end
      io << "\n"
    end
  end
end

grid = Grid.new(lines)
while grid.guard.x >= 0 && grid.guard.x < grid.width && grid.guard.y >= 0 && grid.guard.y < grid.height
  grid.move_guard
  puts grid
end

puts grid.obs_count
