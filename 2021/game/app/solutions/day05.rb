class Day05
  def self.title
    '--- Day 5: Hydrothermal Venture ---'
  end

  def initialize(state)
    @state = state
    setup
  end

  def tick(args)
    render(args)
    process_inputs(args)
  end

  class Line
    attr_reader :start_point, :end_point, :x, :y, :x2, :y2

    def initialize(start_point, end_point)
      @start_point = start_point
      @end_point = end_point
      @horizontal = @start_point.y == @end_point.y
      @vertical = @start_point.x == @end_point.x
      @x = @start_point.x
      @y = @start_point.y
      @x2 = @end_point.x
      @y2 = @end_point.y
    end

    def each_point(&block)
      Bresenham.points(@start_point, @end_point).each(&block)
    end

    def horizontal?
      @horizontal
    end

    def vertical?
      @vertical
    end

    def ==(other)
      @start_point == other.start_point && @end_point == other.end_point
    end

    def to_s
      "Line(#{@start_point} -> #{@end_point})"
    end
  end

  class CalculationPart2
    attr_reader :lines

    def initialize(lines)
      @lines = lines
      @processed_index = 0
      @visits = {}
    end

    def next_overlapping_points
      return if @processed_index >= @lines.size

      [].tap { |result|
        line = @lines[@processed_index]
        line.each_point do |point|
          @visits[point.x] ||= {}
          @visits[point.x][point.y] ||= 0
          @visits[point.x][point.y] += 1
          result << point if @visits[point.x][point.y] == 2
        end
        @processed_index += 1
      }
    end
  end

  class CalculationPart1 < CalculationPart2
    def initialize(lines)
      super(lines.select { |line| line.horizontal? || line.vertical? })
    end
  end

  private

  def setup(calculation_method = CalculationPart1)
    @state.lines = read_problem_input('05').split("\n").map { |line|
      left, right = line.split(' -> ')
      Line.new(left.split(',').map(&:to_i), right.split(',').map(&:to_i))
    }
    @state.calculation = calculation_method.new(@state.lines)
    @state.overlapping_points = []
    @state.canvas_initialized = false
    @state.draw_state = :draw_lines
    @state.offset = [0, 0]
    @state.drag_start = nil
    @state.offset_start = nil
    @state.buttons = [
      Button.new(
        id: :part1,
        rect: { x: 1200, y: 10, w: 30, h: 30 },
        label: '1',
        click_handler: ->(_args, _button) { setup(CalculationPart1) }
      ),
      Button.new(
        id: :part2,
        rect: { x: 1240, y: 10, w: 30, h: 30 },
        label: '2',
        click_handler: ->(_args, _button) { setup(CalculationPart2) }
      )
    ]
  end

  def render(args)
    canvas = get_canvas(args)
    render_vents(canvas) unless @state.draw_state == :finished
    render_canvas(args.outputs)
    render_overlapping_point_count(args.outputs)
    render_select_part_buttons(args)
  end

  def get_canvas(args)
    args.outputs[:line_canvas].tap { |canvas|
      canvas.width = 1000
      canvas.height = 1000
      canvas.clear_before_render = !@state.canvas_initialized
      @state.canvas_initialized = true
    }
  end

  def render_vents(gtk_outputs)
    case @state.draw_state
    when :draw_lines
      render_lines(gtk_outputs, @state.calculation.lines)
      @state.draw_state = :draw_overlapping_points
    when :draw_overlapping_points
      points = @state.calculation.next_overlapping_points
      return @state.draw_state = :finished unless points

      points.each do |point|
        gtk_outputs.primitives << { x: point.x, y: point.y, w: 1, h: 1, path: :pixel, r: 255, g: 0, b: 0 }.sprite!
        @state.overlapping_points << point
      end
    end
  end

  def render_lines(gtk_outputs, lines, **values)
    offset_x, offset_y = @state.offset
    gtk_outputs.primitives << lines.map { |line|
      {
        x: line.x - offset_x, y: line.y - offset_y,
        x2: line.x2 - offset_x, y2: line.y2 - offset_y
      }.line!(values)
    }
  end

  def render_canvas(gtk_outputs)
    gtk_outputs.primitives << {
      x: -@state.offset.x, y: -@state.offset.y, w: 1000, h: 1000, path: :line_canvas
    }.sprite!
  end

  def render_overlapping_point_count(gtk_outputs)
    gtk_outputs.primitives << { x: 1000, y: 670, w: 270, h: 40, r: 255, g: 255, b: 255 }.solid!
    gtk_outputs.primitives << top_right_labels(
      "Overlapping points: #{@state.overlapping_points.size}"
    )
  end

  def render_select_part_buttons(args)
    @state.buttons.each { |button| button.render(args.outputs) }
  end

  def process_inputs(args)
    handle_drag_canvas(args)
    handle_buttons(args)
  end

  def handle_drag_canvas(args)
    mouse = args.inputs.mouse
    if @state.drag_start
      @state.offset = [
        @state.offset_start[0] - (mouse.x - @state.drag_start[0]),
        @state.offset_start[1] - (mouse.y - @state.drag_start[1])
      ]
      return unless mouse.up

      @state.drag_start = nil
      @state.offset_start = nil
    else
      return unless mouse.down

      @state.drag_start = [mouse.x, mouse.y]
      @state.offset_start = @state.offset.dup
    end
  end

  def handle_buttons(args)
    @state.buttons.each { |button| button.tick(args) }
  end
end

SOLUTIONS[5] = Day05
