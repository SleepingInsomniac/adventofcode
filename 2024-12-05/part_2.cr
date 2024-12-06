#!/usr/bin/env crystal

input_path = File.join(__DIR__, {% if flag?(:release) %} "input.txt" {% else %} "test_input.txt" {% end %})

orderings = {} of Int32 => Array(Int32)
updates = [] of Array(Int32)

File.open(input_path, "r") do |file|
  while line = file.gets
    break if line.blank?
    l, r = line.split('|').map(&.to_i32)
    orderings[l] = [] of Int32 unless orderings[l]?
    orderings[l] << r
  end

  while line = file.gets
    updates << line.split(',').map(&.to_i32)
  end
end

# puts orderings.join("\n")

def correct_order?(update, orderings)
  update.each_with_index do |page, i|
    rights = orderings[page]? || [] of Int32
    rights.each do |right|
      if ri = update.index(right)
        return false if ri < i
      end
    end
  end
  true
end

def topological_sort(pages : Array(Int32), orderings : Hash(Int32, Array(Int32)))
  subgraph = {} of Int32 => Array(Int32)
  pages_set = pages.to_set

  pages.each do |p|
    subgraph[p] = (orderings[p]? || [] of Int32).select { |r| pages_set.includes?(r) }
  end

  indegree = Hash(Int32, Int32).new(0)

  pages.each do |p|
    indegree[p] = 0
  end

  subgraph.each do |from, tos|
    tos.each do |t|
      indegree[t] += 1
    end
  end

  queue = [] of Int32
  indegree.each do |node, deg|
    queue << node if deg == 0
  end

  sorted = [] of Int32

  while !queue.empty?
    node = queue.shift
    sorted << node
    subgraph[node].each do |adj|
      indegree[adj] -= 1
      queue << adj if indegree[adj] == 0
    end
  end

  sorted
end

invalid_updates = updates.reject do |update|
  correct_order?(update, orderings)
end

invalid_updates.map! do |update|
  topological_sort(update, orderings)
end

puts invalid_updates.reduce(0) { |t, u| t + u[u.size // 2] }
