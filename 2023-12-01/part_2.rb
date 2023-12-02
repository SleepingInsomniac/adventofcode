#!/usr/bin/env ruby

sum = 0

DIGITS = %w[
  zero
  one
  two
  three
  four
  five
  six
  seven
  eight
  nine
].freeze

DIGIT_REGEX = /#{DIGITS.join('|')}/i.freeze

def first_digit(string)
  if match = string.match(DIGIT_REGEX)
    index = DIGITS.find_index(match[0].downcase)
    string = string.gsub(match[0], index.to_s)
  end

  string.gsub(/[^\d]+/, '')[0]
end

def last_digit(string)
  match = nil
  match_offset = 0

  # Find the last occurrance of a match
  loop do
    if working_match = string.match(DIGIT_REGEX, match_offset)
      match = working_match
      match_offset = match.offset(0).first + 1
    else
      break unless match # No matches at all

      # Replace with the last found match and exit loop
      index = DIGITS.find_index(match[0].downcase)
      string = string.gsub(match[0], index.to_s)

      break
    end
  end

  string.gsub(/[^\d]+/, '')[-1]
end

File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
  loop do
    break if file.eof?

    line = file.readline.chomp
    next if /^\s*$/.match?(line)

    first = first_digit(line)
    last = last_digit(line)
    value = (first + last).to_i

    sum += value
  end
end

puts sum
