#!/usr/bin/env ruby

class Hand
  VALUES = {
    'A' => 14,
    'K' => 13,
    'Q' => 12,
    'J' => 11,
    'T' => 10,
    '9' => 9,
    '8' => 8,
    '7' => 7,
    '6' => 6,
    '5' => 5,
    '4' => 4,
    '3' => 3,
    '2' => 2
  }

  PRECEDENCE = %i[
    five_of_a_kind
    four_of_a_kind
    full_house
    three_of_a_kind
    two_pair
    one_pair
    high_card
  ].each_with_index.to_h

  attr_reader :cards, :bid

  def initialize(cards, bid)
    @cards = cards
    @bid = bid
  end

  def hand_type
    @hand_type ||= case
    when @cards.all? { |c| c == @cards.first }    then :five_of_a_kind
    when @cards.tally.values.any? { |c| c == 4 }  then :four_of_a_kind
    when @cards.tally.values.sort == [2, 3]       then :full_house
    when @cards.tally.values.sort == [1, 1, 3]    then :three_of_a_kind
    when @cards.tally.values.sort == [1, 2, 2]    then :two_pair
    when @cards.tally.values.sort == [1, 1, 1, 2] then :one_pair
    when @cards.tally.values == [1, 1, 1, 1, 1]   then :high_card
    end
  end

  def card_values
    @card_values ||= cards.map { |c| VALUES[c] }
  end

  def <=>(other)
    comparison = PRECEDENCE[other.hand_type] <=> PRECEDENCE[hand_type]
    return comparison unless comparison.zero?

    card_values.each_with_index do |v, i|
      comparison = v <=> other.card_values[i]
      break unless comparison.zero?
    end

    comparison
  end
end

hands = []

File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
  until file.eof?
    cards, bid = file.readline.chomp.split
    hands << Hand.new(cards.split(''), bid.to_i)
  end
end

score = 0
hands.sort.each.with_index(1) do |hand, rank|
  score += hand.bid * rank
end

puts score
