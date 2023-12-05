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

class Almanac
  property mappings = [] of Mapping(Int64)

  def map(number : Int64) : Int64
    @mappings.reduce(number) { |number, mapping| mapping.map(number) }
  end
end

almanac = Almanac.new
seeds = [] of Int64

File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  line = file.gets("\n", true).not_nil!
  seeds = line[7..].split(/\s+/).map(&.to_i64).not_nil!
  file.gets("\n", true)

  while line = file.gets("\n", true)
    _, source, destination = /(\w+)-to-(\w+)/i.match(line).not_nil!.to_a.map(&.not_nil!)

    mapping = Mapping(Int64).new(source, destination)
    almanac.mappings << mapping

    while line = file.gets("\n", true)
      break if /\A\s*\z/ =~ line

      dest_start, src_start, length = line.split(/\s+/).map(&.to_i64)
      mapping.add_range(dest_start, src_start, length)
    end
  end
end

min = Int64::MAX

seed_ranges = seeds.each_slice(2)
  .map { |slice| slice[0]...(slice[0] + slice[1]) }
  .to_a
  .sort { |a, b| a.begin <=> b.begin }
  .each do |seed_range|
    puts seed_range.inspect

    seed_range.each do |seed|
      value = almanac.map(seed)

      min = value if value < min
    end
  end

puts min
