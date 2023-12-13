#!/usr/bin/env crystal

class Run
  include Iterator(String)

  getter chars : Array(Char)
  @rep = "#.".chars
  @indicies = [] of Int32
  @i = 0_u32
  @limit : UInt32

  def initialize(string)
    @chars = string.chars
    @chars.each_with_index { |c, i| @indicies << i if c == '?' }
    @limit = @rep.size.to_u32 ** @indicies.size.to_u32
  end

  def next
    return stop if @i >= @limit

    @i += 1

    0.upto(@indicies.size - 1) do |i|
      ind = @indicies[i]
      rollover, @chars[ind] = next_char(@chars[ind])

      break if rollover
    end

    @chars.join
  end

  def next_char(char)
    index = @rep.index(char) || -1
    index += 1
    r, index = index.divmod(@rep.size)
    {r != 0, @rep[index]}
  end
end

class Group
  property gears : String
  property counts : Array(Int32)

  def initialize(@gears, @counts)
  end

  def arrangements
    Run.new(@gears).count do |run|
      @counts == run.split(/\.+/).reject(&.blank?).map(&.size)
    end
  end
end

groups = File.read_lines(File.join(__DIR__, "input.txt")).map do |l|
  gears, counts = l.split
  Group.new(gears, counts.split(',').map(&.to_i32))
end

total = groups.reduce(0) do |t, g|
  t + g.arrangements
end

puts total
