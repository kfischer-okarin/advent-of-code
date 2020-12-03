require_relative 'common'
require_relative 'intcode_computer'

module Task15
  class BreadthFirst
    def initialize(map, start)
      @map = map
      @frontier = [start]
      @came_from = { start => nil }
      @cost = { start => 0 }

      explore
    end

    def cost_to(position)
      @cost[position]
    end

    def max_cost
      @cost.values.max
    end

    private

    def explore
      until @frontier.empty?
        current = @frontier.pop

        @map[current].neighbors.keys.each do |direction|
          neighbor = current + direction
          next if @came_from.include? neighbor

          @frontier << neighbor
          @came_from[neighbor] = current
          @cost[neighbor] = @cost[current] + 1
        end
      end
    end
  end

  class RepairRobot
    def initialize(program)
      @computer = IntcodeComputerV3.new(program)
      @position = Vector.new(0, 0)
      @map = {position => Field.new}
      @steps = []
      @oxygen_system_position = nil
    end

    def explore
      loop do
        next_direction = current_field.unexplored_directions.pop

        if next_direction
          moved = move next_direction
          steps << next_direction if moved
        else
          break if steps.empty? # Explored everything

          last_step = steps.pop
          move last_step.negated
        end
      end
    end

    def steps_to_oxygen_system
      breadth_first = BreadthFirst.new(map, Vector.new(0, 0))
      breadth_first.cost_to oxygen_system_position
    end

    def minutes_till_oxygen_is_filled
      breadth_first = BreadthFirst.new(map, oxygen_system_position)
      breadth_first.max_cost
    end

    def render_map
      puts Renderer.new(map).render
    end

    private

    attr_reader :computer, :map, :steps
    attr_accessor :position, :oxygen_system_position

    DIRECTIONS = {
      Vector.new(0, 1) => 1,
      Vector.new(0, -1) => 2,
      Vector.new(-1, 0) => 3,
      Vector.new(1, 0) => 4
    }.freeze

    class Field
      attr_reader :neighbors

      def initialize
        @neighbors = DIRECTIONS.keys.map { |direction| [direction, :unexplored] }.to_h
      end

      def set_neighbor(direction, neighbor)
        neighbors[direction] = neighbor
      end

      def set_wall(direction)
        neighbors.delete direction
      end

      def unexplored_directions
        neighbors.keys.select { |direction| neighbors[direction] == :unexplored }
      end
    end

    def current_field
      map[position]
    end

    def move(direction)
      target_position = position + direction
      computer.input = DIRECTIONS[direction]
      computer.execute
      case computer.output
      when 0
        set_wall target_position
        false
      when 1
        self.position = target_position
        initialize_field target_position
        true
      when 2
        self.position = target_position
        initialize_field position
        self.oxygen_system_position = target_position
        true
      else
        raise RuntimeError.new('Unknown output')
      end
    end

    def set_wall(position)
      map[position] = :wall
      DIRECTIONS.keys.each do |direction|
        neighbor_position = position + direction
        next unless map[neighbor_position].is_a? Field

        map[neighbor_position].set_wall direction.negated
      end
    end

    def initialize_field(position)
      return if map.key? position

      new_field = Field.new
      map[position] = new_field

      DIRECTIONS.keys.each do |direction|
        neighbor_position = position + direction
        neighbor = map[neighbor_position]

        if neighbor.is_a? Field
          new_field.set_neighbor(direction, neighbor)
          neighbor.set_neighbor(direction.negated, new_field)
        elsif neighbor == :wall
          new_field.set_wall direction
        end
      end
    end

    class Renderer < MapRenderer
      def render_element(element)
        case element
        when :wall
          'X'
        else
          ' '
        end
      end
    end
  end


  if $PROGRAM_NAME == __FILE__
    program = read_intcode_program('15')

    robot = RepairRobot.new program
    robot.explore
    puts "1) Shortest steps to oxygen: #{robot.steps_to_oxygen_system}"
    puts "2) Time until oxygen reaches everywhere: #{robot.minutes_till_oxygen_is_filled}"
  end
end
