# frozen_string_literal: true

require_relative '../../lib/2020/20'

module AOC2020
  module Task20
    RSpec.describe Task20 do
      describe CameraImage do
        let(:lines) {
          [
            '# #',
            '## ',
            ' # '
          ]
        }

        let(:tile) { CameraImage.new(1, lines) }

        it '#top_border' do
          expect(tile.top_border).to eq '# #'
        end

        it '#bottom_border' do
          expect(tile.bottom_border).to eq ' # '
        end

        it '#left_border' do
          expect(tile.left_border).to eq '## '
        end

        it '#right_border' do
          expect(tile.right_border).to eq '#  '
        end

        it 'join_horizontally' do
          joined = CameraImage.join_horizontally([tile, tile])
          expect(joined.lines).to eq ['# ## #', '## ## ', ' #  # ']
        end

        it 'join_vertically' do
          joined = CameraImage.join_vertically([tile, tile])
          expect(joined.lines).to eq ['# #', '## ', ' # ', '# #', '## ', ' # ']
        end

        context '#rotated_left' do
          let(:tile) { CameraImage.new(1, lines).rotated_left }

          it '#top_border' do
            expect(tile.top_border).to eq '#  '
          end

          it '#bottom_border' do
            expect(tile.bottom_border).to eq '## '
          end

          it '#left_border' do
            expect(tile.left_border).to eq '# #'
          end

          it '#right_border' do
            expect(tile.right_border).to eq ' # '
          end
        end
      end
    end
  end
end
