#!/usr/bin/env crystal

time, distance = File.open(File.join(__DIR__, "input.txt"), "r") do |file|
  _, *t = file.gets("\n", true).not_nil!.split(/\s+/)
  _, *d = file.gets("\n", true).not_nil!.split(/\s+/)
  {t.join.to_u64, d.join.to_u64}
end

puts (0_u64..time).reduce(0) { |c, n| n * (time - n) > distance ? c + 1 : c }
