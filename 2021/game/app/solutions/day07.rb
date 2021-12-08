class Day07
  def self.title
    '--- Day 7: The Treachery of Whales ---'
  end

  def initialize(state)
    @state = state
    setup
  end

  def tick(args)
    render(args)
    process_inputs(args)
    update
  end

  class FuelCostPart1
    def cost_for_next_step
      1
    end

    def total_cost(from_x, to_x)
      (to_x - from_x).abs
    end
  end

  class FuelCostPart2
    def initialize
      @cost_for_next_step = 1
    end

    def cost_for_next_step
      result = @cost_for_next_step
      @cost_for_next_step += 1
      result
    end

    def total_cost(from_x, to_x)
      dx = (to_x - from_x).abs
      dx * (dx + 1) / 2
    end
  end

  private

  def setup
    @state.fuel_cost_method = FuelCostPart2
    @state.positions = read_problem_input_as_csv('07').map(&:to_i)
    @state.fuel_costs = @state.positions.map { @state.fuel_cost_method.new }
    @state.offset = 0
    @state.target_position = find_target_position
    @state.spent_fuel = 0
  end

  def find_target_position
    min = @state.positions.min
    max = @state.positions.max
    (min..max).min_by { |x| cost_for_all_positions(@state.positions, x) }
  end

  def cost_for_all_positions(positions, target_x)
    positions.inject(0) { |sum, position| sum + cost(position, target_x) }
  end

  def cost(from_x, to_x)
    @state.fuel_cost_method.new.total_cost(from_x, to_x)
  end

  def render(args)
    render_crabs(args)
    render_info(args)
  end

  def render_crabs(args)
    offset = @state.offset
    args.outputs.primitives << (offset..offset + 130).map { |index|
      position = @state.positions[index]
      {
        x: ((position / 2000) * 1280), y: (index - offset) * 5, w: 5, h: 5,
        path: :pixel, r: 255, g: 0, b: 0
      }.sprite!
    }
  end

  def render_info(args)
    args.outputs.primitives << top_right_labels(
      "Target position: #{@state.target_position}",
      "Spent fuel: #{@state.spent_fuel}"
    )
  end

  def process_inputs(args)
    @state.offset = (
      @state.offset - get_vertical_scroll_input(args.inputs)
    ).clamp(0, 1000 - 130 - 1)
  end

  def update
    (0..@state.positions.size - 1).each do |index|
      movement = (@state.target_position - @state.positions[index]).sign
      @state.positions[index] += movement
      next if movement.zero?

      @state.spent_fuel += @state.fuel_costs[index].cost_for_next_step
    end
  end
end

SOLUTIONS[7] = Day07
