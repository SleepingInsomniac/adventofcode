#!/usr/bin/env crystal

file = {% if flag?(:release) %}
         "input.txt"
       {% else %}
         "test_input.txt"
       {% end %}

def get_chunk(file)
  buffer = [] of Char
  while char = file.read_char
    buffer << char
    break if char == ')'
  end
  buffer.join
end

total = 0

File.open(File.join(__DIR__, file), "r") do |file|
  loop do
    chunk = get_chunk(file)
    break if chunk.empty?
    if match = /mul\((\d+)\,(\d+)\)/.match(chunk)
      total += match[1].to_i * match[2].to_i
    end
  end
end

puts total
