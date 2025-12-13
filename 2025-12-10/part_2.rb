#!/usr/bin/env ruby

# https://adventofcode.com/2025/day/10

require "stringio"
require 'rulp'
ENV['SOLVER'] = 'cbc'
Rulp.log_level = Logger::WARN

def parse_joltages(string)
  string[/\{[^\}]+\}/][1...-1].split(",").map(&:to_i)
end

def parse_buttons(string)
  string.scan(/\([^\)]+\)/).map { |b| b[1...-1].split(",").map(&:to_i) }
end

def solve(input)
  input.each_line.map do |line|
    buttons = parse_buttons(line)
    target = parse_joltages(line)

    button_vars = buttons.map.with_index { |b, i| [b, B_i(i)] }.to_h
    problem = Rulp::Min(button_vars.values.reduce(:+))

    target.each.with_index do |t, i|
      jvalues = button_vars.values_at(*buttons.select { |b| b.include?(i) })
      problem[jvalues.reduce(:+) == t]
    end

    problem.solve
    button_vars.values.map(&:value).sum.to_i
  end.sum
end

# Tests ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

tests = {
  StringIO.new("[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}") => 10,
  StringIO.new("[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}") => 12,
  StringIO.new("[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}") => 11,
}.each do |(input, expectation)|
  result = solve(input)
  unless result == expectation
    STDERR.puts <<~ERROR
      Expected: #{expectation}
        Actual: #{result}
    ERROR

    exit 1
  end
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

File.open(File.join(__dir__, "input.txt"), "r") do |file|
  puts solve(file)
end
