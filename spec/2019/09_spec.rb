require_relative '../../lib/2019/09'

RSpec.describe '09' do
  let(:computer) { IntcodeComputerV3.new(program) }

  let(:output) {
    [].tap { |result|
      result << computer.output while computer.has_output?
    }
  }

  before do
    computer.execute
  end

  context 'Example 1 - self returning' do
    let(:program) {
      [
        109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99
      ]
    }

    it 'returns it self' do
      expect(output).to eq program
    end
  end

  context 'Example 2 - 16 digit number returning' do
    let(:program) {
      [
        1102,34915192,34915192,7,4,7,99,0
      ]
    }

    it 'returns a 16 digit number' do
      expect(output).to eq [1219070632396864]
    end
  end

  context 'Example 3 - large number output' do
    let(:program) {
      [
        104,1125899906842624,99
      ]
    }

    it 'returns the large number' do
      expect(output).to eq [1125899906842624]
    end
  end
end
