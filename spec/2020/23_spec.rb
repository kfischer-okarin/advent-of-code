# frozen_string_literal: true

require_relative '../../lib/2020/23'

module AOC2020
  module Task23
    RSpec.describe Task23 do
      describe Cup do
        describe 'all_cups' do
          subject { cup.all_cups.map(&:number) }

          context 'when it is ring' do
            let(:cup) {
              Cup.new(3).tap { |root|
                root.neighbor = Cup.new(4)
                root.neighbor.neighbor = Cup.new(9)
                root.neighbor.neighbor.neighbor = root
              }
            }

            it { is_expected.to contain_exactly(3, 4, 9) }
          end

          context 'when it is finite' do
            let(:cup) {
              Cup.new(3).tap { |root|
                root.neighbor = Cup.new(4)
                root.neighbor.neighbor = Cup.new(9)
              }
            }

            it { is_expected.to contain_exactly(3, 4, 9) }
          end
        end

        describe '#remove' do
          subject(:remove) { cup.remove(2) }

          let(:cup) {
            Cup.new(3).tap { |root|
              root.neighbor = Cup.new(4)
              root.neighbor.neighbor = Cup.new(9)
              root.neighbor.neighbor.neighbor = Cup.new(33)
              root.neighbor.neighbor.neighbor.neighbor = root
            }
          }

          it 'returns the removed_items' do
            expect(remove.all_numbers).to contain_exactly(4, 9)
          end

          it 'removes the items' do
            remove

            expect(cup.all_numbers).to contain_exactly(3, 33)
          end
        end

        describe '#all_cups.last' do
          subject { cup.all_cups.to_a.last }

          let(:cup) {
            Cup.new(3).tap { |root|
              root.neighbor = Cup.new(4)
              root.neighbor.neighbor = Cup.new(9)
              root.neighbor.neighbor.neighbor = nil
            }
          }

          it { is_expected.to eq cup.neighbor.neighbor }
        end

        describe '#insert' do
          subject(:insert) { cup.insert(other_cups) }

          let(:cup) {
            Cup.new(3).tap { |root|
              root.neighbor = Cup.new(4)
              root.neighbor.neighbor = Cup.new(9)
              root.neighbor.neighbor.neighbor = Cup.new(33)
              root.neighbor.neighbor.neighbor.neighbor = root
            }
          }

          let(:other_cups) {
            Cup.new(7).tap { |root|
              root.neighbor = Cup.new(77)
              root.neighbor.neighbor = nil
            }
          }

          it 'adds the items' do
            insert

            expect(cup.all_numbers).to contain_exactly(3, 7, 77, 4, 9, 33)
          end
        end
      end
    end
  end
end
