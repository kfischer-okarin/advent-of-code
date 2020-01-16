require_relative 'common'
require_relative 'intcode_computer'


if $PROGRAM_NAME == __FILE__
  program = read_input_columns('09')[0].map(&:to_i)

  computer = IntcodeComputerV3.new(program)
  computer.input = 1
  computer.execute
  boost_keycode = computer.output
  puts "1) Boost keycode: #{boost_keycode}"

  computer = IntcodeComputerV3.new(program)
  computer.input = 2
  computer.execute
  coordinates = computer.output
  puts "2) Ceres coordinates: #{coordinates}"
end
