# frozen_string_literal: true

require 'set'

require_relative 'common'

module Task10
  class Vector < ::Vector
    def unit_length
      gcf = greatest_common_factor(x.abs, y.abs)
      Vector.new(x / gcf, y / gcf)
    end

    def manhattan_distance
      x.abs + y.abs
    end

    def length
      Math.sqrt(x**2 + y**2)
    end

    def angle
      # Angle between zero degree vector (0, -1) and self
      # a * b / |a| * |b|
      cos = -y / length
      if x >= 0
        Math.acos(cos)
      else
        (2 * Math::PI) - Math.acos(cos)
      end
    end
  end

  class Asteroid
    Neighbor = Struct.new('Neighbor', :asteroid, :distance) do
      def coordinates
        asteroid.coordinates
      end

      def neighbors
        asteroid.neighbors
      end

      def <=>(other)
        distance <=> other.distance
      end
    end

    attr_reader :coordinates, :neighbors

    def initialize(coordinates)
      @coordinates = coordinates
      @neighbors = {}
    end

    def neighbor_count
      @neighbors.length
    end

    def add_neighbor(direction, neighbor)
      @neighbors[direction] = SortedSet.new unless @neighbors.key?(direction)
      @neighbors[direction] << neighbor
    end

    def determine_visibility(asteroid)
      connection = asteroid.coordinates - coordinates

      direction = connection.unit_length
      distance = connection.manhattan_distance

      add_neighbor direction, Neighbor.new(asteroid, distance)
      asteroid.add_neighbor direction.negated, Neighbor.new(self, distance)
    end

    def inspect
      "Asteroid (#{coordinates.x}, #{coordinates.y})"
    end
  end

  class Laser
    def initialize(asteroid)
      @asteroid = asteroid
    end

    def shot_asteroids
      Enumerator.new do |y|
        neighbors = copy_neighbors
        sorted_directions = neighbors.keys.sort { |a, b| a.angle <=> b.angle }

        until sorted_directions.empty?
          sorted_directions.each do |direction|
            next_asteroid = neighbors[direction].to_a[0]
            neighbors[direction].delete next_asteroid
            y << next_asteroid
          end
          sorted_directions.delete_if { |direction| neighbors[direction].empty? }
        end
      end
    end

    private

    attr_reader :asteroid

    def copy_neighbors
      {}.tap do |result|
        asteroid.neighbors.each do |direction, neighbors|
          result[direction] = SortedSet.new(neighbors)
        end
      end
    end
  end

  class Space
    def initialize(lines)
      @asteroids = {}

      lines.each_with_index do |line, y|
        line.chars.each_with_index do |cell, x|
          coordinates = Vector.new(x, y)
          @asteroids[coordinates] = Asteroid.new(coordinates) if cell == '#'
        end
      end

      determine_visibility
    end

    def best_asteroid
      @asteroids.values.max { |a, b| a.neighbor_count <=> b.neighbor_count }
    end

    private

    def determine_visibility
      processed = Set.new
      @asteroids.each do |_coordinates, asteroid|
        processed << asteroid

        @asteroids.each do |_coordinates, other_asteroid|
          next if processed.include? other_asteroid

          asteroid.determine_visibility(other_asteroid)
        end
      end
    end
  end

  if $PROGRAM_NAME == __FILE__
    map = read_input_lines('10')

    space = Space.new(map)
    puts "1) Detectable asteroids from best location: #{space.best_asteroid.neighbor_count}"

    laser = Laser.new(space.best_asteroid)
    puts "2) 200th shot asteroid: #{laser.shot_asteroids.to_a[199]}"
  end
end
