#!/usr/bin/env crystal

struct Platform
  property width : Int32
  property height : Int32
  property field : Array(Char)

  def initialize(@width, @height)
    @field = Array(Char).new(@width * @height) { '.' }
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

  def draw
    0.upto(@height - 1) do |y|
      0.upto(@width - 1) do |x|
        if cell = self[x, y]
          print cell.to_s
        else
          print '.'
        end
      end
      puts
    end
  end

  def tilt(direction)
    case direction
    when :north
      0.upto(@height - 1) do |y|
        0.upto(@width - 1) do |x|
          roll(x, y, 0, -1) if self[x, y] == 'O'
        end
      end
    when :east
      (@width - 1).downto(0) do |x|
        0.upto(@height - 1) do |y|
          roll(x, y, 1, 0) if self[x, y] == 'O'
        end
      end
    when :south
      (@height - 1).downto(0) do |y|
        0.upto(@width - 1) do |x|
          roll(x, y, 0, 1) if self[x, y] == 'O'
        end
      end
    when :west
      0.upto(@width - 1) do |x|
        0.upto(@height - 1) do |y|
          roll(x, y, -1, 0) if self[x, y] == 'O'
        end
      end
    end
  end

  def roll(x, y, dx, dy)
    loop do
      nx = x + dx
      ny = y + dy

      break if nx < 0 || nx >= @width || ny < 0 || ny >= @height || self[nx, ny] != '.'

      boulder = self[x, y]
      self[x, y] = '.'
      x, y = nx, ny
      self[x, y] = boulder
    end
  end

  def load
    load = 0

    0.upto(@height - 1) do |y|
      0.upto(@width - 1) do |x|
        if self[x, y] == 'O'
          load += (@height - y)
        end
      end
    end

    load
  end
end

platform = Platform.new(100, 100)

File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  y = 0
  while line = file.gets("\n", true)
    line.chars.each_with_index do |char, x|
      platform[x, y] = char
    end

    y += 1
  end
end

start_time = Time.monotonic
elapsed_time = Time::Span.new
remaining_time = Time::Span.new

# This will take a long time... I cheesed it and got the right answer at 1000 cycles
#   Otherwise without a more tailored solution, this will take ~3.5 days on my CPU
1000000000.times do |n|
  platform.tilt(:north)
  platform.tilt(:west)
  platform.tilt(:south)
  platform.tilt(:east)

  if n % 100 == 0 && n != 0
    print "\r#{n}/1000000000 #{((n / 1000000000) * 100).round(2)}% " \
          "elapsed: #{elapsed_time.days} days #{elapsed_time.hours} hours #{elapsed_time.minutes} minutes, " \
          "remaining: #{remaining_time.days} days #{remaining_time.hours} hours #{remaining_time.minutes} minutes"
    elapsed_time = Time.monotonic - start_time
    estimated_total_time = elapsed_time / n * 1000000000
    remaining_time = estimated_total_time - elapsed_time
  end
end

puts
platform.draw
puts platform.load
