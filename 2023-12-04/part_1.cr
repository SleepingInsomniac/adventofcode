#!/usr/bin/env crystal

require "string_scanner"

class Card
  property card_id : Int32
  property winning_numbers : Array(Int32)
  property card_numbers : Array(Int32)

  def self.parse(string : String) : Card
    winning_numbers = [] of Int32
    card_numbers = [] of Int32

    scanner = StringScanner.new(string)
    scanner.scan(/[^\d]+/)
    card_id = scanner.scan(/\d+/).not_nil!.to_i32
    scanner.scan(/\:\s*/)

    until scanner.scan(/\s*\|\s*/)
      winning_numbers << scanner.scan(/\d+/).not_nil!.to_i32
      scanner.scan(/\s*/)
    end

    until scanner.eos?
      card_numbers << scanner.scan(/\d+/).not_nil!.to_i32
      scanner.scan(/\s*/)
    end

    new(card_id, winning_numbers, card_numbers)
  end

  def initialize(@card_id, @winning_numbers, @card_numbers)
  end

  def numbers_won
    @card_numbers.select do |card_number|
      @winning_numbers.find { |n| n == card_number }
    end
  end

  def score
    1 << numbers_won.size >> 1
  end
end

total_score = 0

File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  while line = file.gets("\n", true)
    total_score += Card.parse(line).score
  end
end

puts total_score
