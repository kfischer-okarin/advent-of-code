# frozen_string_literal: true

require_relative '../../lib/2020/13'

module AOC2020
  module Task13
    RSpec.describe Task13 do
      describe PrimeFactors do
        describe '.from' do
          it 'calculates the factors of the number' do
            expect(PrimeFactors.from(3 * 3 * 4)).to(have_attributes(factors: { 3 => 2, 2 => 2 }))
          end
        end

        describe '#number' do
          it 'calculates the number' do
            factors = PrimeFactors.new({ 2 => 3, 3 => 2 })
            expect(factors.number).to eq(2**3 * 3**2)
          end
        end

        describe '#common_with' do
          it 'calculates the common factors' do
            factors = PrimeFactors.new({ 2 => 3, 3 => 2 })
            other_factors = PrimeFactors.new({ 2 => 2, 3 => 1, 4 => 1 })
            common = factors.common_with other_factors
            expect(common.factors).to eq({ 2 => 2, 3 => 1 })
          end
        end
      end

      describe TimestampFinder do
        [
          ['17,x,13,19', 3417],
          ['67,7,59,61', 754_018],
          ['67,x,7,59,61', 779_210],
          ['67,7,x,59,61', 1_261_476],
          ['1789,37,47,1889', 1_202_161_486]
        ].each do |(data, result)|
          it 'calculates the correct result' do
            finder = TimestampFinder.parse(['', data])
            finder.find
            expect(finder.result).to eq result
          end
        end
      end
    end
  end
end
