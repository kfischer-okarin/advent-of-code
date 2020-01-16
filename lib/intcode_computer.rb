require 'bigdecimal'

Parameter = Struct.new('Parameter', :value, :mode) do
  def immediate?
    mode == 1
  end

  def relative?
    mode == 2
  end
end

class Operation
  attr_reader :parameter_count

  def initialize(computer, parameter_count)
    @computer = computer
    @parameter_count = parameter_count
  end

  def execute(parameters)
    do_operation(parameters)
    advance_pointer
  end

  protected

  attr_reader :computer

  def advance_pointer
    computer.position += 1 + parameter_count
  end

  def value_of(parameter)
    return parameter.value if parameter.immediate?
    return computer.memory[computer.relative_base + parameter.value] || 0 if parameter.relative?

    computer.memory[parameter.value] || 0
  end

  def assign(value, position_parameter)
    raise if position_parameter.immediate?

    position = position_parameter.value
    position += computer.relative_base if position_parameter.relative?

    computer.memory[position] = value
  end
end

class Addition < Operation
  def initialize(computer)
    super computer, 3
  end

  def do_operation(parameters)
    param1, param2, result_pos = parameters

    assign(value_of(param1) + value_of(param2), result_pos)
  end
end

class Multiplication < Operation
  def initialize(computer)
    super computer, 3
  end

  def do_operation(parameters)
    param1, param2, result_pos = parameters

    assign(value_of(param1) * value_of(param2), result_pos)
  end
end

class IntcodeComputer
  attr_reader :memory
  attr_accessor :position

  def initialize(program)
    @operations = {}
    @memory = Array.new(program)
    @position = 0
    @finished = false

    register_operation 1, Addition.new(self)
    register_operation 2, Multiplication.new(self)
  end

  def input=(input)
    memory[1], memory[2] = input
  end

  def execute
    until finished?
      raise "Unknown opcode at position: #{@position}" unless operation

      operation.execute(parameters)

      finish if exit?
    end
  end

  def output
    memory[0]
  end

  def finished?
    @finished
  end

  protected

  def register_operation(opcode, operation)
    @operations[opcode] = operation
  end

  private

  def finish
    @finished = true
  end

  def current_opcode
    memory[@position]
  end

  def exit?
    current_opcode == 99
  end

  def operation
    @operations[current_opcode % 100]
  end

  def parameters
    (1..operation.parameter_count).map { |k|
      Parameter.new(memory[@position + k], parameter_mode(k))
    }
  end

  def parameter_mode(k)
    decimal_mask = 10 * 10 ** k
    (current_opcode / decimal_mask) % 10
  end
end

class Read < Operation
  class NoInput < Exception; end

  def initialize(computer)
    super computer, 1
  end

  def do_operation(parameters)
    result_pos = parameters[0]

    assign(computer.input, result_pos)
  end
end

class Write < Operation
  def initialize(computer)
    super computer, 1
  end

  def do_operation(parameters)
    output = parameters[0]
    computer.output = value_of(output)
  end
end

class Jump < Operation
  def initialize(computer)
    super computer, 2
  end

  def do_operation(parameters)
    param, jump_pos = parameters
    @next_pos = should_jump?(param) ? value_of(jump_pos) : (computer.position + 3)
  end

  def advance_pointer
    computer.position = @next_pos
  end
end

class JumpIfTrue < Jump
  def should_jump?(param)
    value_of(param) != 0
  end
end

class JumpIfFalse < Jump
  def should_jump?(param)
    value_of(param) == 0
  end
end

class LessThan < Operation
  def initialize(computer)
    super computer, 3
  end

  def do_operation(parameters)
    param1, param2, result_pos = parameters

    assign(value_of(param1) < value_of(param2) ? 1 : 0, result_pos)
  end
end

class Equals < Operation
  def initialize(computer)
    super computer, 3
  end

  def do_operation(parameters)
    param1, param2, result_pos = parameters

    assign(value_of(param1) == value_of(param2) ? 1 : 0, result_pos)
  end
end

class IntcodeComputerV2 < IntcodeComputer
  def initialize(program)
    super program

    @inputs = Queue.new
    @outputs = Queue.new

    register_operation 3, Read.new(self)
    register_operation 4, Write.new(self)
    register_operation 5, JumpIfTrue.new(self)
    register_operation 6, JumpIfFalse.new(self)
    register_operation 7, LessThan.new(self)
    register_operation 8, Equals.new(self)
  end

  def input=(value)
    (Array.try_convert(value) || [value]).each { |v| @inputs << v }
  end

  def input
    raise Read::NoInput if @inputs.empty?

    @inputs.pop
  end

  def output=(value)
    (Array.try_convert(value) || [value]).each { |v| @outputs << v }
  end

  def output
    @outputs.pop
  end

  def has_output?
    !@outputs.empty?
  end
end

class ChangeRelativeBase < Operation
  def initialize(computer)
    super computer, 1
  end

  def do_operation(parameters)
    param = parameters[0]

    computer.relative_base += value_of(param)
  end
end

class IntcodeComputerV3 < IntcodeComputerV2
  def initialize(program)
    super program

    @relative_base = 0

    register_operation 9, ChangeRelativeBase.new(self)
  end

  attr_accessor :relative_base
end
