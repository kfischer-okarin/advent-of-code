# frozen_string_literal: true

require_relative '../../lib/2019/09'

RSpec.describe '09' do
  let(:computer) { IntcodeComputerV3.new(program) }

  let(:output) do
    [].tap do |result|
      result << computer.output while computer.has_output?
    end
  end

  before do
    computer.execute
  end

  context 'Example 1 - self returning' do
    let(:program) do
      [
        109, 1, 204, -1, 1001, 100, 1, 100, 1008, 100, 16, 101, 1006, 101, 0, 99
      ]
    end

    it 'returns it self' do
      expect(output).to eq program
    end
  end

  context 'Example 2 - 16 digit number returning' do
    let(:program) do
      [
        1102, 34_915_192, 34_915_192, 7, 4, 7, 99, 0
      ]
    end

    it 'returns a 16 digit number' do
      expect(output).to eq [1_219_070_632_396_864]
    end
  end

  context 'Example 3 - large number output' do
    let(:program) do
      [
        104, 1_125_899_906_842_624, 99
      ]
    end

    it 'returns the large number' do
      expect(output).to eq [1_125_899_906_842_624]
    end
  end
end
