#!/usr/bin/env ruby

class Hand
  VALUES = %w[A K Q T 9 8 7 6 5 4 3 2 J].each_with_index.to_h
  PRECEDENCE = %i[
    five_of_a_kind four_of_a_kind full_house three_of_a_kind two_pair one_pair high_card
  ].each_with_index.to_h

  attr_reader :cards, :bid

  def initialize(cards, bid)
    @cards, @bid = cards.chars, bid.to_i
  end

  def counts      = @counts ||= @cards.tally.except('J').values.sort
  def card_values = @card_values ||= cards.map { |c| VALUES[c] }
  def set?(*sets) = sets.any? { |s| counts == s }

  def hand_type
    @hand_type ||= case
    when set?([5], [4], [3], [2], [1], [])     then :five_of_a_kind
    when set?([1, 4], [1, 3], [1, 2], [1, 1])  then :four_of_a_kind
    when set?([2, 3], [2, 2])                  then :full_house
    when set?([1, 1, 3], [1, 1, 2], [1, 1, 1]) then :three_of_a_kind
    when set?([2, 2], [1, 2, 2])               then :two_pair
    when set?([1, 1, 1, 2], [1, 1, 1, 1])      then :one_pair
    when set?([1, 1, 1, 1, 1])                 then :high_card
    end
  end

  def <=>(other)
    comparison = PRECEDENCE[other.hand_type] <=> PRECEDENCE[hand_type]
    return comparison unless comparison.zero?

    card_values.lazy.zip(other.card_values).map { |a, b| b <=> a }.find { |n| !n.zero? }
  end
end

hands = File.readlines(File.join(__dir__, 'input.txt')).map { |l| Hand.new(*l.chomp.split) }
score = 0
hands.sort.each.with_index(1) { |hand, rank| score += hand.bid * rank }
puts score
