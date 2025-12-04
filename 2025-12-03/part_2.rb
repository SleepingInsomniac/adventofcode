#!/usr/bin/env ruby

# https://adventofcode.com/2025/day/3#part2

require "colorize"

class Bank
  def initialize(values, count)
    @values = values.chars.map(&:to_i)
    @pointers = ((@values.size - count)...@values.size).to_a
  end

  def count = @pointers.size
  def pointer_value(i) = @values[@pointers[i]]
  def bank_value(i) = @values[i]

  def maximize
    limit = 0
    bi = @values.size - count - 1
    pi = 0

    loop do
      break if pi >= count

      limit = (pi == 0 ? 0 : @pointers[pi - 1] + 1)

      bi.downto(limit) do |i|
        puts activated({limit => "|", i => "v"}, {@pointers[pi] => "^"})

        if bank_value(i) >= pointer_value(pi)
          @pointers[pi] = i
        end
        print "\e[4A\r"
      end

      pi += 1
      bi += 1
    end

    puts activated
    self
  end

  def joltage = @pointers.map.with_index { |p, i| @values[p] * (10 ** (count - i - 1)) }.sum

  def activated(tps = {}, bps = {})
    v_string = @values.map(&:to_s)
    p_string = Array.new(@values.size) { " " }
    v_arrows = " " * @values.size
    tps.each { |i,s| v_arrows[i] = s }
    p_arrows = " " * @values.size
    bps.each { |i,s| p_arrows[i] = s }

    @pointers.each do |p|
      v_string[p] = v_string[p].colorize(:red)
      p_string[p] = @values[p].to_s
    end

    [
      v_arrows,
      v_string.join,
      p_string.join,
      p_arrows
    ].join("\n")
  end
end

def solve(input)
  total = 0
  until input.eof?
    total += Bank.new(input.gets.chomp, 12).maximize.joltage
    puts total
    print "\e[5A\r"
  end
  total
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tests = {
  "789876543111111" => 987654311111,
  "999999999999111" => 999999999999,
  "123412341234123" => 412341234123,
  "987654321111111" => 987654321111,
  "811111111111119" => 811111111119,
  "234234234234278" => 434234234278,
  "818181911112111" => 888911112111,
}.map do |(input, expectation)|
  result = Bank.new(input, 12).maximize.joltage
  unless result == expectation
    $stderr.puts <<~ERR
      Expected: #{expectation}
        Actual: #{result}
    ERR
    exit 1
  end
  [input, [result == expectation, "Expected #{result} to equal #{expectation}"]]
end.to_h

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if tests.values.all? { |v| v[0] }
  File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
    puts solve(file)
  end
else
  $stderr.puts tests
end
