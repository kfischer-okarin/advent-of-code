# frozen_string_literal: true

require_relative '../common'

module AOC2020
  module Task11
    class SimulatedSeatingPolicy
      def self.will_be_occupied?(occupied, number_of_occupied_neighbors)
        if occupied
          number_of_occupied_neighbors < 4
        else
          number_of_occupied_neighbors.zero?
        end
      end

      def self.set_neighborships(seat_map)
        seat_map.each_seat do |position, seat|
          [[0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1]].each do |direction|
            neighbor = seat_map.seat_at_position([position[0] + direction[0], position[1] + direction[1]])
            next unless neighbor

            seat.add_neighbor(neighbor)
          end
        end
      end
    end

    class RealSeatingPolicy
      def self.will_be_occupied?(occupied, number_of_occupied_neighbors)
        if occupied
          number_of_occupied_neighbors < 5
        else
          number_of_occupied_neighbors.zero?
        end
      end

      def self.set_neighborships(seat_map)
        seat_map.each_seat do |position, seat|
          [[0, 1], [1, 1], [1, 0], [1, -1], [0, -1], [-1, -1], [-1, 0], [-1, 1]].each do |direction|
            neighbor_position = [position[0], position[1]]
            loop do
              neighbor_position = [neighbor_position[0] + direction[0], neighbor_position[1] + direction[1]]
              break if seat_map.seat_at_position(neighbor_position) || !seat_map.contains_position?(neighbor_position)
            end
            neighbor = seat_map.seat_at_position(neighbor_position)
            next unless neighbor

            seat.add_neighbor(neighbor)
          end
        end
      end
    end

    class Seat
      def initialize(occupied, seating_policy)
        @neighbors = []
        @occupied = occupied
        @occupied_next = false
        @seating_policy = seating_policy
      end

      def occupied?
        @occupied
      end

      def calc_change
        @occupied_next = @seating_policy.will_be_occupied?(occupied?, number_of_occupied_neighbors)
      end

      def will_change?
        @occupied_next != occupied?
      end

      def update
        @occupied = @occupied_next
      end

      def add_neighbor(seat)
        @neighbors << seat
      end

      private

      def number_of_occupied_neighbors
        @neighbors.count(&:occupied?)
      end
    end

    class SeatMap
      def initialize(lines, seating_policy)
        @width = lines[0].size
        @height = lines.size
        @seating_policy = seating_policy
        @seats_by_position = {}
        create_seats(lines)
        @seating_policy.set_neighborships(self)
      end

      def contains_position?(position)
        position[0] >= 0 && position[0] < @width && position[1] >= 0 && position[1] < @height
      end

      def seat_at_position(position)
        @seats_by_position[position]
      end

      def each_seat
        @seats_by_position.each do |position, seat|
          yield position, seat
        end
      end

      def number_of_occupied_seats
        seats.count(&:occupied?)
      end

      def simulate
        loop do
          seats.each(&:calc_change)
          break if seats.none?(&:will_change?)

          seats.each(&:update)
        end
      end

      private

      def seats
        @seats_by_position.values
      end

      def create_seats(lines)
        lines.each_with_index do |line, y|
          line.chars.each_with_index do |char, x|
            next if char == '.'

            @seats_by_position[[x, y]] = Seat.new(char == '#', @seating_policy)
          end
        end
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input_lines(__FILE__)

      seat_map = SeatMap.new(data, SimulatedSeatingPolicy)
      seat_map.simulate

      puts "1) Solution 1: #{seat_map.number_of_occupied_seats}"

      seat_map = SeatMap.new(data, RealSeatingPolicy)
      seat_map.simulate
      puts "2) Solution 2: #{seat_map.number_of_occupied_seats}"
    end
  end
end
