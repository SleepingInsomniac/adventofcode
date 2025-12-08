#!/usr/bin/env ruby

# https://adventofcode.com/2015/day/3

require "stringio"

def solve(input)
  x, y = 0, 0
  houses = {[x, y] => 1}

  until input.eof?
    dir = input.getc
    case dir
    when "^" then y += 1
    when "v" then y -= 1
    when ">" then x += 1
    when "<" then x -= 1
    end

    houses[[x, y]] ||= 0
    houses[[x, y]] += 1
  end

  houses.size
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tests = {
  StringIO.new(">") => 2,
  StringIO.new("^>v<") => 4,
  StringIO.new("^v^v^v^v^v") => 2,
}.each do |(input, expectation)|
  result = solve(input)
  unless result == expectation
    $stderr.puts <<~ERROR
      Expected: #{expectation}
        Actual: #{result}
    ERROR

    exit 1
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
  puts solve(file)
end
