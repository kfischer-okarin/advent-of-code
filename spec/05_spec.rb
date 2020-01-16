require_relative '../lib/05'

RSpec.describe '05' do
  let(:computer) { IntcodeComputerV2.new(program) }

  let(:output) { computer.output }


  before do
    computer.input = input
    computer.execute
  end

  shared_examples 'it returns' do |result, for_inputs:|
    for_inputs.each do |n|
      context "input is #{n}" do
        let(:input) { n }

        it "returns #{result}" do
          expect(output).to eq result
        end
      end
    end
  end

  context 'Example 1 - Equal 8? Position mode' do
    let(:program) {
      [3,9,8,9,10,9,4,9,99,-1,8]
    }

    include_examples 'it returns', 0, for_inputs: (4..7)
    include_examples 'it returns', 1, for_inputs: [8]
    include_examples 'it returns', 0, for_inputs: (9..12)
  end

  context 'Example 2 - Less than 8? Position mode' do
    let(:program) {
      [3,9,7,9,10,9,4,9,99,-1,8]
    }

    include_examples 'it returns', 1, for_inputs: (4..7)
    include_examples 'it returns', 0, for_inputs: (8..12)
  end

  context 'Example 3 - Equal 8? Immediate mode' do
    let(:program) {
      [3,3,1108,-1,8,3,4,3,99]
    }

    include_examples 'it returns', 0, for_inputs: (4..7)
    include_examples 'it returns', 1, for_inputs: [8]
    include_examples 'it returns', 0, for_inputs: (9..12)
  end

  context 'Example 4 - Less than 8? Immediate mode' do
    let(:program) {
      [3,3,1107,-1,8,3,4,3,99]
    }

    include_examples 'it returns', 1, for_inputs: (4..7)
    include_examples 'it returns', 0, for_inputs: (8..12)
  end

  context 'Example 5 - Non Zero? Position mode' do
    let(:program) {
      [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]
    }

    include_examples 'it returns', 0, for_inputs: [0]
    include_examples 'it returns', 1, for_inputs: (-4..-1)
    include_examples 'it returns', 1, for_inputs: (1..4)
  end

  context 'Example 6 - Non Zero? Immediate mode' do
    let(:program) {
      [3,3,1105,-1,9,1101,0,0,12,4,12,99,1]
    }

    include_examples 'it returns', 0, for_inputs: [0]
    include_examples 'it returns', 1, for_inputs: (-4..-1)
    include_examples 'it returns', 1, for_inputs: (1..4)
  end

  context 'Example 7 - around 8' do
    let(:program) {
      [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
        1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
        999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99]
    }

    include_examples 'it returns', 999, for_inputs: [1] #(1..7)
    include_examples 'it returns', 1000, for_inputs: [8]
    include_examples 'it returns', 1001, for_inputs: (9..12)
  end

end
