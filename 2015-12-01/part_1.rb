#!/usr/bin/env ruby

require "stringio"

def floor(directions, current_floor: 0)
  while char = directions.getc
    case char
    when '(' then current_floor += 1
    when ')' then current_floor -= 1
    end
  end
  current_floor
end

tests = {
  "(())"    => 0,
  "()()"    => 0,
  "((("     => 3,
  "(()(()(" => 3,
  "())"     => -1,
  "))("     => -1,
  ")))"     => -3,
  ")())())" => -3,
}.map do |(directions, expectation)|
  result = floor(StringIO.new(directions))
  [directions, [result == expectation, "Expected #{result} to equal #{expectation}"]]
end.to_h

if tests.values.all? { |v| v[0] }
  File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
    puts floor(file)
  end
else
  $stderr.puts tests
end
