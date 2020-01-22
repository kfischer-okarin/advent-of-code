require_relative 'common'

module Task12
  Vector3D = Struct.new('Vector3D', :x, :y, :z) do
    def self.parse(string)
      string.gsub!(/[<>]|\w=/, '')
      coordinates = string.split(', ').map(&:to_i)
      new(*coordinates)
    end

    def +(other)
      self.class.new(x + other.x, y + other.y, z + other.z)
    end

    def -(other)
      self.class.new(x - other.x, y - other.y, z - other.z)
    end

    def sign_vector
      self.class.new(sign_of(x), sign_of(y), sign_of(z))
    end

    def abs_sum
      x.abs + y.abs + z.abs
    end

    def inspect
      "<#{x}, #{y}, #{z}>"
    end

    private

    def sign_of(number)
      if number.positive?
        1
      elsif number.negative?
        -1
      else
        0
      end
    end
  end

  class System
    attr_reader :bodies

    def initialize(initial_positions)
      @bodies = initial_positions.map { |p| Body.new(p) }
    end

    def execute_step
      bodies.each do |body|
        other_bodies = bodies.reject { |b| b == body }
        other_bodies.each do |other_body|
          body.apply_gravity other_body
        end
      end

      bodies.each(&:update_position)
    end

    def total_energy
      bodies.map(&:energy).sum
    end

    private

    class Body
      attr_reader :position, :velocity

      def initialize(position)
        @position = position
        @velocity = Vector3D.new(0, 0, 0)
      end

      def apply_gravity(body)
        @velocity += (body.position - position).sign_vector
      end

      def update_position
        @position += velocity
      end

      def energy
        position.abs_sum * velocity.abs_sum
      end
    end
  end

  class RepeatFinder
    attr_reader :steps

    def self.for_all_coordinates(initial_positions)
      %i[x y z].map { |coordinate|
        repeat_finder = new(initial_positions, coordinate)
        repeat_finder.find_loop
        repeat_finder.steps
      }
    end

    def initialize(initial_positions, coordinate)
      @system = System.new(initial_positions)
      @coordinate = coordinate
      @initial_state = current_state
      system.execute_step
      @steps = 1
    end

    def find_loop
      until current_velocities.all?(&:zero?) && current_state == initial_state
        system.execute_step
        self.steps += 1
      end
    end

    private

    attr_writer :steps
    attr_reader :system, :coordinate, :initial_state

    def current_state
      system.bodies.map { |body|
        [body.position.send(coordinate), body.velocity.send(coordinate)]
      }.flatten
    end

    def current_velocities
      system.bodies.map { |body|
        [body.velocity.send(coordinate)]
      }.flatten
    end
  end

  if $PROGRAM_NAME == __FILE__
    position_strings = read_input_lines('12')
    initial_positions = position_strings.map { |s| Vector3D.parse(s) }

    system = System.new(initial_positions)

    1000.times do
      system.execute_step
    end

    puts "1) Total energy after 1000 steps: #{system.total_energy}"

    loop_steps = RepeatFinder.for_all_coordinates(initial_positions)
    p loop_steps

    puts "2) Steps to repeat: #{least_common_multiple(*loop_steps)}"

    # 400128139852752
  end
end
