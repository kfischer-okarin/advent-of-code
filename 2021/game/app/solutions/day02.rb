require 'lib/bresenham.rb'
require 'lib/button.rb'

class Day02
  def self.title
    '--- Day 2: Dive! ---'
  end

  def initialize(state)
    @state = state
    setup
  end

  def tick(args)
    render(args)
    @state.draw_speed.times do
      update
    end
    handle_buttons(args)
  end

  class CalculationPart1
    def self.parse_direction(direction, steps)
      case direction
      when 'forward'
        [steps, 0]
      when 'up'
        [0, steps]
      when 'down'
        [0, -steps]
      end
    end

    def self.y_factor
      1
    end
  end

  class CalculationPart2
    def initialize
      @aim = 0
    end

    def parse_direction(direction, steps)
      case direction
      when 'forward'
        [steps, @aim * steps]
      when 'up'
        @aim += steps
        [0, 0]
      when 'down'
        @aim -= steps
        [0, 0]
      end
    end

    def y_factor
      1000
    end
  end

  private

  def setup(calculation_method = CalculationPart1)
    @state.calculation_method = calculation_method
    @state.depth = 0
    @state.horizontal_position = 0
    @state.path = read_problem_input('02').split("\n")
    @state.index = 0
    @state.draw_speed = 10
    @state.draw_cursor = position_on_canvas
    @state.draw_steps = []
    @state.initial_clear = false
    @state.canvas_offset = [0, CANVAS_H - 720 - 1]
    @state.positions_to_draw = []
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
        click_handler: ->(_args, _button) { setup(CalculationPart2.new) }
      )
    ]
  end

  CANVAS_W = 2500
  CANVAS_H = 1500

  def render(args)
    render_queued_positions(args)
    render_canvas(args)
    render_information(args)
    render_select_part_buttons(args)
  end

  def render_queued_positions(args)
    get_outputs(args).primitives << @state.positions_to_draw.map { |position|
      {
        x: position[0], y: position[1], w: 1, h: 1,
        path: :pixel, r: 255, g: 0, b: 0
      }.sprite!
    }
    @state.positions_to_draw.clear
  end

  def get_outputs(args)
    args.outputs[:path].tap { |outputs|
      outputs.background_color = [255, 255, 255]
      outputs.clear_before_render = !@state.initial_clear
      @state.initial_clear = true
      outputs.width = CANVAS_W
      outputs.height = CANVAS_H
    }
  end

  def render_canvas(args)
    args.outputs.primitives << {
      x: 0, y: 0, w: 1280, h: 720, path: :path,
      source_x: @state.canvas_offset.x, source_y: @state.canvas_offset.y, source_w: 1280, source_h: 720
    }.sprite!
  end

  def render_information(args)
    args.outputs.primitives << top_right_labels(
      "Horizontal Position: #{@state.horizontal_position}",
      "Depth: #{@state.depth}",
      "Multiplied: #{@state.horizontal_position * @state.depth}"
    )
  end

  def render_select_part_buttons(args)
    @state.buttons.each { |button| button.render(args.outputs) }
  end

  def update
    update_position if @state.draw_steps.empty?
    set_next_step
    update_canvas_offset
  end

  def update_position
    return if @state.index >= @state.path.length

    next_path_element = parse_path_element @state.path[@state.index]
    @state.horizontal_position += next_path_element.x
    @state.depth -= next_path_element.y
    @state.index += 1
    @state.draw_steps = Bresenham.steps(@state.draw_cursor, position_on_canvas).to_a
  end

  def parse_path_element(path_element)
    direction, steps = path_element.split
    @state.calculation_method.parse_direction(direction, steps.to_i)
  end

  def set_next_step
    return if @state.draw_steps.empty?

    next_step = @state.draw_steps.shift
    @state.draw_cursor = [@state.draw_cursor.x + next_step.x, @state.draw_cursor.y + next_step.y]
    @state.positions_to_draw << @state.draw_cursor.dup
  end

  def update_canvas_offset
    @state.canvas_offset = [
      [@state.canvas_offset.x, @state.draw_cursor.x - 960].max,
      [@state.canvas_offset.y, @state.draw_cursor.y - 180].min
    ]
  end

  def position_on_canvas
    [@state.horizontal_position, y_on_canvas(@state.depth)]
  end

  def y_on_canvas(depth)
    CANVAS_H - 50 - depth.idiv(@state.calculation_method.y_factor)
  end

  def handle_buttons(args)
    @state.buttons.each { |button| button.tick(args) }
  end
end

SOLUTIONS[2] = Day02
