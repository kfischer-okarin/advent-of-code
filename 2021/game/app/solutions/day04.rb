class Day04
  def self.title
    '--- Day 4: Giant Squid ---'
  end

  def initialize(state)
    @state = state
    setup
  end

  def tick(args)
    render(args)
    process_inputs(args)
    update(args)
  end

  private

  def setup
    input_lines = read_problem_input('04').split("\n")
    @state.random_numbers = input_lines[0].split(',').map(&:to_i)
    @state.bingo_boards = input_lines[1..].each_slice(6).map { |lines|
      build_board(lines[1..])
    }
    @state.announcement_interval = 30
    @state.marked_numbers = []
    @state.last_announced_number = nil
    @state.winning_board = nil
    @state.last_winning_board = nil
    @state.scroll_offset = 0
  end

  def build_board(lines)
    {
      numbers: lines.map { |line|
        line.split.map(&:to_i).map { |number|
          { number: number, marked: false }
        }
      },
      bingo: false,
      score: nil
    }
  end

  def render(args)
    render_last_announced_number(args)
    render_board_scores(args)
    render_bingo_boards(board_canvas(args))
    render_board_canvas(args)
    render_explanation(args)
  end

  def render_last_announced_number(args)
    args.outputs.primitives << {
      x: 640, y: 700, text: @state.last_announced_number.to_s, alignment_enum: 1, size_enum: 8
    }.label!
  end

  def render_board_scores(args)
    if @state.winning_board
      args.outputs.primitives << {
        x: 640, y: 650, text: "Winning Board Score: #{@state.winning_board.score}", alignment_enum: 1
      }.label!
    end
    return unless @state.last_winning_board

    args.outputs.primitives << {
      x: 640, y: 600, text: "Last Winning Board Score: #{@state.last_winning_board.score}", alignment_enum: 1
    }.label!
  end

  def board_canvas(args)
    args.outputs[:board_canvas].tap { |canvas|
      canvas.width = 1280
      canvas.height = BOARD_CANVAS_H
    }
  end

  def render_bingo_boards(gtk_outputs)
    x = 50
    y = BOARD_CANVAS_H - 20
    @state.bingo_boards.each do |board|
      render_bingo_board(gtk_outputs, board, x, y)
      x += 180
      next if x < 1280

      x = 50
      y -= 180
    end
  end

  def render_explanation(args)
    args.outputs.primitives << top_right_labels(
      '↑ ↓ or mouse wheel/trackpad to scroll boards'
    )
  end

  BOARD_H = 180
  BOARD_CANVAS_H = BOARD_H * (100 / 7).ceil
  BOARD_CANVAS_VISIBLE_H = 550

  def render_bingo_board(gtk_outputs, board, x, y)
    gtk_outputs.primitives << board.numbers.map_with_index { |line, number_y|
      line.map_with_index { |number, number_x|
        {
          x: x + (number_x * 30), y: y - (number_y * 30),
          text: number.number.to_s, alignment_enum: 2
        }.label!(number_color(number))
      }
    }
    return unless board.bingo

    if @state.winning_board == board
      render_board_border(gtk_outputs, x, y, r: 255, g: 0, b: 0)
    elsif @state.last_winning_board == board
      render_board_border(gtk_outputs, x, y, r: 0, g: 0, b: 255)
    else
      render_board_border(gtk_outputs, x, y, r: 0, g: 0, b: 0)
    end
  end

  def render_board_border(gtk_outputs, x, y, color)
    gtk_outputs.primitives << { x: x - 30, y: y - 150, w: 160, h: 160 }.border!(color)
  end

  def number_color(number)
    { r: 255, g: 0, b: 0 } if number.marked
  end

  def render_board_canvas(args)
    args.outputs.primitives << [
      {
        x: 0, y: 0, w: 1280, h: BOARD_CANVAS_VISIBLE_H,
        path: :board_canvas,
        source_x: 0, source_y: BOARD_CANVAS_H - BOARD_CANVAS_VISIBLE_H - @state.scroll_offset,
        source_w: 1280, source_h: BOARD_CANVAS_VISIBLE_H
      }.sprite!,
      { x: 0, x2: 1280, y: BOARD_CANVAS_VISIBLE_H, y2: BOARD_CANVAS_VISIBLE_H }.line!
    ]
  end

  def process_inputs(args)
    @state.scroll_offset = (
      @state.scroll_offset - (get_vertical_scroll_input(args.inputs) * 10)
    ).clamp(0, BOARD_CANVAS_H - BOARD_CANVAS_VISIBLE_H)
  end

  def update(args)
    return if @state.last_winning_board

    announce_next_number if args.tick_count.mod_zero? @state.announcement_interval
  end

  def announce_next_number
    @state.marked_numbers << @state.random_numbers.shift
    @state.last_announced_number = @state.marked_numbers.last
    @state.bingo_boards.each do |board|
      mark_board(board)
    end
  end

  def mark_board(board)
    marked_number = board.numbers.flatten.find { |number| number[:number] == @state.last_announced_number }
    marked_number.marked = true if marked_number
    return unless !board.bingo && bingo?(board)

    board.bingo = true
    board.score = score(board)
    @state.winning_board ||= board
    @state.last_winning_board = board if @state.bingo_boards.all?(&:bingo)
  end

  def bingo?(board)
    return true if board.numbers.any? { |line| line.all? { |number| number[:marked] } }

    (0..4).any? { |column_index|
      column = board.numbers.map { |line| line[column_index] }
      column.all? { |number| number[:marked] }
    }
  end

  def score(board)
    sum_of_unmarked_numbers = board.numbers.flatten.inject(0) { |sum, number|
      sum + (number.marked ? 0 : number.number)
    }
    sum_of_unmarked_numbers * @state.last_announced_number
  end
end

SOLUTIONS[4] = Day04
