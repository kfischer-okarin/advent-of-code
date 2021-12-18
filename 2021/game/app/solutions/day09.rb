require 'lib/render_target.rb'

class Day09
  def self.title
    '--- Day 9: Smoke Basin ---'
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
    @state.heightmap = read_heightmap_from_input

    @heightmap_target = RenderTarget.new(
      :heightmap,
      size: [700, 700],
      x: 150,
      y: 20
    )
    @state.processing_state = :draw_map
    @state.low_points = []
    @state.biggest_basin_sizes = []
    @state.risk_level_sum = 0

    @state.processed_index = 0
    @state.max_index = @state.heightmap.size - 1
    process
  end

  def read_heightmap_from_input
    read_problem_input('09').split("\n").map { |line|
      line.chars.map(&:to_i)
    }
  end

  def render(args)
    @heightmap_target.render(args)
    render_info(args)
  end

  def render_info(args)
    args.outputs.primitives << top_right_labels(
      "Risk level sum: #{@state.risk_level_sum}",
      "Biggest basin size product: #{@state.biggest_basin_sizes.inject(:*)}"
    )
  end

  def update
    return if @state.processing_state == :finished

    process
  end

  def process
    case @state.processing_state
    when :draw_map
      draw_line
    when :find_low_points
      find_low_points
    when :find_basins
      find_and_draw_next_basin
    end

    next_element
  end

  def draw_line
    line = @state.heightmap[@state.processed_index]

    @heightmap_target.primitives.concat(
      line.map_with_index { |height, index|
        rendered_cell_rect(index, @state.processed_index).sprite!(
          path: :pixel, r: height * 25, g: height * 25, b: height * 25
        )
      }
    )
  end

  def find_low_points
    line = @state.heightmap[@state.processed_index]
    y = 700 - ((@state.processed_index + 1) * 7)
    primitives = []
    line.each_with_index do |height, index|
      next unless lower_than_neighbors?(index, @state.processed_index)

      @state.low_points << [index, @state.processed_index]
      @state.risk_level_sum += risk_level(height)
      primitives << rendered_cell_rect(index, @state.processed_index).sprite!(
        path: :pixel, r: 255, g: 0, b: 0
      )
    end

    @heightmap_target.primitives.concat(primitives)
  end

  def lower_than_neighbors?(x, y)
    height = @state.heightmap[y][x]
    neighbors(x, y).all? { |neighbor| height < height_at(neighbor.x, neighbor.y) }
  end

  def risk_level(height)
    height + 1
  end

  def find_and_draw_next_basin
    low_point = @state.low_points[@state.processed_index]
    basin = find_basin(low_point)
    update_biggest_basins(basin)
    @heightmap_target.primitives.concat(
      basin.map { |point|
        rendered_cell_rect(point.x, point.y).sprite!(
          path: :pixel, r: height_at(point.x, point.y) * 25, g: 0, b: 0
        )
      }
    )
  end

  def find_basin(low_point)
    [].tap { |result|
      frontier = [low_point]
      visited = {}
      while frontier.any?
        point = frontier.shift
        result << point
        visited[point] = true
        unvisited_neighbors_in_basin = neighbors(point.x, point.y).select { |neighbor|
          height_at(neighbor.x, neighbor.y) != 9 && !visited.key?(neighbor)
        }

        frontier.concat(unvisited_neighbors_in_basin)
        unvisited_neighbors_in_basin.each do |neighbor|
          visited[neighbor] = true
        end
      end
    }
  end

  def update_biggest_basins(basin)
    @state.biggest_basin_sizes << basin.size
    @state.biggest_basin_sizes.sort!
    @state.biggest_basin_sizes.shift while @state.biggest_basin_sizes.size > 3
  end

  def next_element
    @state.processed_index += 1
    return unless @state.processed_index > @state.max_index

    case @state.processing_state
    when :draw_map
      @state.processing_state = :find_low_points
    when :find_low_points
      @state.processing_state = :find_basins
      @state.max_index = @state.low_points.size - 1
    when :find_basins
      @state.processing_state = :finished
    end

    @state.processed_index = 0
  end

  def neighbors(x, y)
    heightmap = @state.heightmap
    [].tap { |result|
      result << [x - 1, y] if x.positive?
      result << [x + 1, y] if x < heightmap[y].size - 1
      result << [x, y - 1] if y.positive?
      result << [x, y + 1] if y < heightmap.size - 1
    }
  end

  def height_at(x, y)
    @state.heightmap[y][x]
  end

  def rendered_cell_rect(map_x, map_y)
    { x: map_x * 7, y: 700 - ((map_y + 1) * 7), w: 7, h: 7 }
  end
end

SOLUTIONS[9] = Day09
