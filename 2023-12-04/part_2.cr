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

  getter numbers_won : Array(Int32) do
    @card_numbers.select do |card_number|
      @winning_numbers.find { |n| n == card_number }
    end
  end

  def score
    1 << numbers_won.size >> 1
  end
end

cards = [] of Card
counts = [] of Int32

File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  while line = file.gets("\n", true)
    cards << Card.parse(line)
    counts << 1
  end
end

while card = cards.shift?
  counts[card.card_id - 1].times do
    card.numbers_won.each_with_index(1) do |_, index|
      counts[card.card_id + index - 1] += 1
    end
  end
end

puts counts.sum
