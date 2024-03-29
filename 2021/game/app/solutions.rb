require 'app/solutions/day01.rb'
require 'app/solutions/day02.rb'
require 'app/solutions/day03.rb'
require 'app/solutions/day04.rb'
require 'app/solutions/day05.rb'
require 'app/solutions/day06.rb'
require 'app/solutions/day07.rb'
require 'app/solutions/day08.rb'
require 'app/solutions/day09.rb'
require 'app/solutions/day10.rb'
require 'app/solutions/day11.rb'
require 'app/solutions/day12.rb'
require 'app/solutions/day13.rb'
require 'app/solutions/day14.rb'

def read_problem_input_as_csv(input_id)
  read_problem_input(input_id).strip.split(',')
end

def read_problem_input(input_id)
  $gtk.read_file("inputs/#{input_id}.txt")
end

def top_right_labels(*labels, attributes: nil)
  labels.map_with_index { |label, index|
    { x: 1260, y: 700 - (index * 20), text: label, alignment_enum: 2 }.label!(attributes)
  }
end

def bottom_left_labels(*labels, attributes: nil)
  labels.reverse_each.with_index.map { |label, index|
    { x: 20, y: 20 + (index * 20), text: label, vertical_alignment_enum: 0 }.label!(attributes)
  }
end

def centered_label(x, y, text)
  { x: x, y: y, text: text, alignment_enum: 1 }.label!
end

def get_horizontal_scroll_input(inputs, mouse_wheel_factor: 3)
  left_right = inputs.keyboard.left_right
  return left_right unless left_right.zero?

  (inputs.mouse.wheel&.x || 0) * mouse_wheel_factor
end

def get_vertical_scroll_input(inputs, mouse_wheel_factor: 3)
  up_down = inputs.keyboard.up_down
  return up_down unless up_down.zero?

  (inputs.mouse.wheel&.y || 0) * mouse_wheel_factor
end
