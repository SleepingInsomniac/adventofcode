#!/usr/bin/env crystal

require "colorize"

@[Flags]
enum Cell : UInt16
  RefLeft
  RefRight
  SplitVert
  SplitHorz
  Energized
  EmitLeft
  EmitRight
  EmitUp
  EmitDown

  def filled?
    self & (RefLeft | RefRight | SplitHorz | SplitVert) != None
  end

  def emitting?
    self & (EmitLeft | EmitRight | EmitUp | EmitDown) != None
  end

  def affect_horz?
    self & (RefLeft | RefRight | SplitVert) != None
  end

  def affect_vert?
    self & (RefLeft | RefRight | SplitHorz) != None
  end
end

class Beam
  property x : Int32
  property y : Int32
  property dx : Int32
  property dy : Int32

  def initialize(@x, @y, @dx, @dy)
  end

  def step
    @x += @dx
    @y += @dy
  end

  def rot_left
    @dx, @dy = @dy, -@dx
  end

  def rot_right
    @dx, @dy = -@dy, @dx
  end
end

class Contraption
  property width : Int32
  property height : Int32
  property field : Array(Cell)
  property beams = [] of Beam
  getter energy : Int32 = 0

  def initialize(@width, @height, @field)
  end

  def index(x, y)
    y * @width + x
  end

  def [](x, y)
    @field[index(x, y)]
  end

  def []=(x, y, value)
    @field[index(x, y)] = value
  end

  def count_energy
    _energy = 0
    0.upto(@height - 1) do |y|
      0.upto(@width - 1) do |x|
        _energy += 1 if self[x, y].energized?
      end
    end
    _energy
  end

  def cell_char(x, y)
    char = case self[x, y]
           when .ref_left?   then "╲"
           when .ref_right?  then "╱"
           when .split_vert? then "│"
           when .split_horz? then "─"
           else                   " "
           end.colorize

    char = char.back(:yellow) if self[x, y].energized?
    char
  end

  def draw
    print "\033[0;0H" # Move to 0,0
    puts "Beams: #{@beams.size}, Energy: #{@energy}"
    print '┌'
    1.upto(@height) { print "─" }
    print '┐'
    puts
    0.upto(@height - 1) do |y|
      print '│'
      0.upto(@width - 1) do |x|
        char = cell_char(x, y)
        if b = @beams.find { |b| b.x == x && b.y == y }
          char.back(:white)
        end
        print char
      end
      print '│'
      puts
    end
    print '└'
    1.upto(@height) { print "─" }
    print '┘'
    puts
  end

  def step
    @beams.each do |beam|
      unless beam.x >= 0 && beam.x < @width && beam.y >= 0 && beam.y < @height
        @beams.delete(beam)
        break
      end

      cell = self[beam.x, beam.y]

      unless cell.energized?
        @energy += 1
      end

      if cell.split_vert? && beam.dx != 0
        beam.dx, beam.dy = 0, 1
        @beams << Beam.new(beam.x, beam.y - 1, 0, -1)
        if cell.emit_up?
          @beams.delete(beam)
        else
          cell |= Cell::EmitUp
        end
      elsif cell.split_horz? && beam.dy != 0
        beam.dx, beam.dy = 1, 0
        @beams << Beam.new(beam.x - 1, beam.y, -1, 0)
        if cell.emit_right?
          @beams.delete(beam)
        else
          cell |= Cell::EmitRight
        end
      elsif cell.ref_right? && beam.dx == 1 # ─┘╱
        beam.rot_left
        if cell.emit_up?
          @beams.delete(beam)
        else
          cell |= Cell::EmitUp
        end
      elsif cell.ref_left? && beam.dx == 1 # ─┐╲
        beam.rot_right
        if cell.emit_down?
          @beams.delete(beam)
        else
          cell |= Cell::EmitDown
        end
      elsif cell.ref_right? && beam.dx == -1 # ╱┌─
        beam.rot_left
        if cell.emit_down?
          @beams.delete(beam)
        else
          cell |= Cell::EmitDown
        end
      elsif cell.ref_left? && beam.dx == -1 # ╲└─
        beam.rot_right
        if cell.emit_up?
          @beams.delete(beam)
        else
          cell |= Cell::EmitUp
        end
      elsif cell.ref_right? && beam.dy == -1 # ╱┌
        beam.rot_right
        if cell.emit_right?
          @beams.delete(beam)
        else
          cell |= Cell::EmitRight
        end
      elsif cell.ref_left? && beam.dy == -1 # ┐╲
        beam.rot_left
        if cell.emit_left?
          @beams.delete(beam)
        else
          cell |= Cell::EmitLeft
        end
      elsif cell.ref_right? && beam.dy == 1 # ┘╱
        beam.rot_right
        if cell.emit_left?
          @beams.delete(beam)
        else
          cell |= Cell::EmitLeft
        end
      elsif cell.ref_left? && beam.dy == 1 # ╲└
        beam.rot_left
        if cell.emit_right?
          @beams.delete(beam)
        else
          cell |= Cell::EmitRight
        end
      end

      cell |= Cell::Energized
      self[beam.x, beam.y] = cell

      beam.step
    end
  end

  def project(x, y, dx, dy)
    @beams << Beam.new(x, y, dx, dy)

    while @beams.size > 0
      draw
      step
    end

    draw
  end
end

contraption = File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  width = 0
  height = 0
  field = Array(Cell).new

  while line = file.gets("\n", true)
    width = line.size if line.size > width
    line.chars.each do |char|
      field << case char
      when '\\' then Cell::RefLeft
      when '/'  then Cell::RefRight
      when '|'  then Cell::SplitVert
      when '-'  then Cell::SplitHorz
      else           Cell::None
      end
    end

    height += 1
  end

  Contraption.new(width, height, field)
end

print "\033[2J" # Clear
contraption.project(0, 0, 1, 0)
puts contraption.count_energy
