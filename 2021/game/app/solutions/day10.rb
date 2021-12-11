class Day10
  def self.title
    '--- Day 10: Syntax Scoring ---'
  end

  def initialize(state)
    @state = state
    setup
  end

  def tick(args)
    render(args)
    update
    process_inputs(args)
  end

  private

  def setup
    @state.program = read_problem_input('10').split("\n")
    @state.scroll_offset = 0
    @state.syntax_error_columns = {}
    @state.autocompletions = {}
    @state.autocompletion_scores = {}
    @state.processed_index = 0
    @state.syntax_error_score = 0
  end

  def render(args)
    render_source_code(args)
    render_info(args)
  end

  def render_source_code(args)
    args.outputs.primitives << (0..MAX_ROWS - 1).map { |line_index|
      y = 630 - (line_index * 20)
      source_code_line_primitives(@state.scroll_offset + line_index, y: y)
    }
  end

  def source_code_line_primitives(line_index, y:)
    line = @state.program[line_index]
    [
      { x: 40, y: y, text: (line_index + 1).to_s, alignment_enum: 2 }.label!,
      { x: 60, y: y, text: line }.label!
    ].tap { |result|
      if @state.syntax_error_columns.key?(line_index)
        error_char_index = @state.syntax_error_columns[line_index]
        offset = $gtk.calcstringbox(line[0..error_char_index - 1])[0]
        result.unshift({ x: 59 + offset, y: y - 20, w: 10, h: 20, r: 255, g: 0, b: 0 }.solid!)
      elsif @state.autocompletions.key?(line_index)
        offset = $gtk.calcstringbox(line)[0]
        result << { x: 59 + offset, y: y, text: @state.autocompletions[line_index], r: 0, g: 128, b: 0 }.label!
      end
    }
  end

  def render_info(args)
    args.outputs.primitives << top_right_labels(
      "Syntax error score: #{@state.syntax_error_score}",
      "Median autocompletion score: #{median_autocompletion_score}"
    )
  end

  def update
    return if @state.processed_index >= @state.program.size

    check_line
    @state.processed_index += 1
  end

  def check_line
    expected_brackets = []
    @state.program[@state.processed_index].each_char.with_index do |char, index|
      if [')', ']', '}', '>'].include?(char)
        next if char == expected_brackets.pop

        @state.syntax_error_columns[@state.processed_index] = index
        @state.syntax_error_score += ILLEGAL_CHAR_POINTS[char]
        expected_brackets.clear
        break
      end

      expected_brackets << CLOSING_BRACKETS[char]
    end
    return if expected_brackets.empty?

    @state.autocompletions[@state.processed_index] = expected_brackets.reverse.join
    @state.autocompletion_scores[@state.processed_index] = calc_autocompletion_score(
      @state.autocompletions[@state.processed_index]
    )
  end

  CLOSING_BRACKETS = {
    '(' => ')',
    '[' => ']',
    '{' => '}',
    '<' => '>'
  }.freeze

  ILLEGAL_CHAR_POINTS = {
    ')' => 3,
    ']' => 57,
    '}' => 1197,
    '>' => 25_137
  }.freeze

  def calc_autocompletion_score(autocompletion)
    autocompletion.each_char.inject(0) { |result, char|
      (result * 5) + AUTOCOMPLETION_SCORES[char]
    }
  end

  AUTOCOMPLETION_SCORES = {
    ')' => 1,
    ']' => 2,
    '}' => 3,
    '>' => 4
  }.freeze

  def median_autocompletion_score
    @state.autocompletion_scores.values.sort[@state.autocompletion_scores.size.idiv(2)]
  end

  def process_inputs(args)
    @state.scroll_offset = (
      @state.scroll_offset - get_vertical_scroll_input(args.inputs)
    ).clamp(0, @state.program.size - MAX_ROWS - 1)
  end

  MAX_ROWS = 31
end

SOLUTIONS[10] = Day10
