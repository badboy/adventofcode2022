#!/usr/bin/env ruby
# encoding: utf-8

s = $stdin.read

# 0 = iter
# 1 = x
# 2 = y
# 3 = tail_x
# 4 = tail_y
# 5 = dir

X_MAX = 200
Y_MAX = 200

def idx(x, y)
  x + (y * X_MAX)
end

states = s.split("\r\n").map {|line| line.split(",").map{ |i| Integer(i) rescue i}}
default_grid = "." * (X_MAX * Y_MAX)

def print_grid(default_grid)
  grid = default_grid.split("")
  g = (0...Y_MAX).map { |i|
    grid[X_MAX*i, X_MAX]*""
  }
  g.reverse.each do |line|
    puts line
  end
end

states.each do |state|
  grid = default_grid.dup

  puts "== S #{state[0]}: #{state[5]} =="
  grid[0] = 's'
  grid[idx(*state[3,2])] = 'T'
  grid[idx(*state[1,2])] = 'H'
  print_grid(grid)
  puts
end
