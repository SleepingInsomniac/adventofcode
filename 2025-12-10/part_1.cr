#!/usr/bin/env crystal

# https://adventofcode.com/2025/day/10

struct Mach(T)
  def self.parse(string)
    on_state = string[/\[[^\]]+\]/][1...-1]
    Mach(UInt16).new(
      on_state.chars.map { |c| c == '#' ? '1' : '0' }.join.to_u16(2),
      on_state.size
    )
  end

  def self.parse_buttons(string)
    size = string[/\[[^\]]+\]/][1...-1].size
    string.scan(/\([^\)]+\)/).map do |b|
      b[0][1...-1].split(",").map(&.to_u16).reduce(0u16) { |m, b| m | (1u16 << size - 1 >> b) }
    end
  end

  def self.stringify(value, size : Int)
    String.build { |io| io << value.to_s(2).rjust(size, '0').chars.map { |l| l == '1' ? '◉' : '○' }.join }
  end

  getter target : T
  getter size : Int32
  getter on : T
  getter presses : Int32

  def initialize(@target : T, @size : Int32, @on : T = T.new(0), @presses : Int32 = 0)
  end

  def press(button : T)
    self.class.new(@target, @size, @on ^ button, @presses + 1)
  end

  def on?
    @on == @target
  end

  def to_s(io)
    io << self.class.stringify(@on, @size) << " " << @presses.to_s
  end
end

def solve(input)
  input.each_line.map do |line|
    q = [] of Mach(UInt16)

    m = Mach.parse(line)
    least = m
    q << m
    buttons = Mach.parse_buttons(line)

    while m = q.shift
      print "\r#{m}"
      # sleep 0.1.seconds
      if m.on?
        least = m
        break
      end
      buttons.each { |b| q << m.press(b) }
    end
    print "\r#{least}"
    puts

    least.presses
  end.sum
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tests = {
  IO::Memory.new("[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}") => 2,
  IO::Memory.new("[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}") => 3,
  IO::Memory.new("[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}") => 2,
}.each do |(input, expectation)|
  result = solve(input)
  unless result == expectation
    STDERR.puts <<-ERROR
      Expected: #{expectation}
        Actual: #{result}
    ERROR

    exit 1
  end
end
puts

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  puts solve(file)
end
