#!/usr/bin/env crystal

require "string_scanner"

struct Draw
  property reds : Int32 = 0
  property greens : Int32 = 0
  property blues : Int32 = 0
end

struct Game
  property id : Int32
  property rounds : Array(Draw)

  def initialize(string : String)
    scanner = StringScanner.new(string)
    scanner.scan(/Game\s*/i)
    @id = scanner.scan(/\d+/).not_nil!.to_i32
    scanner.scan(/\s*:\s*/)

    @rounds = [] of Draw

    loop do
      draw = Draw.new

      loop do
        scanner.scan(/\s*/)
        count = scanner.scan(/\d+/).not_nil!.to_i32
        scanner.scan(/\s*/)

        case scanner.scan(/\w+/)
        when "red"   then draw.reds = count
        when "green" then draw.greens = count
        when "blue"  then draw.blues = count
        else
          raise "Expected a color"
        end

        scanner.scan(/\s*/i)
        break if scanner.eos?
        comma = scanner.scan(/,\s*/)
        semicolon = scanner.scan(/;\s*/)

        break if semicolon
      end

      @rounds.push(draw)

      break if scanner.eos?
    end
  end

  def power
    min_reds = 0
    min_greens = 0
    min_blues = 0

    @rounds.each do |round|
      min_reds = round.reds if min_reds < round.reds
      min_greens = round.greens if min_greens < round.greens
      min_blues = round.blues if min_blues < round.blues
    end

    min_reds * min_greens * min_blues
  end
end

power_sum = 0

File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  while line = file.gets("\n", true)
    power_sum += Game.new(line).power
  end
end

puts power_sum
