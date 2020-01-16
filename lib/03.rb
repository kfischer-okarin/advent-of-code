require_relative 'common'

module Task03
  Wire = Struct.new('Wire', :type, :distance_from_port)


  class WireGrid
    def initialize
      @positions = {}
      @crossings = {}
    end

    def start_wire(type)
      @distance_from_port = 0
      @position = Vector.new(0, 0)
      @type = type
    end

    def draw(segment)
      direction = segment_direction(segment)
      length = segment_length(segment)
      length.times do |_|
        @position += direction
        @distance_from_port += 1
        set_wire
      end
    end

    def closest_crossing_distance
      @crossings.keys.map { |pos| pos.x.abs + pos.y.abs }.min
    end

    def closest_crossing_steps
      @crossings.values.min
    end

    def print
      min_x = @positions.keys.map { |vec| vec.x }.min
      max_x = @positions.keys.map { |vec| vec.x }.max
      min_y = @positions.keys.map { |vec| vec.y }.min
      max_y = @positions.keys.map { |vec| vec.y }.max
      (min_y..max_y).each do |y|
        line = []
        (min_x..max_x).each do |x|
          pos = Vector.new(x, y)
          if pos == Vector.new(0, 0)
            line << 'O'
          elsif @crossings.key? pos
            line << 'X'
          else
            line << (@positions[pos]&.type || ' ')
            # line << (@positions[pos]&.distance_from_port&.%(10) || ' ')
          end
        end
        p line.join
      end
    end

    private

    def segment_direction(segment)
      case segment[0]
      when 'U'
        Vector.new(0, -1)
      when 'D'
        Vector.new(0, 1)
      when 'L'
        Vector.new(-1, 0)
      when 'R'
        Vector.new(1, 0)
      end
    end

    def segment_length(segment)
      segment[1..].to_i
    end

    def set_wire
      wire = Wire.new(@type, @distance_from_port)

      if @positions.key?(@position)
        other_wire = @positions[@position]
        if other_wire.type != wire.type
          total_distance = other_wire.distance_from_port + wire.distance_from_port
          if !@crossings.key?(@position) || @crossings[@position] > total_distance
            @crossings[@position] = total_distance
          end
        end
        return
      end

      @positions[@position] = wire
    end
  end
end

if $PROGRAM_NAME == __FILE__
  wire1, wire2 = read_input_columns('03')

  grid = Task03::WireGrid.new
  grid.start_wire 1
  wire1.each { |segment| grid.draw segment }
  grid.start_wire 2
  wire2.each { |segment| grid.draw segment }
  p "1) Closest crossing distance: #{grid.closest_crossing_distance}"
  p "2) Shortest crossing cable length: #{grid.closest_crossing_steps}"
end
