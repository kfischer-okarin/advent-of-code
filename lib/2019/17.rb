# frozen_string_literal: true

require 'set'

require_relative 'common'
require_relative 'intcode_computer'

module Task17
  class Map
    def initialize
      @scaffold_positions = Set.new
    end

    def add_scaffold_position(coordinates)
      scaffold_positions << coordinates
    end

    def intersections
      scaffold_positions.select do |coordinates|
        neighbor_count(coordinates) >= 3
      end
    end

    private

    attr_reader :scaffold_positions

    def neighbor_directions(coordinates)
      [Vector.new(1, 0), Vector.new(-1, 0), Vector.new(0, 1), Vector.new(0, -1)].select do |direction|
        scaffold_positions.include?(coordinates + direction)
      end
    end

    def neighbor_count(coordinates)
      neighbor_directions(coordinates).count
    end
  end

  class Robot
    def initialize(program)
      @program = program
      @computer = IntcodeComputerV3.new(program.dup)
      @map = Map.new
      read_image
    end

    def sum_of_alignment_parameters
      map.intersections.map { |coordinates| alignment_parameter(coordinates) }.sum
    end

    private

    NEW_LINE = 10
    SCAFFOLD = '#'.ord
    ROBOT_UP = '^'.ord
    ROBOT_LEFT = '<'.ord
    ROBOT_RIGHT = '>'.ord
    ROBOT_DOWN = 'v'.ord

    attr_reader :program, :computer, :map, :position

    def read_image
      x = 0
      y = 0
      computer.execute
      while computer.has_output?
        cell = computer.output
        if cell == NEW_LINE
          x = 0
          y += 1
        else
          case cell
          when SCAFFOLD
            map.add_scaffold_position Vector.new(x, y)
          when ROBOT_UP, ROBOT_DOWN, ROBOT_LEFT, ROBOT_RIGHT
            @position = Vector.new(x, y)
            map.add_scaffold_position position
          end
          x += 1
        end
      end
    end

    def alignment_parameter(coordinates)
      coordinates.x * coordinates.y
    end
  end

  if $PROGRAM_NAME == __FILE__
    program = read_intcode_program('17')

    robot = Robot.new(program)

    puts "1) Sum of alignment parameters: #{robot.sum_of_alignment_parameters}"
    # puts "2) Solution 2: #{}"
  end
end
