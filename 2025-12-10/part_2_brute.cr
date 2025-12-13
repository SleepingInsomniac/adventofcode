#!/usr/bin/env crystal

# https://adventofcode.com/2025/day/10#part2

struct Mach(T)
  getter values : StaticArray(T, 10)
  getter presses = 0

  def initialize
    @values = StaticArray(T, 10).new(T.new(0))
  end

  def initialize(values : Enumerable(T))
    @values = StaticArray(T, 10).new { |i| values[i]? || 0u16 }
  end

  def initialize(@values, @presses = 0)
  end

  def matches?(other : Mach(T))
    @values == other.values
  end

  def exceeds?(other : Mach(T))
    (0...10).any? { |i| @values[i] > other.values[i] }
  end

  def press(button : Enumerable(UInt8))
    new_values = @values.dup
    button.each { |b| new_values[b] += 1 }
    self.class.new(new_values, @presses + 1)
  end

  def to_s(io)
    @values.each do |v|
      io << v.to_s.rjust(3)
      io << ' '
    end
    io << "-> " << @presses.to_s
  end
end

def parse_joltages(string)
  values = string[/\{[^\}]+\}/][1...-1].split(",").map(&.to_u16)
  Mach(UInt16).new(values)
end

def parse_buttons(string)
  string.scan(/\([^\)]+\)/).map { |b| b[0][1...-1].split(",").map(&.to_u8) }
end

def mem(bytes)
  String.build do |io|
    case bytes
    when ...1024 then io << bytes.to_s << "B"
    when 1024...(1024 ** 2) then io << (bytes // 1024).to_s << "KB"
    when (1024 ** 2)...(1024 ** 3) then io << (bytes // (1024 ** 2)).to_s << "MB"
    else
      io << (bytes // (1024 ** 3)).to_s << "GB"
    end
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def solve(input)
  input.each_line.map do |line|
    buttons = parse_buttons(line)
    target = parse_joltages(line)
    m = Mach(UInt16).new
    q = [m]
    least = m
    puts target
    while m = q.shift
      next if m.exceeds?(target)

      print "\r#{m}"#, " size(q): ", mem(sizeof(Mach(UInt16)) * q.size), "    "

      if m.matches?(target)
        least = m
        break
      end
      buttons.each { |b| q << m.press(b) }
    end
    puts
    puts
    # puts least

    least.presses
  end.sum
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tests = {
  IO::Memory.new("[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}") => 10,
  IO::Memory.new("[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}") => 12,
  IO::Memory.new("[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}") => 11,
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

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  puts solve(file)
end
