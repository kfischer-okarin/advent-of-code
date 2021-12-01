# frozen_string_literal: true

require_relative '../common'

module AOC2020
  module Task17
    class Cube
      attr_reader :position

      def initialize(map, position)
        @map = map
        @position = position
        @active = false
        @active_next = false
      end

      def active?
        @active
      end

      def active=(value)
        @active = value
        @map.cube_became_active(self)
      end

      def calc_change
        @active_next = will_be_active?
      end

      def will_change?
        @active_next != active?
      end

      def update
        self.active = @active_next
      end

      private

      def will_be_active?
        if active?
          [2, 3].include? number_of_active_neighbors
        else
          number_of_active_neighbors == 3
        end
      end

      def number_of_active_neighbors
        @map.neighbors(@position).count(&:active?)
      end
    end

    class CubeSpace
      def initialize(initial_area, dimensions)
        @cubes_by_position = {}
        @dimensions = dimensions
        create_initial_cubes(initial_area)
      end

      def number_of_active_cubes
        cubes.count(&:active?)
      end

      def execute_cycle
        cubes.each(&:calc_change)
        cubes.each(&:update)
      end

      def cube_became_active(cube)
        neighbor_positions(cube.position).each do |neighbor_position|
          initialize_cube(neighbor_position)
        end
      end

      def neighbors(position)
        Enumerator.new do |y|
          neighbor_positions(position).each do |neighbor_position|
            y << @cubes_by_position[neighbor_position] if @cubes_by_position.key? neighbor_position
          end
        end
      end

      private

      def cubes
        @cubes_by_position.values
      end

      def initialize_cube(position)
        @cubes_by_position[position] ||= Cube.new(self, position)
      end

      def create_initial_cubes(initial_area)
        initial_area.split.each_with_index do |line, y|
          line.chars.each_with_index do |char, x|
            position = [x, y] + [0] * (@dimensions - 2)
            initialize_cube(position)
            cube = @cubes_by_position[position]
            cube.active = char == '#'
          end
        end
      end

      def neighbors_in_dimension(positions, dimension)
        Enumerator.new do |y|
          [-1, 0, 1].each do |offset|
            positions.each do |position|
              new_position = position.dup
              new_position[dimension] += offset
              y << new_position
            end
          end
        end
      end

      def neighbor_positions(position)
        Enumerator.new do |yielder|
          positions = [position]
          @dimensions.times do |dimension|
            positions = neighbors_in_dimension(positions, dimension)
          end

          positions.each do |neighbor_position|
            next if neighbor_position == position

            yielder << neighbor_position
          end
        end
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input(__FILE__)

      cube_space = CubeSpace.new(data, 3)
      6.times { cube_space.execute_cycle }

      puts "1) Solution 1: #{cube_space.number_of_active_cubes}"

      cube_space = CubeSpace.new(data, 4)
      6.times { cube_space.execute_cycle }
      puts "2) Solution 2: #{cube_space.number_of_active_cubes}"
    end
  end
end
