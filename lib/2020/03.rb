# frozen_string_literal: true

require_relative '../common'

module AOC2020
  module Task03
    class Map
      def self.parse(lines)
        new(lines.map(&:chars))
      end

      def initialize(rows)
        @rows = rows
        @slice_width = rows[0].size
      end

      def relative_position(position, direction)
        [(position[0] + direction[0]) % @slice_width, position[1] + direction[1]]
      end

      def tree_at?(position)
        @rows[position[1]][position[0]] == '#'
      end

      def reached_bottom?(position)
        position[1] >= @rows.size
      end
    end

    class Toboggan
      attr_reader :trees_encountered

      def initialize(direction)
        @position = [0, 0]
        @direction = direction
        @trees_encountered = 0
      end

      def travel(map)
        until map.reached_bottom?(@position)
          @trees_encountered += 1 if map.tree_at? @position
          @position = map.relative_position(@position, @direction)
        end
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input_lines(__FILE__)

      map = Map.parse(data)
      slopes = [[3, 1], [1, 1], [5, 1], [7, 1], [1, 2]]
      results = slopes.map { |slope|
        toboggan = Toboggan.new(slope)
        toboggan.travel(map)
        toboggan.trees_encountered
      }
      puts "1) Solution 1: #{results[0]}"
      puts "2) Solution 2: #{results.reduce(1, :*)}"
    end
  end
end
