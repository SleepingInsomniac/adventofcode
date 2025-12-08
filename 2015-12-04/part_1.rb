#!/usr/bin/env ruby

# https://adventofcode.com/2015/day/4

require "stringio"
require "digest"

def solve(input)
  secret = input.readline(chomp: true)
  solution = 0
  loop do
    hash = Digest::MD5.hexdigest(secret + solution.to_s)
    break if hash.start_with?("00000")
    solution += 1
  end
  solution
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tests = {
  StringIO.new("abcdef") => 609043,
  StringIO.new("pqrstuv") => 1048970,
}.each do |(input, expectation)|
  result = solve(input)
  unless result == expectation
    $stderr.puts <<~ERROR
      Expected: #{expectation}
        Actual: #{result}
    ERROR

    exit 1
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
  puts solve(file)
end
