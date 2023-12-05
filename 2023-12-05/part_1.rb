#!/usr/bin/env ruby

class Mapping
  attr_reader :src, :dest

  def initialize(src, dest)
    @src, @dest = [src, dest].map(&:to_sym)
    @ranges = []
  end

  def add_range(dest_start, src_start, length)
    @ranges << [
      (src_start...(src_start + length)),
      (dest_start...(dest_start + length)),
    ]
  end

  def map(number)
    if range = @ranges.find { |(s, _)| s.cover?(number) }
      src_range, dest_range = range
      dest_range.begin + (number - src_range.begin)
    else
      number
    end
  end
end

almanac = []
seeds = []

File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
  line = file.readline.chomp
  seeds = line[7..].split(/\s+/).map(&:to_i)
  file.readline

  until file.eof?
    line = file.readline.chomp
    _, source, destination = /(\w+)-to-(\w+)/i.match(line).to_a

    mapping = Mapping.new(source, destination)
    almanac << mapping

    loop do
      line = file.readline.chomp
      break if /\A\s*\z/.match?(line) || file.eof?

      dest_start, src_start, length = line.split(/\s+/).map(&:to_i)
      mapping.add_range(dest_start, src_start, length)
    end
  end
end

locations = seeds.map do |seed|
  almanac.reduce(seed) { |seed, mapping| mapping.map(seed) }
end

puts locations.min
