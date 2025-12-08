#!/usr/bin/env ruby

# https://adventofcode.com/2015/day/3#part2

require "stringio"

def solve(input)
  houses = {"0,0" => 1}
  actors = [[0, 0], [0, 0]].cycle

  until input.eof?
    a = actors.next

    dir = input.getc
    case dir
    when "^" then a[1] += 1
    when "v" then a[1] -= 1
    when ">" then a[0] += 1
    when "<" then a[0] -= 1
    end

    k = a.join(',')
    houses[k] ||= 0
    houses[k] += 1
  end

  houses.size
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tests = {
  StringIO.new("^v") => 3,
  StringIO.new("^>v<") => 3,
  StringIO.new("^v^v^v^v^v") => 11,
}.each do |(input, expectation)|
  result = solve(input)
  unless result == expectation
    $stderr.puts <<~ERROR
         Input: #{input.string}
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
