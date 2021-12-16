class Day13
  def self.title
    '--- Day 13: Transparent Origami ---'
  end

  def initialize(state)
    @state = state
    setup
  end

  def tick(args)
    render(args)
    process_input(args)
  end

  private

  def setup
    @state.paper = read_paper_from_input('13')
    recalc_dimensions
  end

  def read_paper_from_input(input)
    lines = read_problem_input(input).split("\n")
    dots = []
    folds = []
    lines.each do |line|
      if line.start_with? 'fold'
        folds << parse_fold(line)
      elsif line.size.positive?
        x, y = line.split(',').map(&:to_i)
        dots << { x: x, y: y }
      end
    end
    { dots: dots, folds: folds }
  end

  def parse_fold(line)
    _, _, axis_and_value = line.split
    axis, value = axis_and_value.split('=')
    { axis: axis.to_sym, value: value.to_i }
  end

  def render(args)
    target = get_paper_target(args)
    render_dots(target)
    render_fold_line(target)
    render_border(target)
    render_paper(args.outputs, target)
    render_info(args)
  end

  def get_paper_target(args)
    args.outputs[:paper].tap { |target|
      target.width = (@state.max_x + 1) * @state.scale
      target.height = (@state.max_y + 1) * @state.scale
    }
  end

  def render_dots(gtk_outputs)
    dot_size = [@state.scale, 1].max
    gtk_outputs.primitives << @state.paper.dots.map { |dot|
      {
        x: dot.x * @state.scale, y: (@state.max_y - dot.y) * @state.scale, w: dot_size, h: dot_size,
        path: :pixel
      }.solid!
    }
  end

  def render_fold_line(gtk_outputs)
    return unless can_be_folded?

    gtk_outputs.primitives << fold_line.line!(r: 255, g: 0, b: 0)
  end

  def fold_line
    next_fold = @state.paper.folds.first
    if next_fold.axis == :x
      value = (next_fold.value * @state.scale) + @state.scale.half
      { x: value, y: 0, x2: value, y2: (@state.max_y + 1) * @state.scale }
    else
      value = ((@state.max_y - next_fold.value) * @state.scale) + @state.scale.half
      { x: 0, y: value, x2: (@state.max_x + 1) * @state.scale, y2: value }
    end
  end

  def render_border(gtk_outputs)
    gtk_outputs.primitives << {
      x: 0, y: 0, w: (@state.max_x + 1) * @state.scale, h: (@state.max_y + 1) * @state.scale
    }.border!
  end

  def render_paper(gtk_outputs, paper)
    gtk_outputs.primitives << { x: 20, y: 20, w: paper.width, h: paper.height, path: :paper }.sprite!
  end

  def render_info(args)
    args.outputs.primitives << top_right_labels(
      "Number of visible dots: #{@state.paper.dots.size}",
      can_be_folded? ? 'Press space to fold paper' : ''
    )
  end

  def process_input(args)
    return unless args.inputs.keyboard.key_down.space && can_be_folded?

    next_fold = @state.paper.folds.shift
    if next_fold.axis == :x
      fold_horizontally(next_fold.value)
    else
      fold_vertically(next_fold.value)
    end
    recalc_dimensions
  end

  def fold_horizontally(value)
    @state.paper.dots.each do |dot|
      next if dot.x < value

      dot.x = (2 * value) - dot.x
    end
    @state.paper.dots.uniq!
  end

  def fold_vertically(value)
    @state.paper.dots.each do |dot|
      next if dot.y < value

      dot.y = (2 * value) - dot.y
    end
    @state.paper.dots.uniq!
  end

  def recalc_dimensions
    @state.max_x = @state.paper.dots.map(&:x).max
    @state.max_y = @state.paper.dots.map(&:y).max
    calc_scale
  end

  def calc_scale
    x_scale = 1240 / (@state.max_x + 1)
    y_scale = 680 / (@state.max_y + 1)
    @state.scale = [x_scale, y_scale].min
  end

  def can_be_folded?
    !@state.paper.folds.empty?
  end
end

SOLUTIONS[13] = Day13
