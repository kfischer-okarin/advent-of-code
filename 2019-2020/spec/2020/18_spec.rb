# frozen_string_literal: true

require_relative '../../lib/2020/18'

module AOC2020
  module Task18
    RSpec.describe Task18 do
      describe PlusMinusPrecedenceParser do
        [
          ['1 + (2 * 3) + (4 * (5 + 6))', 51],
          ['2 * 3 + (4 * 5)', 46],
          ['5 + (8 * 3 + 9 + 3 * 4 * 3)', 1445],
          ['5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))', 669_060],
          ['((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2', 23_340]
        ].each do |string, result|
          it "calculates correctly: #{string}" do
            result_expression = PlusMinusPrecedenceParser.new(string).result
            expect(result_expression.evaluate).to eq result
          end
        end
      end
    end
  end
end
