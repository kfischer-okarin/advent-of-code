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
    @state.bit_count = @state.dianostic_report.first.length
    @state.gamma_epsilon_search = build_search(@state.dianostic_report.dup)
    @state.state = :gamma_epsilon_search
  end

  def render(args)
    render_inputs(args)
    render_outputs(args)
  end

  def render_inputs(args)
    case @state.state
    when :gamma_epsilon_search
      render_search(args, @state.gamma_epsilon_search, x: 960)
    when :oxygen_co2_search
      args.outputs.primitives << centered_label(800, 650, 'Oxygen Generator Rating:')
      render_search(args, @state.oxygen_generator_rating_search, x: 800)
      args.outputs.primitives << centered_label(1120, 650, 'CO2 Scrubber Rating:')
      render_search(args, @state.co2_scrubber_rating_search, x: 1120)
    end
  end

  def render_search(args, search, x:)
    current_index = search.index
    start_index = [current_index - 5, 0].max
    end_index = [current_index + 5, search.items.size - 1].min
    args.outputs.primitives << (start_index..end_index).map { |index|
      input_label(x: x, text: search.items[index], offset: ((current_index - index) * 50) + search.offset)
    }
    args.outputs.primitives << { x: x - 110, y: 340, w: 220, h: 45, r: 255, g: 0, b: 0 }.border!
    return unless search.key? :bit

    args.outputs.primitives << { x: x - 100 + (search.bit * 16.5), y: 340, w: 18, h: 45, r: 255, g: 0, b: 0 }.border!
  end

  def input_label(text:, offset:, x:)
    {
      x: x, y: 360 + offset,
      text: text, size_enum: 8 - (offset.abs / 100),
      alignment_enum: 1, vertical_alignment_enum: 1,
      a: 255 - offset.abs
    }.label!
  end

  def render_outputs(args)
    args.outputs.primitives << [
      centered_label(200, 600, 'Gamma Rate:'),
      { x: 200, y: 550, text: gamma_rate_bits, alignment_enum: 1, size_enum: 8 }.label!,
      centered_label(200, 500, "(#{decimal_value(gamma_rate_bits)})"),
      centered_label(200, 400, 'Epsilon Rate:'),
      { x: 200, y: 350, text: epsilon_rate_bits, alignment_enum: 1, size_enum: 8 }.label!,
      centered_label(200, 300, "(#{decimal_value(epsilon_rate_bits)})"),
      centered_label(200, 200, 'Power Consumption:'),
      centered_label(200, 170, power_consumption.to_s)
    ]
    return unless @state.state == :finished

    oxygen_generator_rating = @state.oxygen_generator_rating_search.items.first
    co2_scrubber_rating = @state.co2_scrubber_rating_search.items.first
    args.outputs.primitives << [
      centered_label(500, 600, 'Oxygen Generator Rating:'),
      { x: 500, y: 550, text: oxygen_generator_rating, alignment_enum: 1, size_enum: 8 }.label!,
      centered_label(500, 500, "(#{decimal_value(oxygen_generator_rating)})"),
      centered_label(500, 400, 'CO2 Scrubber Rating:'),
      { x: 500, y: 350, text: co2_scrubber_rating, alignment_enum: 1, size_enum: 8 }.label!,
      centered_label(500, 300, "(#{decimal_value(co2_scrubber_rating)})"),
      centered_label(500, 200, 'Life Support Rating:'),
      centered_label(
        500, 170,
        (decimal_value(oxygen_generator_rating) * decimal_value(co2_scrubber_rating)).to_s
      )
    ]
  end

  def gamma_rate_bits
    search = @state.gamma_epsilon_search
    search.one_counts.map { |count|
      if count > search.index.half
        '1'
      elsif count < search.index.half
        '0'
      else
        '?'
      end
    }.join
  end

  def epsilon_rate_bits
    search = @state.gamma_epsilon_search
    search.one_counts.map { |count|
      if count > search.index.half
        '0'
      elsif count < search.index.half
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
    case @state.state
    when :gamma_epsilon_search
      update_gamma_epsilon_search
    when :oxygen_co2_search
      update_oxygen_generator_rating_search
      update_co2_scrubber_rating_search
      if @state.oxygen_generator_rating_search.items.size == 1 && @state.co2_scrubber_rating_search.items.size == 1
        @state.state = :finished
      end
    end
  end

  def update_gamma_epsilon_search
    update_input_position(@state.gamma_epsilon_search)
    return unless @state.gamma_epsilon_search.index >= @state.gamma_epsilon_search.items.size

    @state.state = :oxygen_co2_search
    @state.oxygen_generator_rating_search = build_oxygen_generator_rating_search(@state.gamma_epsilon_search, bit: 0)
    @state.co2_scrubber_rating_search = build_co2_scrubber_rating_search(@state.gamma_epsilon_search, bit: 0)
  end

  def update_oxygen_generator_rating_search
    search = @state.oxygen_generator_rating_search
    return if search.items.size == 1

    update_input_position(search)
    return unless search.index >= search.items.size

    @state.oxygen_generator_rating_search = build_oxygen_generator_rating_search(search, bit: search.bit)
  end

  def update_co2_scrubber_rating_search
    search = @state.co2_scrubber_rating_search
    return if search.items.size == 1

    update_input_position(search)
    return unless search.index >= search.items.size

    @state.co2_scrubber_rating_search = build_co2_scrubber_rating_search(search, bit: search.bit)
  end

  def update_input_position(search)
    return if search.index >= search.items.size

    search.offset += 140
    while search.offset >= 50
      search.index += 1
      search.offset -= 50
      process_entry(search)
    end
  end

  def process_entry(search)
    return if search.index >= search.items.size

    search.items[search.index].each_char.with_index do |char, index|
      search.one_counts[index] += 1 if char == '1'
    end
  end

  def build_oxygen_generator_rating_search(search, bit:)
    most_common_bit = search.one_counts[bit] >= search.items.size.half ? '1' : '0'
    build_search(
      search.items.select { |item| item[bit] == most_common_bit },
      bit: bit + 1
    )
  end

  def build_co2_scrubber_rating_search(search, bit:)
    least_common_bit = search.one_counts[bit] >= search.items.size.half ? '0' : '1'
    build_search(
      search.items.select { |item| item[bit] == least_common_bit },
      bit: bit + 1
    )
  end

  def build_search(items, bit: nil)
    {
      items: items,
      one_counts: [0] * @state.bit_count,
      index: -1,
      offset: 0
    }.tap { |search| search[:bit] = bit if bit }
  end
end

SOLUTIONS[3] = Day03
