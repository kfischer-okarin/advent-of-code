# frozen_string_literal: true

require 'set'

require_relative '../common'

module AOC2020
  module Task08
    class Interpreter
      def self.parse_instruction(instruction_string)
        type, argument = instruction_string.split
        { type: type.to_sym, argument: argument.to_i }
      end

      attr_reader :accumulator

      def initialize(instructions)
        @instructions = instructions
        @accumulator = 0
        @next_instruction = 0
        @executed_instructions = Set.new
        @terminated = false
      end

      def terminated?
        @terminated
      end

      def execute
        loop do
          break if @executed_instructions.include? @next_instruction

          if @next_instruction == @instructions.size
            @terminated = true
            break
          end

          @executed_instructions << @next_instruction
          instruction = @instructions[@next_instruction]
          send(:"execute_#{instruction[:type]}", instruction[:argument])
        end
      end

      private

      def execute_nop(_argument)
        @next_instruction += 1
      end

      def execute_acc(argument)
        @accumulator += argument
        @next_instruction += 1
      end

      def execute_jmp(argument)
        @next_instruction += argument
      end
    end

    class ProgramFixer
      def initialize(original_instructions)
        @original_instructions = original_instructions
        @interpreter = nil
        @fixed_index = -1
      end

      def accumulator
        @interpreter.accumulator
      end

      def fix_program
        loop do
          @fixed_index += 1
          instruction = @original_instructions[@fixed_index]
          next if instruction[:type] == :acc

          fixed_instructions = Array.new @original_instructions
          fixed_instructions[@fixed_index] = fixed_instruction(instruction)
          @interpreter = Interpreter.new fixed_instructions
          @interpreter.execute
          break if @interpreter.terminated?
        end
      end

      private

      def fixed_instruction(original_instruction)
        original_instruction.merge(type: original_instruction[:type] == :nop ? :jmp : :nop)
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input_lines(__FILE__)
      instructions = data.map { |instruction_line| Interpreter.parse_instruction(instruction_line) }

      interpreter = Interpreter.new(instructions)
      interpreter.execute

      puts "1) Solution 1: #{interpreter.accumulator}"

      program_fixer = ProgramFixer.new(instructions)
      program_fixer.fix_program

      puts "2) Solution 2: #{program_fixer.accumulator}"
    end
  end
end
