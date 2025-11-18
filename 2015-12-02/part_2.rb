#!/usr/bin/env ruby

# https://adventofcode.com/2015/day/2#part2

def solve(input)
  l, w, h = input.split("x").map(&:to_i)

  d1, d2 = [l, w, h].sort[0..1]
  bow = l * w * h

  2 * d1 + 2 * d2 + bow
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tests = {
  "2x3x4" => 34,
  "1x1x10" => 14,
}.map do |(input, expectation)|
  result = solve(input)
  [input, [result == expectation, "Expected #{result} to equal #{expectation}"]]
end.to_h

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if tests.values.all? { |v| v[0] }
  File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
    total = 0
    while line = file.readline.chomp
      total += solve(line)
    end
  rescue EOFError
  ensure
    puts total
  end
else
  $stderr.puts tests
end
