#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  gem 'http'
  gem 'tzinfo'
  gem 'dotenv'
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

unless File.exist?(File.join(__dir__, folder, 'input.txt'))
  input = HTTP
    .headers('Cookie' => "session=#{ENV['AOC_SESSION']}")
    .get("https://adventofcode.com/#{year}/day/#{day}/input")

  File.open(File.join(__dir__, folder, 'input.txt'), 'w') do |file|
    file.write(input)
  end
end

lang = day % 2 == 0 ? 'cr' : 'rb'

rb_template = <<~RUBY
  #!/usr/bin/env ruby

  File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
    line = file.readline.chomp
  end
RUBY

cr_template = <<~CRYSTAL
  #!/usr/bin/env crystal

  File.open(File.join(__DIR__, "input.txt"), "r") do |file|
    line = file.gets("\\n", true)
  end
CRYSTAL

unless File.exist?(File.join(__dir__, folder, "part_1.#{lang}"))
  File.open(File.join(__dir__, folder, "part_1.#{lang}"), 'w') do |file|
    file.write(lang == 'rb' ? rb_template : cr_template)
  end
end
