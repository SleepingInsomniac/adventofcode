#!/usr/bin/env crystal

# https://adventofcode.com/2025/day/11

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def solve(input)
  devices = {} of String => Array(String)

  while line = input.gets(chomp: true)
    outputs = line.strip.split(/\W+/)
    label = outputs.shift
    devices[label] = outputs
  end

  q = [{"you", Set(String).new}]
  paths = 0

  while item = q.shift?
    label, visited = item

    if label == "out"
      paths += 1
    else
      devices[label].each do |output|
        v = visited.dup
        if v.add?(output)
          q << {output, v}
        end
      end
    end
  end

  paths
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

test_input = IO::Memory.new(<<-TEST_INPUT)
  aaa: you hhh
  you: bbb ccc
  bbb: ddd eee
  ccc: ddd eee fff
  ddd: ggg
  eee: out
  fff: out
  ggg: out
  hhh: ccc fff iii
  iii: out
TEST_INPUT

tests = {
  test_input => 5
}.each do |(input, expectation)|
  result = solve(input)
  unless result == expectation
    STDERR.puts <<-ERROR
      Expected: #{expectation}
        Actual: #{result}
    ERROR

    exit 1
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  puts solve(file)
end
