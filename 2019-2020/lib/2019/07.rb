# frozen_string_literal: true

require_relative 'common'
require_relative 'intcode_computer'

class AmplifierArray
  def initialize(program)
    @program = program
  end

  def optimize_phase_settings(possible_settings)
    max_output = 0

    possible_settings.each do |settings|
      max_output = [max_output, run_with_settings(settings)].max
    end

    max_output
  end

  private

  attr_accessor :program

  def run_with_settings(phase_settings)
    output = 0

    amplifiers = phase_settings.map do |setting|
      IntcodeComputerV2.new(program).tap do |amplifier|
        amplifier.input = setting
      end
    end

    until amplifiers.all?(&:finished?)
      amplifiers.each do |amplifier|
        amplifier.input = output
        amplifier.execute
        output = amplifier.output
      end
    end

    output
  end
end

if $PROGRAM_NAME == __FILE__
  program = read_intcode_program('07')

  amplifiers = AmplifierArray.new(program)
  highest_signal = amplifiers.optimize_phase_settings([0, 1, 2, 3, 4].permutation)
  puts "1) Highest possible signal: #{highest_signal}"

  highest_signal_feedback = amplifiers.optimize_phase_settings([5, 6, 7, 8, 9].permutation)
  puts "2) Highest possible signal: #{highest_signal_feedback}"
end
