require 'app/solutions/day01.rb'
require 'app/solutions/day02.rb'

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

def get_horizontal_scroll_input(inputs, mouse_wheel_factor: 3)
  left_right = inputs.keyboard.left_right
  return left_right unless left_right.zero?

  (inputs.mouse.wheel&.x || 0) * mouse_wheel_factor
end
