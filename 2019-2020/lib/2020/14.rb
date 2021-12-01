# frozen_string_literal: true

require_relative '../common'

module AOC2020
  module Task14
    class ValueBitmask
      def initialize(bitmask)
        @and_bitmask = bitmask.gsub('X', '1').to_i(2) # Apply zeros
        @or_bitmask = bitmask.gsub('X', '0').to_i(2) # Apply ones
      end

      def apply_to_value(number)
        (number & @and_bitmask) | @or_bitmask
      end
    end

    class AddressBitmask
      SIZE = 36

      def initialize(bitmask)
        @or_bitmask = bitmask.gsub('X', '0').to_i(2) # Apply ones
        @x_bits = []
        bitmask.chars.each_with_index do |c, i|
          @x_bits << SIZE - i - 1 if c == 'X'
        end
      end

      def addresses_for(address)
        result = [address | @or_bitmask]
        @x_bits.each do |bit|
          result = with_floating_bit(bit, result)
        end
        result
      end

      private

      def with_floating_bit(bit, result)
        result.flat_map { |address|
          [
            address | 2**bit, # Set that bit to 1
            address & (2**SIZE - 1 - 2**bit) # Set that bit to 0
          ]
        }
      end
    end

    class Interpreter
      def initialize(instructions)
        @instructions = instructions
        @memory = {}
      end

      def execute
        @instructions.each do |instruction|
          send(*parse_instruction(instruction))
        end
      end

      def sum_of_memory_values
        @memory.values.sum
      end

      private

      MASK_FORMAT = /\Amask = (.+)\Z/.freeze
      SET_VALUE_FORMAT = /\Amem\[(\d+)\] = (\d+)\Z/.freeze

      def parse_instruction(instruction)
        if (match = MASK_FORMAT.match(instruction))
          [:set_bitmask, match[1]]
        elsif (match = SET_VALUE_FORMAT.match(instruction))
          [:set_value, match[1].to_i, match[2].to_i]
        end
      end

      def set_bitmask(bitmask)
        @bitmask = ValueBitmask.new(bitmask)
      end

      def set_value(address, value)
        @memory[address] = @bitmask.apply_to_value(value)
      end
    end

    class InterpreterV2 < Interpreter
      private

      def set_bitmask(bitmask)
        @bitmask = AddressBitmask.new(bitmask)
      end

      def set_value(address, value)
        @bitmask.addresses_for(address).each do |actual_address|
          @memory[actual_address] = value
        end
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input_lines(__FILE__)

      interpreter = Interpreter.new(data)
      interpreter.execute

      puts "1) Solution 1: #{interpreter.sum_of_memory_values}"

      interpreter = InterpreterV2.new(data)
      interpreter.execute
      puts "2) Solution 2: #{interpreter.sum_of_memory_values}"
    end
  end
end
