def tick(args)
  setup(args) if args.tick_count.zero?
  render(args)
  process_input(args)
end

def setup(args)
  args.state.depths = read_problem_input('01').split("\n").map(&:to_i)
  args.state.left_index = 0
  args.state.x_scale = 3
  args.state.result.number_of_increases = calc_number_of_increases(args.state.depths)
  args.state.result.number_of_window_increases = calc_number_of_window_increases(args.state.depths)
end

def read_problem_input(input_id)
  $gtk.read_file("inputs/#{input_id}.txt")
end

def calc_number_of_increases(depths)
  depths.each_cons(2).count { |a, b| b > a }
end

def calc_number_of_window_increases(depths)
  window_sums = depths.each_cons(3).map { |a, b, c| a + b + c }
  window_sums.each_cons(2).count { |a, b| b > a }
end

def render(args)
  render_sea_floor(args)
  render_solution(args)
  render_instructions(args)
end

def render_sea_floor(args)
  dephts = args.state.depths
  left_index = args.state.left_index
  x_scale = args.state.x_scale

  args.outputs.primitives << (0..samples_per_screen(args)).map { |index|
    depth_index = left_index + index

    { x: index * x_scale, y: 0, w: x_scale, h: y_for_depth(dephts[depth_index]), r: 0, g: 89, b: 89 }.solid!
  }
end

def y_for_depth(depth)
  720 - depth.idiv(10)
end

def render_solution(args)
  args.outputs.primitives << [
    { x: 1260, y: 700, text: "Total Measurements: #{args.state.depths.size}", alignment_enum: 2 }.label!,
    { x: 1260, y: 680, text: "Number of increases: #{args.state.result.number_of_increases}", alignment_enum: 2 }.label!,
    { x: 1260, y: 660, text: "Number of window increases: #{args.state.result.number_of_window_increases}", alignment_enum: 2 }.label!
  ]
end

def render_instructions(args)
  args.outputs.primitives << [
    {
      x: 20, y: 20,
      text: '← → or trackpad to scroll sea floor',
      r: 255, g: 255, b: 255,
      vertical_alignment_enum: 0
    }.label!
  ]
end

def process_input(args)
  left_right = get_left_right_input(args.inputs)
  return if left_right.zero?

  args.state.left_index = (args.state.left_index + (left_right * 5)).clamp(0, args.state.depths.size - samples_per_screen(args) - 1)
end

def get_left_right_input(inputs)
  left_right = inputs.keyboard.left_right
  return left_right unless left_right.zero?

  (inputs.mouse.wheel&.x || 0) * 3
end

def samples_per_screen(args)
  1280.idiv(args.state.x_scale)
end

$gtk.reset
