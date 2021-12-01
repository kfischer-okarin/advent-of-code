# frozen_string_literal: true

require_relative '../common'

module AOC2020
  module Task10
    class AdapterConnection
      attr_reader :differences

      def initialize(adapters)
        @adapters = adapters.sort
        @differences = calc_differences
        calc_ways_to_reach
      end

      def combinations
        @ways_to_reach[@adapters[-1]]
      end

      private

      def calc_differences
        last_output = 0
        { 1 => 0, 2 => 0, 3 => 1 }.tap { |result|
          @adapters.each do |output|
            difference = output - last_output
            result[difference] += 1
            last_output = output
          end
        }
      end

      def calc_ways_to_reach
        @ways_to_reach = Hash.new(0)
        @ways_to_reach[0] = 1
        @adapters.each do |output|
          @ways_to_reach[output] = @ways_to_reach[output - 3] + @ways_to_reach[output - 2] + @ways_to_reach[output - 1]
        end
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input_lines(__FILE__)

      connection = AdapterConnection.new data.map(&:to_i)

      puts "1) Solution 1: #{connection.differences[1] * connection.differences[3]}"
      puts "2) Solution 2: #{connection.combinations}"
    end
  end
end
