#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source "https://rubygems.org"

  gem 'http'
  gem 'tzinfo'
  gem 'dotenv'
  gem 'nokogiri'
  gem 'reverse_markdown'
end

require 'date'
require 'fileutils'

Dotenv.load

timezone = TZInfo::Timezone.get('America/New_York')
date = timezone.now.to_date
year = date.year
month = date.month
day = date.day

exit 1 if month != 12

folder = "#{year}-#{month}-#{day.to_s.rjust(2, '0')}"

FileUtils.mkdir_p(folder)

# lang = day % 2 == 0 ? 'cr' : 'rb'
lang = 'cr'
puts "Using lang: #{lang}"

templates = {
  'rb' => <<~RUBY,
    #!/usr/bin/env ruby

    File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
      line = file.readline.chomp
    end
  RUBY
  'cr' => <<~CRYSTAL
    #!/usr/bin/env crystal

    file = {% if flag?(:release) %}
             "input.txt"
           {% else %}
             "test_input.txt"
           {% end %}

    lines = File.read_lines(File.join(__DIR__, file)).map(&.chomp)
  CRYSTAL
}

unless File.exist?(File.join(__dir__, folder, 'input.txt'))
  puts "Getting input"
  input = HTTP
    .headers('Cookie' => "session=#{ENV['AOC_SESSION']}")
    .get("https://adventofcode.com/#{year}/day/#{day}/input")

  File.open(File.join(__dir__, folder, 'input.txt'), 'w') do |file|
    file.write(input)
  end
end

unless File.exist?(File.join(__dir__, folder, 'part_1.md'))
  puts "Getting puzzle: part 1"
  puzzle = HTTP
    .headers('Cookie' => "session=#{ENV['AOC_SESSION']}")
    .get("https://adventofcode.com/#{year}/day/#{day}")

  puzzle = Nokogiri::HTML(puzzle.to_s).css('article.day-desc')
  File.write(File.join(__dir__, folder, 'part_1.md'), ReverseMarkdown.convert(puzzle.to_s))
end

unless File.exist?(File.join(__dir__, folder, "part_1.#{lang}"))
  puts "Writing template: part 1"
  File.open(File.join(__dir__, folder, "part_1.#{lang}"), 'w') do |file|
    file.write(templates[lang])
  end
end

if File.exist?(File.join(__dir__, folder, 'part_1_answer.txt'))
  unless File.exist?(File.join(__dir__, folder, 'part_2.md'))
    puts "Getting puzzle: part 2"
    puzzle = HTTP
      .headers('Cookie' => "session=#{ENV['AOC_SESSION']}")
      .get("https://adventofcode.com/#{year}/day/#{day}#part2")

    puzzle = Nokogiri::HTML(puzzle.to_s).css('article.day-desc')[1]
    File.write(File.join(__dir__, folder, 'part_2.md'), ReverseMarkdown.convert(puzzle.to_s))
  end

  unless File.exist?(File.join(__dir__, folder, "part_2.#{lang}"))
    puts "Writing template: part 2"
    File.open(File.join(__dir__, folder, "part_2.#{lang}"), 'w') do |file|
      file.write(templates[lang])
    end
  end
end

