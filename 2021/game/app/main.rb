require 'app/menu.rb'
require 'app/solutions.rb'

SOLUTIONS = {} # rubocop:disable Style/MutableConstant

def tick(args)
  setup(args) if args.tick_count.zero?

  $scene.tick(args)
  show_menu if args.inputs.keyboard.key_down.escape
end

def setup(args)
  $menu = Menu.new(args)
  show_menu
end

def show_menu
  $scene = $menu
end

$gtk.reset
