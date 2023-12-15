#!/usr/bin/env ruby

sequence = File.read(File.join(__dir__, 'input.txt')).chomp
  .split(',')
  .map { |s| s.split(/(=|-)/) }
  .map { |s| s[2] = s[2].to_i if s[2]; s }

class Hashmap
  def initialize = @boxes = Array.new(256) { {} }
  def hash_value(string) = string.chars.reduce(0) { |v, c| ((v + c.ord) * 17) % 256 }
  def to_s
    @boxes.map.with_index do |b, i|
      b.compact.empty? ? nil : "Box #{i}: #{b.map { |k, v| "[#{k} #{v}]" }.join(' ')}"
    end.compact.join("\n")
  end

  def perform(key, op, value = nil)
    case op
    when '=' then @boxes[hash_value(key)][key] = value
    when '-' then @boxes[hash_value(key)].delete(key)
    end
  end

  def focusing_power
    @boxes.map.with_index(1) { |b, i| b.values.map.with_index(1) { |v, bi| v * i * bi } }
      .flatten.reduce(0) { |total, v| total + v }
  end
end

h = Hashmap.new

sequence.each do |instruction|
  h.perform(*instruction)
end

puts h.to_s
puts h.focusing_power
