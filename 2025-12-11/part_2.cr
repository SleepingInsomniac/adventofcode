#!/usr/bin/env crystal

# https://adventofcode.com/2025/day/11#part2

class Node(T)
  property value : T
  getter parents = [] of Node(T)
  getter children = [] of Node(T)

  def initialize(@value : T)
  end

  def <<(node : Node(T))
    node.parents << self
    @children << node
  end
end

alias Device = Node(String)

def paths(from : Device, to : Device, dac = false, fft = false, memo = {} of Tuple(Device, Bool, Bool) => UInt64)
  dac = true if from.value == "dac"
  fft = true if from.value == "fft"

  return dac && fft ? 1u64 : 0u64 if from == to

  key = {from, dac, fft}
  return memo[key] if memo[key]?

  memo[key] = from.children.sum(0u64) { |c| paths(c, to, dac, fft, memo) }
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def solve(input)
  devices = {} of String => Device

  while line = input.gets(chomp: true)
    label, *outputs = line.strip.split(/\W+/)
    parent = devices[label] ||= Device.new(label)

    outputs.each do |ol|
      child = devices[ol] ||= Device.new(ol)
      parent << child
    end
  end

  paths(from: devices["svr"], to: devices["out"])
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

test_input = IO::Memory.new(<<-TEST_INPUT)
  svr: aaa bbb
  aaa: fft
  fft: ccc
  bbb: tty
  tty: ccc
  ccc: ddd eee
  ddd: hub
  hub: fff
  eee: dac
  dac: fff
  fff: ggg hhh
  ggg: out
  hhh: out
TEST_INPUT

tests = {
  test_input => 2
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
  print "\r\033[0J"
  puts solve(file)
end
