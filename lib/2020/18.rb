# frozen_string_literal: true

require_relative '../common'

module AOC2020
  module Task18
    class Number
      def initialize(value)
        @value = value
      end

      def evaluate
        @value
      end

      def binds_stronger_than?(_operator)
        true
      end

      def inspect
        "Number.new(#{@value})"
      end
    end

    class Operation
      attr_reader :operator, :left, :right

      attr_writer :in_brackets

      def initialize(operator, left, right)
        @operator = operator
        @left = left
        @right = right
        @in_brackets = false
      end

      def binds_stronger_than?(operator)
        %i[+ -].include?(@operator) || %i[* /].include?(operator) || @in_brackets
      end

      def evaluate
        @left.evaluate.send(@operator, @right.evaluate)
      end

      def inspect
        "Operation.new(#{@operator}, #{@left.inspect}, #{@right.inspect})"
      end
    end

    class Parser
      attr_reader :result

      def initialize(string, in_brackets: false)
        @string = string
        @index = 0
        @result = parse_operand
        while @index < @string.length
          parse_space
          operator = parse_operator
          parse_space
          right = parse_operand
          @result = calc_expression(operator, @result, right)
        end
      end

      protected

      def calc_expression(operator, left, right)
        Operation.new(operator, left, right)
      end

      private

      def next_character
        @string[@index]
      end

      def parse_number
        end_index = @index
        end_index += 1 while /d/ =~ @string[end_index + 1]
        result = Number.new(@string[@index..end_index].to_i)
        @index = end_index + 1
        result
      end

      def parse_bracket_expression
        end_index = @index + 1
        open_brackets = 1
        while open_brackets > 0
          case @string[end_index]
          when '('
            open_brackets += 1
            end_index += 1
          when ')'
            open_brackets -= 1
            end_index += 1 if open_brackets > 0
          else
            end_index += 1
          end
        end
        parser = self.class.new(@string[(@index + 1)..(end_index - 1)])
        result = parser.result
        result.in_brackets = true
        @index = end_index + 1
        result
      end

      def parse_operand
        case next_character
        when /\d/
          parse_number
        when '('
          parse_bracket_expression
        else
          raise "Unexpected next character '#{next_character}'! Expected operand!"
        end
      end

      def parse_space
        raise 'Expected space after operand' unless next_character == ' '

        @index += 1
      end

      def parse_operator
        case next_character
        when '+', '-', '/', '*'
          result = next_character.to_sym
          @index += 1
          result
        else
          raise "Unexpected next character '#{next_character}'! Expected operator!"
        end
      end
    end

    class PlusMinusPrecedenceParser < Parser
      def calc_expression(operator, left, right)
        left_applied_first = Operation.new(operator, left, right)
        return left_applied_first if left.binds_stronger_than?(operator)

        Operation.new(left.operator, left.left, Operation.new(operator, left.right, right))
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input_lines(__FILE__)

      values = data.map { |line| Parser.new(line).result.evaluate }

      puts "1) Solution 1: #{values.sum}"

      values = data.map { |line| PlusMinusPrecedenceParser.new(line).result.evaluate }
      puts "2) Solution 2: #{values.sum}"
    end
  end
end
