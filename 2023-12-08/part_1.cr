#!/usr/bin/env crystal

class Map
  property directions = Array(Char).new
  property nodes = {} of String => Node
  property entry : Node?

  def steps(start : Node, fin : Node)
    curr = start
    iterator = directions.cycle
    steps = 0
    while curr.name != fin.name
      steps += 1
      direction = iterator.next
      puts "At: #{curr.inspect}, going #{direction}"
      curr = direction == 'L' ? curr.left.not_nil! : curr.right.not_nil!
    end
    steps
  end
end

class Node
  property name : String
  property left : Node?
  property right : Node?

  def initialize(@name, @left = nil, @right = nil)
  end

  def inspect
    "#{@name} (#{@left.try(&.name)}, #{@right.try(&.name)})"
  end
end

map = Map.new

File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  map.directions = file.gets("\n", true).not_nil!.chars

  file.gets("\n", true)

  while line = file.gets("\n", true)
    name, left, right = line.split(/\W+/)

    map.nodes[name] ||= Node.new(name)
    map.nodes[left] ||= Node.new(left)
    map.nodes[right] ||= Node.new(right)

    map.nodes[name].left = map.nodes[left]
    map.nodes[name].right = map.nodes[right]
  end
end

puts map.steps(map.nodes["AAA"], map.nodes["ZZZ"])
