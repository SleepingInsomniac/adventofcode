#!/usr/bin/env crystal

class Race
  property time : Int32
  property distance : Int32

  def initialize(@time, @distance)
  end

  def permutations
    (0..@time).map do |n|
      travel_time = @time - n
      {speed: n, time: travel_time, distance: n * travel_time}
    end
  end

  def wins
    permutations.select { |p| p[:distance] > @distance }
  end
end

races = [] of Race

File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  _, *times = file.gets("\n", true).not_nil!.split(/\s+/)
  _, *distances = file.gets("\n", true).not_nil!.split(/\s+/)

  times.map(&.to_i32).zip(distances.map(&.to_i32)).each do |r|
    races << Race.new(r[0], r[1])
  end
end

puts races.map(&.wins.size).reduce(1) { |t, v| t * v }
