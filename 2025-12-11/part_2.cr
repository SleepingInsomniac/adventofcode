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

alias Dev = Node(String)

def paths(from : Dev, to : Dev, path = [] of Dev, results = [] of Array(Dev), including = [] of Dev)
  path << from

  if from == to
    print "\r", path.map(&.value).join(" -> ")
    if including.all? { |n| path.includes?(n) }
      puts
      results << path.dup
    end
  else
    from.children.each do |child|
      paths(child, to, path, results, including) unless path.includes?(child)
    end
  end

  path.pop
  results
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def solve(input)
  devices = {} of String => Node(String)

  while line = input.gets(chomp: true)
    outputs = line.strip.split(/\W+/)
    label = outputs.shift

    devices[label] = Node.new(label)
  end

  devices["out"] = Node.new("out")
  input.rewind

  while line = input.gets(chomp: true)
    outputs = line.strip.split(/\W+/)
    label = outputs.shift
    outputs.each do |ol|
      devices[label] << devices[ol]
    end
  end

  # devices.each do |_, dev|
  #   puts "#{dev.parents.map(&.value).join(", ")} <- (#{dev.value}) -> #{dev.children.map(&.value).join(", ")}"
  # end

  paths(from: devices["svr"], to: devices["out"], including: [devices["dac"], devices["fft"]]).size
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
