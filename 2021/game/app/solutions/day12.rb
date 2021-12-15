require 'lib/graph_layout.rb'

class Day12
  def self.title
    '--- Day 12: Passage Pathing ---'
  end

  def initialize(state)
    @state = state
    setup
  end

  def tick(args)
    render(args)
    update(args)
  end

  private

  def setup(part: 1, input: :sample_input1)
    @state.input = input
    @state.part = part
    @state.nodes = parse_nodes send(input)
    @state.pathfinder = pathfinder_class_for_part(@state.part).new(@state.nodes)
    @layouter = GraphLayout.new CaveGraph.new(@state.nodes), display_size: 550
    @state.state = :graph_balancing
    @state.path_count = 0
    @state.latest_path = nil
    light_green = { r: 230, g: 255, b: 230 }
    @state.buttons = [
      Button.new(
        id: :part1,
        rect: { x: 1200, y: 10, w: 30, h: 30 },
        label: '1',
        color: @state.part == 1 ? light_green : nil,
        click_handler: ->(_args, _button) { setup(part: 1, input: @state.input) }
      ),
      Button.new(
        id: :part2,
        rect: { x: 1240, y: 10, w: 30, h: 30 },
        label: '2',
        color: @state.part == 2 ? light_green : nil,
        click_handler: ->(_args, _button) { setup(part: 2, input: @state.input) }
      ),
      Button.new(
        id: :sample_input1,
        rect: { x: 10, y: 10, w: 100, h: 30 },
        label: 'Sample 1',
        color: @state.input == :sample_input1 ? light_green : nil,
        click_handler: ->(_args, _button) { setup(part: @state.part, input: :sample_input1) }
      ),
      Button.new(
        id: :sample_input1,
        rect: { x: 120, y: 10, w: 100, h: 30 },
        label: 'Sample 2',
        color: @state.input == :sample_input2 ? light_green : nil,
        click_handler: ->(_args, _button) { setup(part: @state.part, input: :sample_input2) }
      ),
      Button.new(
        id: :sample_input1,
        rect: { x: 230, y: 10, w: 100, h: 30 },
        label: 'Sample 3',
        color: @state.input == :sample_input3 ? light_green : nil,
        click_handler: ->(_args, _button) { setup(part: @state.part, input: :sample_input3) }
      ),
      Button.new(
        id: :sample_input1,
        rect: { x: 340, y: 10, w: 90, h: 30 },
        label: 'Puzzle',
        color: @state.input == :puzzle_input ? light_green : nil,
        click_handler: ->(_args, _button) { setup(part: @state.part, input: :puzzle_input) }
      )
    ]
  end

  def pathfinder_class_for_part(part)
    part == 2 ? PathfinderPart2 : PathfinderPart1
  end

  def parse_nodes(input)
    {}.tap { |result|
      input.split("\n").each do |line|
        cave1, cave2 = line.split('-')
        result[cave1] ||= new_node(cave1)
        result[cave1].neighbors << cave2
        result[cave2] ||= new_node(cave2)
        result[cave2].neighbors << cave1
      end
    }
  end

  def new_node(name)
    {
      name: name,
      neighbors: [],
      rect: initial_rect(name),
      fixed: %w[start end].include?(name),
      big: uppercase?(name)
    }.tap { |node|
      rect = node.rect
      node.center = { x: rect.x + rect.w.idiv(2), y: rect.y + rect.h.idiv(2) }
    }
  end

  def initial_rect(name)
    size = $gtk.calcstringbox(name)
    padding = uppercase?(name) ? 20 : 10
    size.x += padding
    size.y += padding
    x, y = initial_position(name, size)
    { x: x, y: y, w: size.x, h: size.y }
  end

  def initial_position(name, size)
    case name
    when 'start' then [200, 360 - size.y.idiv(2)]
    when 'end' then [1080 - size.x, 360 - size.y.idiv(2)]
    else [20 + rand(1280 - size.x - 10 - 40), rand(720 - size.y - 10 - 40)]
    end
  end

  def sample_input1
    <<~INPUT
      start-A
      start-b
      A-c
      A-b
      b-d
      A-end
      b-end
    INPUT
  end

  def sample_input2
    <<~INPUT
      dc-end
      HN-start
      start-kj
      dc-start
      dc-HN
      LN-dc
      HN-end
      kj-sa
      kj-HN
      kj-dc
    INPUT
  end

  def sample_input3
    <<~INPUT
      fs-end
      he-DX
      fs-he
      start-DX
      pj-DX
      end-zg
      zg-sl
      zg-pj
      pj-he
      RW-he
      fs-DX
      pj-RW
      zg-RW
      start-pj
      he-WI
      zg-he
      pj-fs
      start-RW
    INPUT
  end

  def puzzle_input
    read_problem_input('12')
  end

  # Interface wrapper for GraphLayout
  class CaveGraph
    class Node
      attr_reader :data

      def initialize(data)
        @data = data
      end

      def x
        @data.center.x
      end

      def x=(value)
        @data.rect.x = value - @data.rect.w.idiv(2)
        @data.center.x = value
      end

      def y
        @data.center.y
      end

      def y=(value)
        @data.rect.y = value - @data.rect.h.idiv(2)
        @data.center.y = value
      end

      def fixed?
        @data.fixed
      end
    end

    def initialize(original_nodes_by_name)
      @nodes_by_name = original_nodes_by_name.transform_values { |node| Node.new(node) }
    end

    def nodes
      @nodes_by_name.values
    end

    def neighbors_of(node)
      node_name = node.data.name
      neighbor_names = @nodes_by_name[node_name].data.neighbors
      neighbor_names.map { |name| @nodes_by_name[name] }
    end
  end

  def render(args)
    render_cave(args)
    render_info(args)
    render_select_part_buttons(args)
  end

  def render_cave(args)
    nodes = @state.nodes.values
    args.outputs.primitives << nodes.map { |node| edge_primitives(node) }
    args.outputs.primitives << nodes.map { |node| node_primitives(node) }
  end

  def edge_primitives(node)
    node_center = node.center
    node.neighbors.map { |neighbor_name|
      neighbor = @state.nodes[neighbor_name]
      neighbor_center = neighbor.center
      color = edge_in_latest_path?(node, neighbor) ? { r: 255, g: 64, b: 64 } : { r: 0, g: 0, b: 0 }
      node_center.to_line(
        x2: neighbor_center.x, y2: neighbor_center.y, **color
      )
    }
  end

  def node_primitives(node)
    rect = node.rect
    [
      rect.to_solid(node_color(node)),
      rect.to_border,
      node.center.to_label(
        text: node.name, alignment_enum: 1, vertical_alignment_enum: 1
      )
    ]
  end

  def node_color(node)
    case node.name
    when 'start' then { r: 255, g: 128, b: 0 }
    when 'end' then { r: 128, g: 255, b: 0 }
    else
      if in_latest_path?(node)
        { r: 255, g: 64, b: 64 }
      else
        { r: 255, g: 255, b: 255 }
      end
    end
  end

  def in_latest_path?(node)
    @state.latest_path&.include?(node)
  end

  def edge_in_latest_path?(node1, node2)
    node1_index = @state.latest_path.index(node1)
    return unless node1_index

    node2_index = @state.latest_path.index(node2)
    return unless node2_index

    (node1_index - node2_index).abs == 1
  end

  def render_info(args)
    args.outputs.primitives << top_right_labels(
      @state.state == :graph_balancing ? 'Layouting graph...' : "Paths: #{@state.path_count}"
    )
  end

  def render_select_part_buttons(args)
    @state.buttons.each { |button| button.render(args.outputs) }
  end

  def update(args)
    case @state.state
    when :graph_balancing
      updated = layout_graph(100) # layout_graph(1) for balancing animation
      @state.state = :path_finding unless updated
    when :path_finding
      @state.latest_path = find_next_path
      @state.state = :finished unless @state.latest_path
    end
    handle_buttons(args)
  end

  def layout_graph(max_iterations = 5000)
    iterations = 0
    loop do
      updated = @layouter.layout_graph_step
      break if !updated || iterations > max_iterations

      iterations += 1
    end
    iterations.positive?
  end

  def find_next_path
    result = nil
    @state.pathfinder.steps_per_tick.times do
      result = @state.pathfinder.find_next_path
      break unless result

      @state.path_count += 1
    end
    result
  end

  def uppercase?(string)
    string.upcase == string
  end

  def handle_buttons(args)
    @state.buttons.each { |button| button.tick(args) }
  end

  class PathfinderPart1
    def initialize(nodes)
      @nodes = nodes
      @current_path = [@nodes['start']]
      @neighbors_stack = [neighbors_of(@nodes['start'])]
      @visit_count = { @nodes['start'] => 1 }
    end

    def find_next_path
      return if @neighbors_stack.empty?

      loop do
        remaining_neighbors = nil
        loop do
          remaining_neighbors = @neighbors_stack.pop
          break unless remaining_neighbors.empty?

          exited_node = @current_path.pop
          @visit_count[exited_node] -= 1
          return if @neighbors_stack.empty?
        end

        next_node = remaining_neighbors.shift
        @neighbors_stack << remaining_neighbors
        next unless continue_path?(next_node)
        return @current_path + [next_node] if next_node.name == 'end'

        @current_path << next_node
        @visit_count[next_node] ||= 0
        @visit_count[next_node] += 1
        @neighbors_stack << neighbors_of(next_node)
      end
    end

    def neighbors_of(node)
      node.neighbors.map { |neighbor_name| @nodes[neighbor_name] }
    end

    def continue_path?(next_node)
      next_node.big || (@visit_count[next_node] || 0) < 1
    end

    def steps_per_tick
      case @nodes.size
      when 1..10
        1
      when 11..20
        5
      else
        20
      end
    end
  end

  class PathfinderPart2 < PathfinderPart1
    def continue_path?(next_node)
      visit_count = @visit_count[next_node] || 0
      return true if next_node.big || visit_count.zero?
      return false if next_node.name == 'start'

      @current_path.none? { |node| !node.big && (@visit_count[node] || 0) > 1 }
    end

    def steps_per_tick
      case @nodes.size
      when 1..10
        1
      when 11..20
        20
      else
        500
      end
    end
  end
end

SOLUTIONS[12] = Day12
