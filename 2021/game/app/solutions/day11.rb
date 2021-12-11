class Day11
  def self.title
    '--- Day 11: Dumbo Octopus ---'
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
    @state.energy_levels = read_map_from_input
    @state.steps = 0
    @state.phase = :increase_energy
    @state.flashes = 0
    @state.flashed = {}
    @state.flashes_after_100_steps = nil
  end

  def read_map_from_input
    read_problem_input('11').split("\n").map { |line|
      line.chars.map(&:to_i)
    }
  end

  def render(args)
    render_octopuses(args)
    render_info(args)
  end

  def render_octopuses(args)
    x_offset = 150
    y_offset = 20
    args.outputs.primitives << @state.energy_levels.map_with_index { |row, row_index|
      row.map_with_index { |energy, column_index|
        {
          x: x_offset + (column_index * 70), y: y_offset + (row_index * 70), w: 70, h: 70,
          path: :pixel
        }.solid!(COLORS[energy.clamp(0, 10)])
      }
    }
  end

  def render_info(args)
    args.outputs.primitives << top_right_labels(
      "Steps: #{@state.steps}",
      "Flashes: #{@state.flashes}",
      "Flashes after 100 steps: #{@state.flashes_after_100_steps}"
    )
  end

  COLORS = [
    { r: 0x00, g: 0x00, b: 0x00 },
    { r: 0x00, g: 0x1d, b: 0x2a },
    { r: 0x00, g: 0x34, b: 0x44 },
    { r: 0x00, g: 0x4d, b: 0x5b },
    { r: 0x00, g: 0x68, b: 0x6c },
    { r: 0x00, g: 0x83, b: 0x77 },
    { r: 0x00, g: 0x9e, b: 0x7b },
    { r: 0x41, g: 0xb9, b: 0x79 },
    { r: 0x7a, g: 0xd3, b: 0x73 },
    { r: 0xb4, g: 0xea, b: 0x6b },
    { r: 0xf2, g: 0xff, b: 0x66 }
  ].map(&:freeze).freeze

  def update
    case @state.phase
    when :increase_energy
      increase_energy
      @state.phase = :flashing
    when :flashing
      flashing = new_flashing_octopuses
      if flashing.empty?
        @state.phase = :reset_flashed_octopuses
      else
        @state.flashes += flashing.size
        flashing.each do |position|
          increase_neighbor_energy(position)
          @state.flashed[position] = true
        end
      end
    when :reset_flashed_octopuses
      next_phase = @state.flashed.size == 100 ? :finished : :increase_energy
      @state.flashed.each_key do |position|
        @state.energy_levels[position.y][position.x] = 0
      end
      @state.flashed.clear
      @state.phase = next_phase
      @state.steps += 1
      @state.flashes_after_100_steps = @state.flashes if @state.steps == 100
    end
  end

  def increase_energy
    @state.energy_levels.map! { |row|
      row.map { |energy| energy + 1 }
    }
  end

  def new_flashing_octopuses
    [].tap { |result|
      @state.energy_levels.each_with_index do |row, row_index|
        row.each_with_index do |energy, column_index|
          position = [column_index, row_index]
          next if @state.flashed[position]
          next unless energy > 9

          result << position
        end
      end
    }
  end

  def increase_neighbor_energy(position)
    neighbors(position).each do |neighbor|
      x, y = neighbor
      @state.energy_levels[y][x] += 1
    end
  end

  def neighbors(position)
    x, y = position
    not_left = x.positive?
    not_right = x < @state.energy_levels.size - 1
    [].tap { |result|
      if y < @state.energy_levels.size - 1
        result << [x, y + 1]
        result << [x + 1, y + 1] if not_right
        result << [x - 1, y + 1] if not_left
      end

      if y.positive?
        result << [x, y - 1]
        result << [x + 1, y - 1] if not_right
        result << [x - 1, y - 1] if not_left
      end

      result << [x + 1, y] if not_right
      result << [x - 1, y] if not_left
    }
  end
end

SOLUTIONS[11] = Day11
