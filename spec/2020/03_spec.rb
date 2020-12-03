# frozen_string_literal: true

require_relative '../../lib/2020/03'

module AOC2020
  module Task03
    RSpec.describe Task03 do
      let(:map_lines) {
        <<~MAP
          ..##.......
          #...#...#..
          .#....#..#.
          ..#.#...#.#
          .#...##..#.
          ..#.##.....
          .#.#.#....#
          .#........#
          #.##...#...
          #...##....#
          .#..#...#.#
        MAP
      }

      let(:map) { Map.parse(map_lines.split) }

      describe Map do
        describe '#relative_position' do
          it 'calculates correctly' do
            expect(map.relative_position([0, 0], [3, 1])).to eq [3, 1]
          end

          it 'calculates correctly across x border' do
            expect(map.relative_position([9, 3], [3, 1])).to eq [1, 4]
          end
        end

        describe '#tree_at?' do
          it 'returns true for positions with trees' do
            expect(map.tree_at?([2, 0])).to be true
          end

          it 'returns false for positions without trees' do
            expect(map.tree_at?([1, 0])).to be false
          end
        end
      end

      describe Toboggan do
        describe '#travel' do
          let(:toboggan) { Toboggan.new([3, 1]) }

          it 'returns the number of encountered trees' do
            toboggan.travel(map)
            expect(toboggan.trees_encountered).to eq 7
          end
        end
      end
    end
  end
end
