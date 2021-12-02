class Day01
  def self.title
    '--- Day 1: Sonar Sweep ---'
  end

  def initialize(state)
    @state = state
    setup
  end

  def tick(args)
    render(args)
    process_input(args)
  end

  class Calculation
    def initialize(depths)
      @depths = depths
    end

    def number_of_increases
      @depths.each_cons(2).count { |a, b| b > a }
    end

    def number_of_window_increases
      window_sums = @depths.each_cons(3).map { |a, b, c| a + b + c }
      window_sums.each_cons(2).count { |a, b| b > a }
    end
  end

  private

  def setup
    @state.depths = read_problem_input('01').split("\n").map(&:to_i)
    @state.left_index = 0
    @state.x_scale = 3
    calculation = Calculation.new(@state.depths)
    @state.result.number_of_increases = calculation.number_of_increases
    @state.result.number_of_window_increases = calculation.number_of_window_increases
  end

  def render(args)
    render_sea_floor(args)
    render_solution(args)
    render_instructions(args)
  end

  def render_sea_floor(args)
    dephts = @state.depths
    left_index = @state.left_index
    x_scale = @state.x_scale

    args.outputs.primitives << (0..samples_per_screen).map { |index|
      depth_index = left_index + index

      { x: index * x_scale, y: 0, w: x_scale, h: y_for_depth(dephts[depth_index]), r: 0, g: 89, b: 89 }.solid!
    }
  end

  def y_for_depth(depth)
    720 - depth.idiv(10)
  end

  def render_solution(args)
    args.outputs.primitives << top_right_labels(
      "Total Measurements: #{@state.depths.size}",
      "Number of increases: #{@state.result.number_of_increases}",
      "Number of window increases: #{@state.result.number_of_window_increases}"
    )
  end

  def render_instructions(args)
    args.outputs.primitives << bottom_left_labels(
      '← → or trackpad to scroll sea floor',
      'Escape to return to menu',
      attributes: { r: 255, g: 255, b: 255 }
    )
  end

  def process_input(args)
    left_right = get_horizontal_scroll_input(args.inputs)
    return if left_right.zero?

    @state.left_index = (@state.left_index + (left_right * 5)).clamp(0, @state.depths.size - samples_per_screen - 1)
  end

  def samples_per_screen
    1280.idiv(@state.x_scale)
  end
end

SOLUTIONS[1] = Day01
