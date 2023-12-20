#!/usr/bin/env ruby

class Workflow
  attr_reader :rules, :parts

  def initialize(name, workflows)
    @name = name
    @workflows = workflows
    @rules = []
    @parts = []
  end

  def process
    while part = @parts.shift
      @rules.each do |rule|
        break if rule.apply(part, @workflows)
      end
    end
  end

  def sum
    @parts.map(&:values).flatten.sum
  end
end

class Rule
  attr_reader :rating, :op, :oprand, :dest

  def initialize(rating, op, oprand, dest)
    @rating, @op, @oprand, @dest = rating, op, oprand, dest
  end

  def apply(part, workflows)
    case @op
    when :<
      if part[@rating] < @oprand
        workflows[@dest].parts << part
        true
      else
        false
      end
    when :>
      if part[@rating] > @oprand
        workflows[@dest].parts << part
        true
      else
        false
      end
    else
      workflows[@dest].parts << part
      true
    end
  end
end

workflows = {}
workflows[:in] = Workflow.new(:in, workflows)

File.open(File.join(__dir__, 'input.txt'), 'r') do |file|
  reading_parts = false
  until file.eof?
    line = file.readline.chomp
    reading_parts = true and next if line =~ /^\s*$/

    unless reading_parts
      name, line = line.split('{')
      workflow = Workflow.new(name.to_sym, workflows)
      workflows[name.to_sym] = workflow

      rules = line[..-2].split(',')

      rules.each do |rule|
        r = rule.split(':')
        case r.size
        when 1
          workflow.rules << Rule.new(:none, :any, 0, r.last.to_sym)
        else
          rating, op, oprand = r[0].split(/(<|>)/)
          workflow.rules << Rule.new(rating.to_sym, op.to_sym, oprand.to_i, r[1].to_sym)
        end
      end

    else
      workflows[:in].parts << line[1..-1].split(',').map { |c| c = c.split('='); [c[0].to_sym, c[1].to_i] }.to_h
    end
  end
end

workflows[:A] = Workflow.new(:A, workflows)
workflows[:R] = Workflow.new(:R, workflows)

until workflows.except(:A, :R).values.all? { |w| w.parts.empty? }
  workflows.except(:A, :R).values.each(&:process)
end

puts workflows[:A].sum
