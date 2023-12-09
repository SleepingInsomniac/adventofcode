#!/usr/bin/env ruby

class Sequence
  attr_reader :numbers

  def initialize(numbers) = @numbers = numbers
  def extrapolate = Sequence.new(@numbers.each_cons(2).map { |a, b| b - a })
  def zeros? = @numbers.all?(&:zero?)
  def predict = zeros? ? 0 : @numbers.last + extrapolate.predict
  def pre_predict = zeros? ? 0 : @numbers.first - extrapolate.pre_predict
end

sequences = File.readlines(File.join(__dir__, 'input.txt')).map do |l|
  Sequence.new(l.split.map(&:to_i))
end

puts sequences.map(&:pre_predict).reduce(&:+)
