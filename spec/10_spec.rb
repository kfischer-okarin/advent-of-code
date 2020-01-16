require_relative '../lib/10'

module Task10
  RSpec.describe '10' do
    describe Vector do
      describe '#unit_length' do
        it 'returns the vector with unit length' do
          expect(Vector.new(4, 8).unit_length).to eq (Vector.new(1, 2))
          expect(Vector.new(0, 8).unit_length).to eq (Vector.new(0, 1))
        end
      end

      describe '#angle' do
        it 'returns the vector angle' do
          expect(Vector.new(0, -1).angle).to eq 0
          expect(Vector.new(1, 0).angle).to eq Math::PI / 2
          expect(Vector.new(0, 1).angle).to eq Math::PI
          expect(Vector.new(-1, 0).angle).to eq 3 * Math::PI / 2
          expect(Vector.new(1, 1).angle).to eq ((2 * Math::PI) - Vector.new(-1, 1).angle)
        end
      end
    end

    describe Asteroid do
      describe '#determine_visibility' do
        context 'Normal neighbors' do
          let(:asteroid_a) { Asteroid.new(Vector.new(1, 1)) }
          let(:asteroid_b) { Asteroid.new(Vector.new(3, 3)) }

          before do
            asteroid_a.determine_visibility asteroid_b
          end

          it 'adds the asteroids as each others neighbor' do
            expect(asteroid_a.neighbors).to eq({ Vector.new(1, 1) => SortedSet.new([Asteroid::Neighbor.new(asteroid_b, 4)]) })
            expect(asteroid_b.neighbors).to eq({ Vector.new(-1, -1) => SortedSet.new([Asteroid::Neighbor.new(asteroid_a, 4)]) })
          end
        end

        context 'Closer neighbor' do
          let(:asteroid_a) { Asteroid.new(Vector.new(1, 1)) }
          let(:asteroid_b) { Asteroid.new(Vector.new(3, 3)) }
          let(:asteroid_c) { Asteroid.new(Vector.new(5, 5)) }

          before do
            asteroid_a.determine_visibility asteroid_c
            asteroid_b.determine_visibility asteroid_c
            asteroid_a.determine_visibility asteroid_b
          end

          it 'adds the asteroids as each others neighbor' do
            expect(asteroid_a.neighbors).to eq({
              Vector.new(1, 1) => SortedSet.new([
                Asteroid::Neighbor.new(asteroid_b, 4),
                Asteroid::Neighbor.new(asteroid_c, 8)
              ])
            })
            expect(asteroid_b.neighbors).to eq({
              Vector.new(-1, -1) => SortedSet.new([Asteroid::Neighbor.new(asteroid_a, 4)]),
              Vector.new(1, 1) => SortedSet.new([Asteroid::Neighbor.new(asteroid_c, 4)])
            })
            expect(asteroid_c.neighbors).to eq({
              Vector.new(-1, -1) => SortedSet.new([
                Asteroid::Neighbor.new(asteroid_b, 4),
                Asteroid::Neighbor.new(asteroid_a, 8)
              ])
            })
          end
        end
      end
    end

    describe Space do
      let(:space) { Space.new(map) }

      describe '#best_asteroid' do
        let(:result) { space.best_asteroid }

        describe 'Example 1' do
          let(:map) {
            [
              '.#..#',
              '.....',
              '#####',
              '....#',
              '...##'
            ]
          }

          it 'is at position 3, 4' do
            expect(result.coordinates).to eq Vector.new(3, 4)
          end

          it 'can see 8 other asteroids' do
            expect(result.neighbor_count).to eq 8
          end
        end

        describe 'Example 2' do
          let(:map) {
            [
              '......#.#.',
              '#..#.#....',
              '..#######.',
              '.#.#.###..',
              '.#..#.....',
              '..#....#.#',
              '#..#....#.',
              '.##.#..###',
              '##...#..#.',
              '.#....####'
            ]
          }

          it 'is at position 5, 8' do
            expect(result.coordinates).to eq Vector.new(5, 8)
          end

          it 'can see 33 other asteroids' do
            expect(result.neighbor_count).to eq 33
          end
        end

        describe 'Example 3' do
          let(:map) {
            [
              '#.#...#.#.',
              '.###....#.',
              '.#....#...',
              '##.#.#.#.#',
              '....#.#.#.',
              '.##..###.#',
              '..#...##..',
              '..##....##',
              '......#...',
              '.####.###.'
            ]
          }

          it 'is at position 1, 2' do
            expect(result.coordinates).to eq Vector.new(1, 2)
          end

          it 'can see 35 other asteroids' do
            expect(result.neighbor_count).to eq 35
          end
        end

        describe 'Example 4' do
          let(:map) {
            [
              '.#..#..###',
              '####.###.#',
              '....###.#.',
              '..###.##.#',
              '##.##.#.#.',
              '....###..#',
              '..#.#..#.#',
              '#..#.#.###',
              '.##...##.#',
              '.....#.#..'
            ]
          }

          it 'is at position 6, 3' do
            expect(result.coordinates).to eq Vector.new(6, 3)
          end

          it 'can see 41 other asteroids' do
            expect(result.neighbor_count).to eq 41
          end
        end

        describe 'Example 5' do
          let(:map) {
            [
              '.#..##.###...#######',
              '##.############..##.',
              '.#.######.########.#',
              '.###.#######.####.#.',
              '#####.##.#.##.###.##',
              '..#####..#.#########',
              '####################',
              '#.####....###.#.#.##',
              '##.#################',
              '#####.##.###..####..',
              '..######..##.#######',
              '####.##.####...##..#',
              '.#####..#.######.###',
              '##...#.##########...',
              '#.##########.#######',
              '.####.#.###.###.#.##',
              '....##.##.###..#####',
              '.#.#.###########.###',
              '#.#.#.#####.####.###',
              '###.##.####.##.#..##'
            ]
          }

          it 'is at position 11, 13' do
            expect(result.coordinates).to eq Vector.new(11, 13)
          end

          it 'can see 210 other asteroids' do
            expect(result.neighbor_count).to eq 210
          end
        end
      end
    end
  end
end
