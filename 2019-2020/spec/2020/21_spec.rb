# frozen_string_literal: true

require_relative '../../lib/2020/21'

module AOC2020
  module Task21
    RSpec.describe Task21 do
      describe AllergenFinder do
        let(:lines) {
          [
            'mxmxvkd kfcds sqjhc nhms (contains dairy, fish)',
            'trh fvjkl sbzzf mxmxvkd (contains dairy)',
            'sqjhc fvjkl (contains soy)',
            'sqjhc mxmxvkd sbzzf (contains fish)'
          ]
        }

        let(:lists) { lines.map { |line| IngredientList.parse line } }

        let(:finder) { AllergenFinder.new(lists) }

        describe '#safe_ingredients' do
          subject { finder.safe_ingredients }

          it { is_expected.to eq Set['kfcds', 'nhms', 'sbzzf', 'trh'] }
        end

        describe '#safe_ingredient_count' do
          subject { finder.safe_ingredient_count }

          it { is_expected.to eq 5 }
        end
      end
    end
  end
end
