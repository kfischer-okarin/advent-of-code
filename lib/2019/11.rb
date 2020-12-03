# frozen_string_literal: true

require_relative 'common'
require_relative 'intcode_computer'

module Task11
  class Vector < ::Vector
    def rotate_left
      Vector.new(-y, x)
    end

    def rotate_right
      Vector.new(y, -x)
    end
  end

  BLACK = 0
  WHITE = 1

  class Hull
    def initialize
      @colors = {}
      @robot_position = Vector.new(0, 0)
    end

    def color_at_robot
      @colors[@robot_position] || BLACK
    end

    def move_robot(direction)
      @robot_position += direction
    end

    def paint(color)
      @colors[@robot_position] = color
    end

    def painted_panels
      @colors.size
    end

    def draw
      puts HullRenderer.new(@colors).render
    end

    class HullRenderer < MapRenderer
      protected

      def render_element(element)
        element == WHITE ? 'X' : ' '
      end
    end
  end

  class Robot
    def initialize(program, interface)
      @computer = IntcodeComputerV3.new(program)
      @direction = Vector.new(0, 1)
      @interface = interface
    end

    def run
      until computer.finished?
        computer.input = interface.color_at_robot
        computer.execute
        interface.paint computer.output
        turn computer.output
        interface.move_robot direction
      end
    end

    private

    LEFT = 0
    RIGHT = 1

    attr_reader :computer, :direction, :interface

    def turn(direction)
      case direction
      when LEFT
        turn_left
      when RIGHT
        turn_right
      else
        raise "Unknown direction: #{direction}"
      end
    end

    def turn_right
      @direction = @direction.rotate_right
    end

    def turn_left
      @direction = @direction.rotate_left
    end
  end

  if $PROGRAM_NAME == __FILE__
    program = read_intcode_program('11')

    hull = Hull.new
    robot = Robot.new(program, hull)
    robot.run

    puts "1) Painted panels: #{hull.painted_panels}"

    hull = Hull.new
    hull.paint WHITE
    robot = Robot.new(program, hull)
    robot.run
    puts '2) Painted ID:'
    hull.draw
  end
end
