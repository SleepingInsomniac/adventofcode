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
base_path = File.join(__dir__, folder)

part = 1
if File.exist?(File.join(base_path, 'part_1_answer.txt'))
  part = 2

  if File.exist?(File.join(base_path, 'part_2_answer.txt'))
    $stderr.puts "Already submitted"
    exit 1
  end
end

unless File.exist?(File.join(__dir__, folder, "part_#{part}_answer.txt"))
  system "crystal build --release #{File.join(base_path, "part_#{part}.cr")} -o #{File.join(base_path, "part_#{part}")}"
  answer = `#{File.join(base_path, "part_#{part}")}`.chomp
  puts "Answer: #{answer}"

  response = HTTP
    .headers('Cookie' => "session=#{ENV['AOC_SESSION']}")
    .post("https://adventofcode.com/#{year}/day/#{day}/answer", form: { level: part, answer: answer })

  puts response.status
  puts response.to_s

  evaluation = Nokogiri::HTML(response.to_s).css('main article p').text

  puts evaluation

  if evaluation =~ /That\'s the right answer/i
    File.write(File.join(base_path, "part_#{part}_answer.txt"), answer)
    system `#{File.join(__dir__, '_template.rb')}`
  end
end
