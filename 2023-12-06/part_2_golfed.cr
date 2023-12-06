#!/usr/bin/env crystal

time, distance = File.read_lines(File.join(__DIR__, "input.txt")).map { |l| l.split[1..].join.to_u64 }
puts (0_u64..time).count { |n| n * (time - n) > distance }
