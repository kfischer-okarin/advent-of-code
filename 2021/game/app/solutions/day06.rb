class Day06
  def self.title
    '--- Day 6: Lanternfish ---'
  end

  def initialize(state)
    @state = state
    setup
  end

  def tick(args)
    render(args)
    update
  end

  private

  def setup
    @state.fish_counts = read_input
    @state.ticks = 0
    @state.passed_days = 0
    @state.day_ticks = 5
    @state.max_days = 256
    @state.count_after_80_days = nil
  end

  def read_input
    build_fish_counts.tap { |counts|
      read_problem_input('06').strip.split(',').each do |timer|
        counts[timer.to_i] += 1
      end
    }
  end

  def build_fish_counts
    (0..8).map { |i| [i, 0] }.to_h
  end

  def render(args)
    render_fish_counts(args)
    render_info(args)
  end

  def render_fish_counts(args)
    padding = 100
    graph_x = 200
    graph_y = 70
    x_width = 100
    y_width = 500
    max_count = @state.fish_counts.values.max
    args.outputs.primitives << [
      { x: graph_x, y: graph_y, x2: graph_x + (x_width * 9) + padding, y2: graph_y }.line!,
      { x: graph_x, y: graph_y, x2: graph_x, y2: graph_y + y_width + padding }.line!,
      { x: graph_x - 20, y: graph_y + y_width, x2: graph_x + 20, y2: graph_y + y_width }.line!,
      {
        x: graph_x - 30, y: graph_y + y_width,
        text: max_count.to_s, vertical_alignment_enum: 1, alignment_enum: 2
      }.label!
    ]
    args.outputs.primitives << (0..8).map { |i|
      x = graph_x + (x_width * (i + 1))

      [
        { x: x, y: graph_y - 20, x2: x, y2: graph_y + 20 }.line!,
        { x: x, y: graph_y - 30, text: i.to_s, alignment_enum: 1 }.label!,
        { x: x - 10, y: graph_y, w: 20, h: @state.fish_counts[i] * y_width / max_count }.solid!
      ]
    }
  end

  def render_info(args)
    args.outputs.primitives << top_right_labels(
      "Passed days: #{@state.passed_days}",
      "Fishes: #{total_fish_count}",
      "After 80 days: #{@state.count_after_80_days}"
    )
  end

  def total_fish_count
    @state.fish_counts.values.inject(&:+)
  end

  def update
    return if @state.passed_days == @state.max_days

    @state.ticks += 1
    return unless @state.ticks == @state.day_ticks

    update_fish_counts
    @state.passed_days += 1
    @state.count_after_80_days = total_fish_count if @state.passed_days == 80
    @state.ticks = 0
  end

  def update_fish_counts
    new_counts = build_fish_counts
    @state.fish_counts.each do |timer_value, count|
      if timer_value.zero?
        new_counts[6] += count
        new_counts[8] += count
      else
        new_counts[timer_value - 1] += count
      end
    end
    @state.fish_counts = new_counts
  end
end

SOLUTIONS[6] = Day06
