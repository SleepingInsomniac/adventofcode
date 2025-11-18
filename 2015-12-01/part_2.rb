#!/usr/bin/env ruby

require "stringio"

def basement(directions, current_floor: 0)
  instruction_num = 0
  while char = directions.getc
    instruction_num += 1
    case char
    when '(' then current_floor += 1
    when ')' then current_floor -= 1
    end
    break if current_floor < 0
  end
  instruction_num
end

tests = {
  ")"     => 1,
  "()())" => 5,
}.map do |(directions, expectation)|
  result = basement(StringIO.new(directions))
  [directions, [result == expectation, "Expected #{result} to equal #{expectation}"]]
end.to_h

if tests.values.all? { |v| v[0] }
  File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
    puts basement(file)
  end
else
  $stderr.puts tests
end
