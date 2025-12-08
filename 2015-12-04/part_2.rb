#!/usr/bin/env ruby

# https://adventofcode.com/2015/day/4#part2

require "stringio"
require "digest"

def solve(input)
  secret = input.readline(chomp: true)
  solution = 0
  loop do
    hash = Digest::MD5.hexdigest(secret + solution.to_s)
    break if hash.start_with?("000000")
    solution += 1
  end
  solution
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
  puts solve(file)
end
