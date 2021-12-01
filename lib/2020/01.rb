# frozen_string_literal: true

require_relative '../common'

module AOC2020
  module Task01
    class ExpenseRecordProcessor
      def initialize(expenses)
        @expenses = expenses
      end

      def solution1
        expense1, expense2 = two_expenses_adding_up_to2020
        expense1 * expense2
      end

      def solution2
        expense1, expense2, expense3 = three_expenses_adding_up_to2020
        expense1 * expense2 * expense3
      end

      private

      def two_expenses_adding_up_to2020
        @expenses.each_with_index do |expense, index|
          @expenses[(index + 1)..].each do |other_expense|
            return [expense, other_expense] if expense + other_expense == 2020
          end
        end
      end

      def three_expenses_adding_up_to2020
        @expenses.each_with_index do |expense, index|
          @expenses[(index + 1)..].each_with_index do |other_expense, index2|
            @expenses[(index + index2 + 1)..].each do |third_expense|
              return [expense, other_expense, third_expense] if expense + other_expense + third_expense == 2020
            end
          end
        end
      end
    end


    if $PROGRAM_NAME == __FILE__
      data = read_input_lines(__FILE__).map(&:to_i)

      processor = ExpenseRecordProcessor.new(data)
      puts "1) Solution 1: #{processor.solution1}"
      puts "2) Solution 2: #{processor.solution2}"
    end
  end
end
