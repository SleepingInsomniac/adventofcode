#!/usr/bin/env crystal

require "set"

enum Pulse
  Low
  High

  def flip
    low? ? High : Low
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

abstract class Mod
  getter name : String

  abstract def state
  abstract def recv(pulse : Pulse, sender : Mod, queue : Array(Tuple(Mod, Mod)))

  property inputs = Set(Mod).new
  property outputs = Set(Mod).new

  def initialize(@name)
  end

  # Sender, Pulse, Receiver
  def propagate(queue = [] of Tuple(Mod, Pulse, Mod))
    @outputs.each { |output| queue.unshift({self, state, output}) }
    queue
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class Broadcaster < Mod
  getter state = Pulse::Low

  def recv(pulse, sender, queue)
    @state = pulse
    propagate(queue)
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class FlipFlop < Mod
  getter state = Pulse::Low

  def recv(pulse, sender, queue)
    if pulse.low?
      @state = @state.flip
      propagate(queue)
    end
  end

  def name
    '%' + super
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class Conjunction < Mod
  getter states = {} of Mod => Pulse

  def inputs=(value)
    value.each { |mod| @states[mod] = Pulse::Low }
  end

  def state
    @states.values.all?(&.high?) ? Pulse::Low : Pulse::High
  end

  def recv(pulse, sender, queue)
    @states[sender] = pulse
    propagate(queue)
  end

  def name
    '&' + super
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class Entry
  property name : String
  property kind : Char
  property inputs : Array(String)
  property outputs : Array(String)

  def initialize(@name, @kind, @inputs, @outputs)
  end
end

input = {} of String => Entry

file = {% if flag?(:release) %} "input.txt" {% else %} "test_input2.txt" {% end %}

File.read_lines(File.join(__DIR__, file)).map(&.chomp).each do |line|
  name, dests = line.split(/\s*\-\>\s*/i)
  kind, name = name[0], name[/\w+/]
  outputs = dests.split(/\,\s*/)

  input[name] ||= Entry.new(name, kind, [] of String, outputs)
  input[name].kind = kind
  input[name].outputs = outputs

  outputs.each do |output|
    input[output] ||= Entry.new(output, '.', [] of String, [] of String)
    input[output].inputs << name
  end
end

modules = {} of String => Mod

input.each do |name, entry|
  modules[name] = case entry.kind
                  when '%' then FlipFlop.new(entry.name)
                  when '&' then Conjunction.new(entry.name)
                  else          Broadcaster.new(entry.name)
                  end
end

input.each do |name, entry|
  modules[name].inputs = Set.new(entry.inputs.map { |n| modules[n] })
  modules[name].outputs = Set.new(entry.outputs.map { |n| modules[n] })
end

button = Broadcaster.new("button")
button.outputs << modules["broadcaster"]

queue = [] of Tuple(Mod, Pulse, Mod)

highs = 0
lows = 0

1000.times do
  button.propagate(queue)

  while op = queue.pop?
    sender, pulse, receiever = op
    pulse.low? ? (lows += 1) : (highs += 1)
    # puts "#{sender.name.rjust(11)} --#{pulse.to_s.ljust(4, '-')}-> #{receiever.name}"
    receiever.recv(pulse, sender, queue)
  end
  # puts
end

puts "lows: #{lows} * highs: #{highs} = #{lows * highs}"
