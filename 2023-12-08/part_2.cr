#!/usr/bin/env crystal

class Map
  property directions = Array(Char).new
  property nodes = {} of String => Node
  property entry : Node?

  def starting_nodes
    @nodes.values.select(&.starting_node?)
  end

  def steps
    starting_nodes.map(&.steps(@directions)).reduce { |lcm, count| lcm.lcm(count) }
  end
end

class Node
  property name : String
  property left : Node?
  property right : Node?

  def initialize(@name, @left = nil, @right = nil)
  end

  def starting_node?
    @name[-1] == 'A'
  end

  def ending_node?
    @name[-1] == 'Z'
  end

  def follow(direction) : Node
    direction == 'L' ? left.not_nil! : right.not_nil!
  end

  def steps(directions)
    steps = 0_u64
    curr = self
    iterator = directions.cycle
    until curr.ending_node?
      steps += 1
      curr = curr.follow(iterator.next)
    end
    steps
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

puts map.steps
