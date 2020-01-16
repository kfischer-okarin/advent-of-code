require_relative '../lib/03'

RSpec.describe '03' do
  let(:grid) { Task03::WireGrid.new }

  before do
    grid.start_wire 1
    wire1.each { |segment| grid.draw segment }
    grid.start_wire 2
    wire2.each { |segment| grid.draw segment }
  end

  context 'Example 1' do
    let(:wire1) {
      %w[R8 U5 L5 D3]
    }
    let(:wire2) {
      %w[U7 R6 D4 L4]
    }

    it 'returns the right distance' do
      expect(grid.closest_crossing_distance).to eq 6
    end

    it 'returns the right steps' do
      expect(grid.closest_crossing_steps).to eq 30
    end
  end

  context 'Example 2' do
    let(:wire1) {
      %w[R75 D30 R83 U83 L12 D49 R71 U7 L72]
    }
    let(:wire2) {
      %w[U62 R66 U55 R34 D71 R55 D58 R83]
    }

    it 'returns the right distance' do
      expect(grid.closest_crossing_distance).to eq 159
    end

    it 'returns the right steps' do
      expect(grid.closest_crossing_steps).to eq 610
    end
  end

  context 'Example 3' do
    let(:wire1) {
      %w[R98 U47 R26 D63 R33 U87 L62 D20 R33 U53 R51]
    }
    let(:wire2) {
      %w[U98 R91 D20 R16 D67 R40 U7 R15 U6 R7]
    }

    it 'returns the right distance' do
      expect(grid.closest_crossing_distance).to eq 135
    end

    it 'returns the right steps' do
      expect(grid.closest_crossing_steps).to eq 410
    end
  end
end
