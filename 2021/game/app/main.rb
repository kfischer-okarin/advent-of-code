require 'app/menu.rb'
require 'app/solutions.rb'

SOLUTIONS = {}

def tick(args)
  $scene = Menu.new if args.tick_count.zero?

  $scene.tick(args)
  $scene = Menu.new if args.inputs.keyboard.key_down.escape
end

$gtk.reset
