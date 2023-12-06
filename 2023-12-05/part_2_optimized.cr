#!/usr/bin/env crystal

class Mapping(T)
  property src : String
  property dest : String
  @ranges = [] of NamedTuple(src: Range(T, T), dst: Range(T, T))

  def initialize(@src, @dest)
  end

  def add_range(dest_start : T, src_start : T, length : T)
    @ranges << {
      src: (src_start...(src_start + length)),
      dst: (dest_start...(dest_start + length)),
    }
  end

  def map_range(range)
    # puts "\nMapping: #{@src} to #{@dest}"

    matched = [] of Range(T, T)
    unmatched = [range]

    @ranges.each do |map|
      # puts "  Map #{map[:src]} to #{map[:dst]}"
      # puts "  (considering #{unmatched})"
      splits = [] of Range(T, T)

      unmatched.size.times do
        unmatched.concat(split_range(unmatched.shift, map[:src]))
      end

      unmatched.size.times do
        ur = unmatched.shift

        if ur.begin >= map[:src].begin && ur.end <= map[:src].end
          dist = map[:dst].begin - map[:src].begin
          mapped = ((ur.begin + dist)..(ur.end + dist))
          # puts "  Match: #{ur} with #{map[:src]} => #{mapped}"
          matched << mapped
        else
          # puts "  Unmatched: #{ur} with #{map[:src]}"
          unmatched << ur
        end
      end
    end

    # puts "  -> Matched: #{matched}, Unmatched: #{unmatched}\n"

    [*matched, *unmatched]
  end

  def split_range(range : Range(T, T), source : Range(T, T))
    # print "     Split: #{range} by #{source}: "

    if range.end < source.begin || range.begin > source.end
      # print "(No overlap) "
      return {range} # .tap { |r| puts r }
    end

    if range.begin >= source.begin && range.end <= source.end
      # print "(Contained) "
      return {(range.begin..range.end)} # .tap { |r| puts r }
    end

    if range.begin < source.begin && range.end > source.end
      # print "(Full overlap) "
      return {
        (range.begin...source.begin),
        source,
        ((source.end + 1)..range.end),
      } # .tap { |r| puts r }
    end

    if range.begin < source.begin && range.end <= source.end
      # print "(Left overlap) "
      return {
        (range.begin...source.begin),
        (source.begin..range.end),
      } # .tap { |r| puts r }
    end

    if range.begin > source.begin && range.end > source.end
      # print "(Right overlap) "
      return {
        (range.begin..source.end),
        ((source.end + 1)..range.end),
      } # .tap { |r| puts r }
    end

    return {range} # All cases covered, this is for the type engine
  end
end

class Almanac(T)
  property mappings = [] of Mapping(T)

  def map_seeds(range : Range(T, T))
    output = [range] of Range(T, T)

    @mappings.each do |mapping|
      output.size.times do
        r = output.shift
        output.concat(mapping.map_range(r))
      end
    end

    output
  end
end

almanac = Almanac(Int64).new
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

location = seeds.each_slice(2)
  .map { |slice| slice[0]...(slice[0] + slice[1]) }
  .map { |range| almanac.map_seeds(range).map(&.begin) }
  .flatten
  .min

puts location
