#!/usr/bin/env ruby

# https://adventofcode.com/2015/day/2

def solve(input)
  l, w, h = input.split("x").map(&:to_i)
  side_a = l * w
  side_b = w * h
  side_c = h * l

  2 * side_a + 2 * side_b + 2 * side_c + [side_a, side_b, side_c].min
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tests = {
  "2x3x4" => 58,
  "1x1x10" => 43,
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
