class Menu
  def initialize(args)
    args.state.buttons = SOLUTIONS.keys.sort!.map { |number| build_button(number) }
  end

  def tick(args)
    buttons = args.state.buttons
    render_buttons(args.outputs, buttons)
    reset_hover(buttons)
    handle_mouse(args, buttons)
  end

  private

  def build_button(number)
    title = SOLUTIONS[number].title
    width = $gtk.calcstringbox(title)[0] + 20
    {
      number: number,
      label: title,
      rect: { x: 640 - width.idiv(2), y: 720 - (number * 60), w: width, h: 40 },
      hover: false
    }
  end

  def render_buttons(gtk_outputs, buttons)
    gtk_outputs.primitives << buttons.map { |button|
      button_primitives(
        rect: button[:rect],
        label: button[:label],
        inverted: button[:hover]
      )
    }
  end

  def button_primitives(rect:, label:, inverted:)
    button_background = inverted ? rect.to_solid : rect.to_border
    label_color = inverted ? { r: 255, g: 255, b: 255 } : { r: 0, g: 0, b: 0 }
    [
      button_background,
      { x: rect.x + rect.w.idiv(2), y: rect.y + 30, text: label, alignment_enum: 1 }.label!(label_color)
    ]
  end

  def reset_hover(buttons)
    buttons.each { |button| button[:hover] = false }
  end

  def handle_mouse(args, buttons)
    mouse = args.inputs.mouse

    hover_button = buttons.find { |button| mouse.inside_rect? button[:rect] }
    return unless hover_button

    hover_button[:hover] = true
    return unless mouse.down

    start_solution(args, hover_button[:number])
  end

  def start_solution(args, number)
    args.state.data = args.state.new_entity(:data)
    $scene = SOLUTIONS[number].new(args.state.data)
  end
end
