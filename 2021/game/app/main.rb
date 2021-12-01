require 'app/solutions.rb'

SOLUTIONS = {}

def tick(args)
  $scene = Menu.new if args.tick_count.zero?

  $scene.tick(args)
  $scene = Menu.new if args.inputs.keyboard.key_down.escape
end

class Menu
  def initialize
    @buttons = SOLUTIONS.keys.sort!.map { |key|
      {
        solution_class: SOLUTIONS[key]
      }.tap { |button|
        button[:label] = button[:solution_class].title
        width = $gtk.calcstringbox(button[:label])[0] + 20
        button[:rect] = { x: 640 - width.idiv(2), y: 720 - (key * 60), w: width, h: 40 }
        button[:hover] = false
      }
    }
  end

  def tick(args)
    render_buttons(args)
    reset_hover
    handle_mouse(args)
  end

  private

  def render_buttons(args)
    args.outputs.primitives << @buttons.map { |button|
      button_background = button[:hover] ? button[:rect].to_solid : button[:rect].to_border
      label_color = button[:hover] ? { r: 255, g: 255, b: 255 } : { r: 0, g: 0, b: 0 }
      [
        button_background,
        { x: 640, y: button[:rect].y + 30, text: button[:label], alignment_enum: 1 }.label!(label_color)
      ]
    }
  end

  def reset_hover
    @buttons.each { |button| button[:hover] = false }
  end

  def handle_mouse(args)
    mouse = args.inputs.mouse

    hover_button = @buttons.find { |button| mouse.inside_rect? button[:rect] }
    return unless hover_button

    hover_button[:hover] = true
    return unless mouse.down

    args.state.data = args.state.new_entity(:data)
    $scene = hover_button[:solution_class].new(args.state.data)
  end
end

$gtk.reset
