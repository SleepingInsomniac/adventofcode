#!/usr/bin/env crystal

class Race(T)
  property time : T
  property distance : T

  def initialize(@time, @distance)
  end

  def wins
    count = 0

    (0_u128..@time).each do |n|
      travel_time = @time - n
      travel_distance = n * travel_time
      count += 1 if travel_distance > @distance
    end

    count
  end
end

race = File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  _, *time = file.gets("\n", true).not_nil!.split(/\s+/)
  _, *distance = file.gets("\n", true).not_nil!.split(/\s+/)

  Race(UInt128).new(time.join.to_u128, distance.join.to_u128)
end

puts race.wins
