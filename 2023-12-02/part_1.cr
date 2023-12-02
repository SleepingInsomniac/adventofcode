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

  def possible?(reds : Int32, greens : Int32, blues : Int32)
    @rounds.none? do |draw|
      draw.reds > reds || draw.greens > greens || draw.blues > blues
    end
  end
end

possible_sum = 0

File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  while line = file.gets("\n", true)
    game = Game.new(line)

    if game.possible?(reds: 12, greens: 13, blues: 14)
      possible_sum += game.id
    end
  end
end

puts possible_sum
