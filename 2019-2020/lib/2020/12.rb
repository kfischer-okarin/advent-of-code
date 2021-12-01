# frozen_string_literal: true

require_relative '../common'

module AOC2020
  module Task12
    class DirectNavigation
      attr_reader :ship_position

      def initialize
        @ship_position = [0, 0]
        @ship_direction = [1, 0]
      end

      DIRECTIONS = [[0, 1], [1, 0], [0, -1], [-1, 0]].freeze

      def move_north(steps)
        move([0, 1], steps)
      end

      def move_south(steps)
        move([0, -1], steps)
      end

      def move_east(steps)
        move([1, 0], steps)
      end

      def move_west(steps)
        move([-1, 0], steps)
      end

      def turn_right(degrees)
        current_index = DIRECTIONS.index(@ship_direction)
        new_index = (current_index + (degrees / 90)) % 4
        @ship_direction = DIRECTIONS[new_index]
      end

      def turn_left(degrees)
        turn_right(-degrees)
      end

      def move_forward(steps)
        move(@ship_direction, steps)
      end

      private

      def move(direction, steps)
        @ship_position[0] += direction[0] * steps
        @ship_position[1] += direction[1] * steps
      end
    end

    class WaypointNavigation
      attr_reader :ship_position

      def initialize
        @ship_position = [0, 0]
        @ship_direction = [1, 0]
        @waypoint = [10, 1]
      end

      def move_north(steps)
        move_waypoint([0, 1], steps)
      end

      def move_south(steps)
        move_waypoint([0, -1], steps)
      end

      def move_east(steps)
        move_waypoint([1, 0], steps)
      end

      def move_west(steps)
        move_waypoint([-1, 0], steps)
      end

      def turn_right(degrees)
        (degrees / 90).times { rotate_waypoint_right_90_degrees }
      end

      def turn_left(degrees)
        (degrees / 90).times { rotate_waypoint_left_90_degrees }
      end

      def move_forward(steps)
        @ship_position[0] += @waypoint[0] * steps
        @ship_position[1] += @waypoint[1] * steps
      end

      private

      def move_waypoint(direction, steps)
        @waypoint[0] += direction[0] * steps
        @waypoint[1] += direction[1] * steps
      end

      # [0, 1] -> [1, 0] -> [0, -1] -> [-1, 0]
      def rotate_waypoint_right_90_degrees
        @waypoint = [@waypoint[1], -@waypoint[0]]
      end

      # [0, 1] -> [-1, 0] -> [0, -1] -> [1, 0]
      def rotate_waypoint_left_90_degrees
        @waypoint = [-@waypoint[1], @waypoint[0]]
      end
    end

    class ShipNavigation
      def initialize(strategy)
        @strategy = strategy
      end

      def execute_instructions(instructions)
        instructions.each do |instruction|
          instruction, value = parse_instruction(instruction)
          @strategy.send(instruction, value)
        end
      end

      def distance_from_start
        @strategy.ship_position[0].abs + @strategy.ship_position[1].abs
      end

      private

      INSTRUCTIONS = {
        'N' => :move_north,
        'S' => :move_south,
        'E' => :move_east,
        'W' => :move_west,
        'L' => :turn_left,
        'R' => :turn_right,
        'F' => :move_forward
      }.freeze

      def parse_instruction(instruction)
        [INSTRUCTIONS[instruction[0]], instruction[1..].to_i]
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input_lines(__FILE__)

      navigation = ShipNavigation.new(DirectNavigation.new)
      navigation.execute_instructions(data)
      puts "1) Solution 1: #{navigation.distance_from_start}"

      navigation = ShipNavigation.new(WaypointNavigation.new)
      navigation.execute_instructions(data)
      puts "2) Solution 2: #{navigation.distance_from_start}"
    end
  end
end
