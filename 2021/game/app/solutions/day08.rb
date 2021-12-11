class Day08
  def self.title
    '--- Day 8: Seven Segment Search ---'
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
    @state.displays = read_displays_from_input
    @state.index = -1
    @state.number_of_uniquely_identifiable_outputs = calc_number_of_uniquely_identifiable_outputs
    @state.sum_of_outputs = 0
    next_display
  end

  def read_displays_from_input
    read_problem_input('08').split("\n").map { |line|
      parts = line.split
      {
        signal_patterns: parts[0..9].map { |segments| sorted_letters(segments) },
        outputs: parts[11..14].map { |segments| sorted_letters(segments) }
      }
    }
  end

  def sorted_letters(string)
    string.chars.sort
  end

  def calc_number_of_uniquely_identifiable_outputs
    all_outputs.select { |segments| uniquely_identifiable?(segments) }.length
  end

  def all_outputs
    @state.displays.map(&:outputs).flatten(1)
  end

  def uniquely_identifiable?(segments)
    [2, 3, 4, 7].include?(segments.length)
  end

  def next_display
    @state.index += 1
    return if @state.index >= @state.displays.length

    @state.current_display = @state.displays[@state.index]
    @state.mapping_possibilities = build_mapping_possibilities
    next_mapping
  end

  def build_mapping_possibilities
    conditions = [matches_digit1, matches_digit7, matches_digit4]
    [].tap { |result|
      ALL_SEGMENTS.permutation(7) do |mapping|
        next unless conditions.all? { |condition| condition.call(mapping) }

        result << mapping
      end
    }
  end

  def matches_digit1
    pattern_with_length_will_map_to_segments(2, %w[c f])
  end

  def matches_digit7
    pattern_with_length_will_map_to_segments(3, %w[a c f])
  end

  def matches_digit4
    pattern_with_length_will_map_to_segments(4, %w[b c d f])
  end

  def pattern_with_length_will_map_to_segments(length, segments)
    pattern = find_pattern_with_length(length)
    mapping_indexes = pattern.map { |segment| ALL_SEGMENTS.index(segment) }
    ->(mapping) { mapping_indexes.all? { |index| segments.include? mapping[index] } }
  end

  def find_pattern_with_length(length)
    @state.current_display.signal_patterns.find { |pattern| pattern.length == length }
  end

  def next_mapping
    return if @state.mapping_possibilities.empty?

    @state.mapping = @state.mapping_possibilities.shift
  end

  def render(args)
    render_info(args)
    render_signal_patterns(args)
    render_decoded_signal_patterns(args)
    render_decoded_output(args)
  end

  def render_info(args)
    args.outputs.primitives << top_right_labels(
      "Uniquely identifiable outputs: #{@state.number_of_uniquely_identifiable_outputs}",
      "Sum of outputs: #{@state.sum_of_outputs} (#{@state.index} / #{@state.displays.length})"
    )
  end

  def render_signal_patterns(args)
    args.outputs.primitives << pattern_list_primitives(
      @state.current_display.signal_patterns,
      x: 20,
      y: 150
    )
  end

  def render_decoded_signal_patterns(args)
    args.outputs.primitives << pattern_list_primitives(
      decode_patterns(@state.current_display.signal_patterns),
      x: 20,
      y: 20,
      r: 128
    )
  end

  def render_decoded_output(args)
    args.outputs.primitives << pattern_list_primitives(
      decode_patterns(@state.current_display.outputs),
      x: 700,
      y: 20,
      r: 128
    )
  end

  def pattern_list_primitives(pattern_list, x:, y:, **values)
    pattern_list.map_with_index { |pattern, index|
      pattern_segments_primitives(pattern, x: x + (index * 60), y: y, **values)
    }.flatten(1)
  end

  def decode_patterns(segment_patterns)
    mapping = mapping_as_hash
    segment_patterns.map { |pattern|
      pattern.map { |segment| mapping[segment] }.sort
    }
  end

  def mapping_as_hash
    ALL_SEGMENTS.zip(@state.mapping).to_h
  end

  def pattern_segments_primitives(segments, x:, y:, **values)
    result = ALL_SEGMENTS.map { |segment|
      segment_rect(segment, x: x, y: y).border!(a: 64, **values)
    }

    result.concat(
      segments.map { |segment|
        segment_rect(segment, x: x, y: y).solid!(**values)
      }
    )

    result
  end

  def segment_rect(segment, x:, y:)
    case segment
    when 'g'
      { x: x + 10, y: y, w: 30, h: 10 }
    when 'd'
      { x: x + 10, y: y + 40, w: 30, h: 10 }
    when 'a'
      { x: x + 10, y: y + 80, w: 30, h: 10 }
    when 'e'
      { x: x, y: y + 10, w: 10, h: 30 }
    when 'b'
      { x: x, y: y + 50, w: 10, h: 30 }
    when 'f'
      { x: x + 40, y: y + 10, w: 10, h: 30 }
    when 'c'
      { x: x + 40, y: y + 50, w: 10, h: 30 }
    end
  end

  def update
    return if @state.index >= @state.displays.length

    if correct_mapping?
      @state.sum_of_outputs += decoded_output_value
      next_display
    else
      next_mapping
    end
  end

  def correct_mapping?
    patterns = @state.current_display.signal_patterns
    decoded_patterns = decode_patterns(patterns).sort
    decoded_patterns == CORRECT_PATTERNS
  end

  def decoded_output_value
    result = 0
    decode_patterns(@state.current_display.outputs).each do |output|
      result *= 10
      result += PATTERN_VALUES[output]
    end
    result
  end

  ALL_SEGMENTS = 'abcdefg'.chars.freeze

  PATTERN_VALUES = {
    %w[a b c e f g].freeze => 0,
    %w[c f].freeze => 1,
    %w[a c d e g].freeze => 2,
    %w[a c d f g].freeze => 3,
    %w[b c d f].freeze => 4,
    %w[a b d f g].freeze => 5,
    %w[a b d e f g].freeze => 6,
    %w[a c f].freeze => 7,
    %w[a b c d e f g].freeze => 8,
    %w[a b c d f g].freeze => 9
  }.freeze

  CORRECT_PATTERNS = PATTERN_VALUES.keys.sort.freeze
end

SOLUTIONS[8] = Day08
