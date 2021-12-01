# frozen_string_literal: true

require_relative '../common'

module AOC2020
  module Task09
    class XMASCracker
      attr_reader :invalid_number, :weakness

      def initialize(numbers)
        @numbers = numbers
        @invalid_number = calc_invalid_number
        @weakness = calc_weakness
      end

      private

      def calc_invalid_number
        index = 25
        loop do
          return @numbers[index] unless sum_of_any_two?(@numbers[index], @numbers[(index - 25)..(index - 1)])

          index += 1
        end
      end

      def calc_weakness
        result_range = numbers_summing_to_invalid_number
        result_range.min + result_range.max
      end

      def numbers_summing_to_invalid_number
        (0..@numbers.length).each do |index|
          ((index + 1)..@numbers.length).each do |index2|
            return @numbers[index..index2] if @numbers[index..index2].sum == @invalid_number
          end
        end
      end

      def sum_of_any_two?(result, numbers)
        (0...numbers.length).any? { |index|
          ((index + 1)...numbers.length).any? { |index2|
            numbers[index] + numbers[index2] == result
          }
        }
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input_lines(__FILE__)

      validator = XMASCracker.new(data.map(&:to_i))

      puts "1) Solution 1: #{validator.invalid_number}"
      puts "2) Solution 2: #{validator.weakness}"
    end
  end
end
