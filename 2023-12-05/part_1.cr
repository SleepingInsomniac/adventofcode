#!/usr/bin/env crystal

class Mapping(T)
  property src : String
  property dest : String
  @ranges = [] of Tuple(Range(T, T), Range(T, T))

  def initialize(@src, @dest)
  end

  def add_range(dest_start : T, src_start : T, length : T)
    @ranges << {
      (src_start...(src_start + length)),
      (dest_start...(dest_start + length)),
    }
  end

  def map(number : T) : T
    if range = @ranges.find { |(s, _)| s.covers?(number) }
      src_range, dest_range = range
      dest_range.begin + (number - src_range.begin)
    else
      number
    end
  end
end

almanac = [] of Mapping(Int64)
seeds = [] of Int64

File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  line = file.gets("\n", true).not_nil!
  seeds = line[7..].split(/\s+/).map(&.to_i64)
  file.gets("\n", true)

  while line = file.gets("\n", true)
    _, source, destination = /(\w+)-to-(\w+)/i.match(line).not_nil!.to_a.map(&.not_nil!)

    mapping = Mapping(Int64).new(source, destination)
    almanac << mapping

    while line = file.gets("\n", true)
      break if /\A\s*\z/ =~ line

      dest_start, src_start, length = line.split(/\s+/).map(&.to_i64)
      mapping.add_range(dest_start, src_start, length)
    end
  end
end

locations = seeds.map do |seed|
  almanac.reduce(seed) { |seed, mapping| mapping.map(seed) }
end

puts locations.min
