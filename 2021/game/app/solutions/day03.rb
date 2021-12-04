require 'lib/bresenham.rb'
require 'lib/button.rb'

class Day03
  def self.title
    '--- Day 3: Binary Diagnostic ---'
  end

  def initialize(state)
    @state = state
    setup
  end

  def tick(args)
    render(args)
    update
  end

  private

  def setup
    @state.dianostic_report = read_problem_input('03').split("\n")
    @state.one_counts = [0] * @state.dianostic_report[0].size
    @state.index = -1
    @state.offset = 0
  end

  def render(args)
    render_inputs(args)
    render_outputs(args)
  end

  def render_inputs(args)
    current_index = @state.index
    start_index = [current_index - 5, 0].max
    end_index = [current_index + 5, @state.dianostic_report.size - 1].min
    args.outputs.primitives << (start_index..end_index).map { |index|
      input_label(text: @state.dianostic_report[index], offset: ((current_index - index) * 50) + @state.offset)
    }
    args.outputs.primitives << { x: 850, y: 340, w: 220, h: 45, r: 255, g: 0, b: 0 }.border!
  end

  def input_label(text:, offset:)
    {
      x: 960, y: 360 + offset,
      text: text, size_enum: 8 - (offset.abs / 100),
      alignment_enum: 1, vertical_alignment_enum: 1,
      a: 255 - offset.abs
    }.label!
  end

  def render_outputs(args)
    args.outputs.primitives << [
      { x: 200, y: 600, text: 'Gamma Rate:', alignment_enum: 1 }.label!,
      { x: 200, y: 550, text: gamma_rate_bits, alignment_enum: 1, size_enum: 8 }.label!,
      { x: 200, y: 500, text: "(#{decimal_value(gamma_rate_bits)})", alignment_enum: 1 }.label!,
      { x: 200, y: 400, text: 'Epsilon Rate:', alignment_enum: 1 }.label!,
      { x: 200, y: 350, text: epsilon_rate_bits, alignment_enum: 1, size_enum: 8 }.label!,
      { x: 200, y: 300, text: "(#{decimal_value(epsilon_rate_bits)})", alignment_enum: 1 }.label!,
      { x: 200, y: 200, text: 'Power Consumption:', alignment_enum: 1 }.label!,
      { x: 200, y: 170, text: power_consumption.to_s, alignment_enum: 1 }.label!,
    ]
  end

  def gamma_rate_bits
    @state.one_counts.map { |count|
      if count > @state.index.half
        '1'
      elsif count < @state.index.half
        '0'
      else
        '?'
      end
    }.join
  end

  def epsilon_rate_bits
    @state.one_counts.map { |count|
      if count > @state.index.half
        '0'
      elsif count < @state.index.half
        '1'
      else
        '?'
      end
    }.join
  end

  def decimal_value(bits)
    return '???' if bits.chars.any? { |char| char == '?' }

    bits.chars.reduce(0) { |result, bit| (result * 2) + bit.to_i }
  end

  def power_consumption
    gamma_rate = decimal_value(gamma_rate_bits)
    epsilon_rate = decimal_value(epsilon_rate_bits)
    return '???' if gamma_rate == '???' || epsilon_rate == '???'

    gamma_rate * epsilon_rate
  end

  def update
    update_input_position
  end

  def update_input_position
    return if @state.index >= @state.dianostic_report.size

    @state.offset += 40
    while @state.offset >= 50
      @state.index += 1
      @state.offset -= 50
      process_entry
    end
  end

  def process_entry
    return if @state.index >= @state.dianostic_report.size

    @state.dianostic_report[@state.index].each_char.with_index do |char, index|
      @state.one_counts[index] += 1 if char == '1'
    end
  end
end

SOLUTIONS[3] = Day03
