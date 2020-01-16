require_relative '../lib/02'

RSpec.describe '02' do
  let(:computer) { IntcodeComputer.new(program) }

  let(:memory) { computer.memory }


  before do
    computer.execute
  end

  context 'Example 1' do
    let(:program) {
      [
        1, 9, 10, 3,
        2, 3, 11, 0,
        99,
        30, 40, 50
      ]
    }

    it 'produces the right state' do
      expect(memory).to eq [
        3500,9,10,70,
        2,3,11,0,
        99,
        30,40,50
      ]
    end
  end

  context 'Example 2' do
    let(:program) {
      [
        1,0,0,0,
        99
      ]
    }

    it 'produces the right state' do
      expect(memory).to eq [
        2,0,0,0,99
      ]
    end
  end

  context 'Example 3' do
    let(:program) {
      [
        2,3,0,3,
        99
      ]
    }

    it 'produces the right state' do
      expect(memory).to eq [
        2,3,0,6,99
      ]
    end
  end

  context 'Example 4' do
    let(:program) {
      [
        2,4,4,5,
        99,
        0
      ]
    }

    it 'produces the right state' do
      expect(memory).to eq [
        2,4,4,5,99,9801
      ]
    end
  end

  context 'Example 5' do
    let(:program) {
      [
        1,1,1,4,
        99,
        5,6,0,99
      ]
    }

    it 'produces the right state' do
      expect(memory).to eq [
        30,1,1,4,2,5,6,0,99
      ]
    end
  end
end
