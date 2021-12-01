# frozen_string_literal: true

require_relative '../common'

module AOC2020
  module Task23
    class Cup
      attr_reader :number
      attr_accessor :neighbor

      def initialize(number)
        @number = number
      end

      def all_cups
        current = self
        Enumerator.new do |y|
          loop do
            y << current
            break if current.neighbor == self || current.neighbor.nil?

            current = current.neighbor
          end
        end
      end

      def all_numbers
        all_cups.to_a.map(&:number)
      end

      def remove(number)
        first_taken = neighbor
        current = first_taken
        (number - 1).times do
          current = current.neighbor
        end
        self.neighbor = current.neighbor
        current.neighbor = nil
        first_taken
      end

      def insert(cup)
        old_neighbor = neighbor
        self.neighbor = cup
        cup.all_cups.to_a.last.neighbor = old_neighbor
      end
    end

    class CupRing
      def initialize(cups)
        @current = nil
        @by_number = {}
        @max_number = 0
        create_cups(cups)
      end

      def play_turn
        taken_cups = @current.remove(3)
        destination_cup = find_destination_cup(taken_cups)
        destination_cup.insert taken_cups
        @current = @current.neighbor
      end

      def order
        @by_number[1].all_numbers[1..].join
      end

      def two_cups_next_to_one
        one = @by_number[1]
        [one.neighbor.number, one.neighbor.neighbor.number]
      end

      private

      def create_cups(cups)
        last_added = nil
        cups.each do |number|
          @max_number = [@max_number, number].max
          new_cup = Cup.new(number)
          @by_number[number] = new_cup
          @current ||= new_cup
          last_added.neighbor = new_cup if last_added
          last_added = new_cup
        end
        last_added.neighbor = @current
      end

      def find_destination_cup(taken_cups)
        number = @current.number
        loop do
          number -= 1
          number = @max_number if number <= 0
          break unless taken_cups.all_numbers.include? number
        end
        @by_number[number]
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = '418976235'
      cup_ring = CupRing.new data.chars.map(&:to_i)
      100.times { cup_ring.play_turn }

      puts "1) Solution 1: #{cup_ring.order}"

      real_cup_ring = CupRing.new(data.chars.map(&:to_i) + (10..1_000_000).to_a)
      10_000_000.times { real_cup_ring.play_turn }
      puts "2) Solution 2: #{real_cup_ring.two_cups_next_to_one}"
    end
  end
end
