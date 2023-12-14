#!/usr/bin/env ruby

class RefSearch
  attr_accessor :string, :ptr, :side

  def initialize(string)
    @string = string
    @ptr = @ptr_left = @ptr_right = @string.size / 2
    @ptr_right += 1
    @side = :left
  end

  def next
    if @side == :left
      @side = :right
      @ptr_left -= 1
      @ptr = @ptr_right
    else
      @side = :left
      @ptr_right += 1
      @ptr = @ptr_left
    end
  end

  def reflects?(line = @string)
    if @side == :left
      left, right = line[0...@ptr], line[@ptr..(@ptr + @ptr - 1)]
    else
      left, right = line[(@ptr - (line.size - @ptr))...@ptr], line[@ptr..]
    end

    left == right.reverse
  end

  def finished?
    @ptr_left == 0 && @ptr_right == (@string.size - 1)
  end
end

class Pattern
  attr_accessor :lines

  def initialize(lines)
    @lines = lines
    @search = RefSearch.new(@lines.first)
  end

  def rotated
    Pattern.new(@lines.map(&:chars).transpose.reverse.map(&:join))
  end

  def reflects?
    loop do
      until @search.reflects? || @search.finished?
        @search.next
      end

      if @lines.all? { |l| @search.reflects?(l) }
        break @search.ptr
      end

      break false if @search.finished?

      @search.next
    end
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

patterns = []

File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
  loop do
    lines = []

    until file.eof?
      line = file.readline&.chomp
      break if line.empty?
      lines << line
    end

    patterns << Pattern.new(lines)

    break if file.eof?
  end
end


total = patterns.reduce(0) do |t, pat|
  if value = pat.reflects?
    t += value
  end

  pat_rot = pat.rotated

  if value = pat_rot.reflects?
    t += (value * 100)
  end

  t
end

puts total
