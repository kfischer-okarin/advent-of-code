# frozen_string_literal: true

require_relative '../common'

module AOC2020
  module Task13
    class Bus
      attr_reader :id

      def initialize(id)
        @id = id
      end

      def earliest_departure_from(timestamp)
        (timestamp / @id.to_f).ceil * @id
      end

      def departs_at?(timestamp)
        (timestamp % @id).zero?
      end

      def inspect
        "Bus(#{@id})"
      end
    end

    class BusTravel
      def self.parse(data)
        earliest_possible_timestamp = data[0].to_i
        buses = data[1].split(',').reject { |entry| entry == 'x' }.map { |entry| Bus.new(entry.to_i) }
        new(earliest_possible_timestamp, buses)
      end

      def initialize(earliest_possible_timestamp, buses)
        @earliest_possible_timestamp = earliest_possible_timestamp
        @buses = buses
      end

      def earliest_possible_bus
        @buses.min_by { |bus| bus.earliest_departure_from(@earliest_possible_timestamp) }
      end

      def waiting_time_until_next_departure(bus)
        bus.earliest_departure_from(@earliest_possible_timestamp) - @earliest_possible_timestamp
      end
    end

    class PrimeFactors
      class << self
        def from(number)
          new calc_factors(number)
        end

        def calc_factors(number)
          {}.tap { |result|
            factor = 2
            remainder = number
            while factor <= remainder
              if (remainder % factor).zero?
                result[factor] = (result[factor] || 0) + 1
                remainder /= factor
              else
                factor += 1
              end
            end
          }
        end
      end

      attr_reader :factors

      def initialize(factors)
        @factors = factors
      end

      def number
        @factors.reduce(1) { |result, (factor, exponent)| result * factor**exponent }
      end

      def common_with(other)
        common_factors = {}
        @factors.each do |factor, exponent|
          next unless other.factors.key? factor

          common_factors[factor] = [exponent, other.factors[factor]].min
        end
        PrimeFactors.new(common_factors)
      end
    end

    class TimestampFinder
      def self.parse(data)
        bus_offsets = {}
        data[1].split(',').each_with_index do |entry, index|
          next if entry == 'x'

          bus_offsets[Bus.new(entry.to_i)] = index
        end
        new(bus_offsets)
      end

      attr_reader :result

      def initialize(bus_offsets)
        @bus_offsets = bus_offsets
        @longest_bus = buses.max_by(&:id)
        @search_start = @longest_bus.id - longest_bus_offset
        @search_step = @longest_bus.id
      end

      def find
        run_sub_finder if @bus_offsets.size > 2

        # two numbers: find match
        # find least common multiple -> it will happen again every lcm after that
        # Take third number... repeat until all
        brute_force_find
      end

      def lcm_of_ids
        @bus_offsets.keys.map(&:id).reduce { |result, next_offset| least_common_multiple(result, next_offset) }
      end

      private

      def run_sub_finder
        offsets = @bus_offsets.to_a
        sub_finder = TimestampFinder.new(offsets[0..-2].to_h)
        sub_finder.find
        @search_start = sub_finder.result
        @search_step = sub_finder.lcm_of_ids
      end

      def brute_force_find
        @result = @search_start
        loop do
          break if buses_will_depart_correctly? @result

          @result += @search_step
        end
      end

      def buses
        @bus_offsets.keys
      end

      def longest_bus_offset
        @bus_offsets[@longest_bus]
      end

      def buses_will_depart_correctly?(timestamp)
        buses.all? { |bus|
          expected_timestamp = timestamp + @bus_offsets[bus]
          bus.departs_at? expected_timestamp
        }
      end

      def least_common_multiple(a, b)
        a * b / greatest_common_divisor(a, b)
      end

      def greatest_common_divisor(a, b)
        PrimeFactors.from(a).common_with(PrimeFactors.from(b)).number
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input_lines(__FILE__)

      travel = BusTravel.parse(data)
      earliest_possible_bus = travel.earliest_possible_bus
      puts "1) Solution 1: #{earliest_possible_bus.id * travel.waiting_time_until_next_departure(earliest_possible_bus)}"

      finder = TimestampFinder.parse(data)
      finder.find
      puts "2) Solution 2: #{finder.result}"
    end
  end
end
