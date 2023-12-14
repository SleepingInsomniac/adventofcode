#!/usr/bin/env crystal

class Run(T)
  include Iterator(T)

  getter string : String
  @on_bits : T = T.new(0)
  @off_bits : T = T.new(0)
  @current : T = T.new(0)
  @mask : T = T.new(0)

  def initialize(@string)
    @string.chars.each_with_index do |char, index|
      @on_bits |= (T.new(1) << (@string.size - index) >> 1) if char == '#'
      @off_bits |= (T.new(1) << (@string.size - index) >> 1) unless char == '.'
    end

    @mask = (T.new(1) << @string.size) - 1
    @current = @on_bits
  end

  def next
    c = @current
    if @current > @off_bits
      stop
    else
      @current += 1

      while (@current & @off_bits) != @current
        t = @current & ~@off_bits
        break if t == 0

        lowest_off_bit = t & (~t + 1_u128)
        @current += lowest_off_bit

        break if @current > @off_bits

        @current |= @on_bits
      end

      @current |= @on_bits
      c
    end
  end

  def count_groups(num, groups : Array(UInt8)) : Array(UInt8)
    s_index = groups.size - 1
    counts = [] of UInt8
    count = 0u8
    @string.size.times do
      if (num & 1) == 1
        count += 1
      elsif count > 0
        break if count != groups[s_index]?
        counts.unshift(count)
        s_index -= 1
        count = 0u8
      end
      break if num == 0
      num >>= 1
    end
    counts.unshift(count) unless count == 0
    counts
  end
end

class Group
  property gears : String
  property counts : Array(UInt8)

  def initialize(@gears, @counts)
  end

  def repetitions
  end

  def arrangements
    @gears.split('.').reverse.each do |part|
      puts
      puts "#{part} : #{@counts}"
      puts "----------------------"
      count = 0_u64
      run = Run(UInt128).new(part)
      matched_size = 0
      run.each do |num|
        print "\r\e[2K#{num.to_s(2).rjust(part.size, '0')}"
        print " : "
        counted = run.count_groups(num, @counts)
        print counted

        if @counts[-counted.size..-1] == counted
          matched_size = counted.size
          #
          # while counted.pop? == @counts.last
          #   @counts.pop
          count += 1
          print " ✔︎ #{matched_size}"
        end

        puts
        # if counted == @counts
        #   count += 1
        #   puts "✔︎"
        # else
        #   puts
        # end
      end
      matched_size.times { @counts.pop }

      puts "\e[2K  => #{count}"
      count
    end
  end

  # def arrangements
  #   puts
  #   puts "#{@gears} : #{@counts}"
  #   puts "----------------------"
  #   count = 0_u64
  #   run = Run(UInt128).new(@gears)
  #   run.each do |num|
  #     print "\r\e[2K#{num.to_s(2).rjust(@gears.size, '0')}"
  #     print " : "
  #     counted = run.count_groups(num, @counts)
  #     print counted
  #     if counted == @counts
  #       count += 1
  #       puts "✔︎"
  #     end
  #   end
  #   puts "\e[2K  => #{count}"
  #   count
  # end
end

STDOUT.sync = true

max_size = 0
groups = [] of Group
File.read_lines(File.join(__DIR__, "test_input.txt")).map do |l|
  gears, counts = l.split
  gears = Array.new(5) { gears }.join('?')
  counts = Array.new(5) { counts }.join(',')

  gears = gears.gsub(/\.+/, '.').gsub(/(^\.+|\.+$)/, "")
  max_size = gears.size if gears.size > max_size

  groups << Group.new(gears, counts.split(',').map(&.to_u8))
end

pp groups[0].arrangements

# t = 0_u64
# groups.each do |g|
#   t += g.arrangements
# end
# puts
# puts "Answer: #{t}"
