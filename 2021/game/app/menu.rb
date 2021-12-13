require 'lib/button.rb'

class Menu
  def initialize(args)
    args.state.buttons = SOLUTIONS.keys.sort!.map { |number| build_button(number) }
  end

  def tick(args)
    buttons = args.state.buttons
    render_buttons(args.outputs, buttons)
    handle_buttons(args, buttons)
  end

  private

  def build_button(number)
    title = SOLUTIONS[number].title
    width = $gtk.calcstringbox(title)[0] + 20
    Button.new(
      id: number,
      rect: { x: 100, y: 730 - (number * 60), w: width, h: 40 },
      label: title,
      click_handler: ->(args, _) { start_solution(args, number) }
    )
  end

  def render_buttons(gtk_outputs, buttons)
    buttons.each do |button|
      button.render(gtk_outputs)
    end
  end

  def handle_buttons(args, buttons)
    buttons.each do |button|
      button.tick(args)
    end
  end

  def start_solution(args, number)
    args.state.data = args.state.new_entity(:data)
    $scene = SOLUTIONS[number].new(args.state.data)
  end
end
