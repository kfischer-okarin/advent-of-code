# frozen_string_literal: true

require_relative 'common'
require_relative 'intcode_computer'

if $PROGRAM_NAME == __FILE__
  program = read_intcode_program('02')

  computer = IntcodeComputer.new(program)
  computer.input = [12, 2]
  computer.execute
  p "Error program output (12, 2): #{computer.output}"

  def find_inputs_producing(desired_output, program:)
    (0..99).each do |input1|
      (0..99).each do |input2|
        computer = IntcodeComputer.new(program)
        computer.input = [input1, input2]
        computer.execute
        return [input1, input2] if computer.output == desired_output
      end
    end
  end

  target_inputs = find_inputs_producing(19_690_720, program: program)

  p "Inputs producing 19_690_720: #{target_inputs}"
end
