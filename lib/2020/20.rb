# frozen_string_literal: true

require 'set'

require_relative '../common'

module AOC2020
  module Task20
    class CameraImage
      def self.parse(data)
        lines = data.split("\n")
        id = lines[0][5..-2].to_i
        new(id, lines[1..])
      end

      def self.join_horizontally(images)
        lines = images[0].rows.times.map { |row| images.map { |image| image.lines[row] }.join }
        new(nil, lines)
      end

      def self.join_vertically(images)
        lines = images.map(&:lines).reduce([], :+)
        new(nil, lines)
      end

      attr_reader :id, :lines

      def initialize(id, lines)
        @id = id
        @lines = lines
      end

      def rows
        @lines.size
      end

      def columns
        @lines[0].size
      end

      def top_border
        @lines[0]
      end

      def bottom_border
        @lines[-1]
      end

      def left_border
        @left_border ||= vertical_line_at(0)
      end

      def right_border
        @right_border ||= vertical_line_at(-1)
      end

      def fits_top(other)
        top_border == other.bottom_border
      end

      def fits_bottom(other)
        bottom_border == other.top_border
      end

      def fits_left(other)
        left_border == other.right_border
      end

      def fits_right(other)
        right_border == other.left_border
      end

      def vertical_line_at(index)
        @lines.map { |line| line[index] }.join
      end

      def rotated_left
        CameraImage.new(@id, (columns - 1).downto(0).map { |index| vertical_line_at(index) })
      end

      def flipped_horizontally
        CameraImage.new(@id, @lines.map(&:reverse))
      end

      def variations
        result = [self]
        3.times do
          result << result[-1].rotated_left
        end
        result + result.map(&:flipped_horizontally)
      end

      DIRECTIONS = %i[top left bottom right].freeze

      def directions_without_fitting_neighbor(images)
        Set.new(DIRECTIONS.select { |direction|
          images.flat_map(&:variations).none? { |other| send("fits_#{direction}", other) }
        })
      end

      def without_border
        CameraImage.new(@id, @lines[1..-2].map { |line| line[1..-2] } )
      end

      SEA_MONSTER = [
        '                  # ',
        '#    ##    ##    ###',
        ' #  #  #  #  #  #   '
      ].freeze

      def number_of_sea_monsters
        possible_sea_monster_positions.count { |position| sea_monster?(position) }
      end

      def possible_sea_monster_positions
        (0..(columns - SEA_MONSTER[0].size)).flat_map { |x|
          (0..(rows - SEA_MONSTER.size)).map { |y| [x, y] }
        }
      end

      def sea_monster?(position)
        SEA_MONSTER.each_with_index.all? { |row, y|
          row.chars.each_with_index.all? { |char, x|
            next true if char == ' '

            @lines[position[1] + y][position[0] + x] == '#'
          }
        }
      end
    end

    class SatelliteImageReconstructor
      def initialize(images)
        @unplaced = Set.new(images)
        @rows = []
        @current_row = []
        build_rows
      end

      def corner_tiles
        [@rows[0][0], @rows[0][-1], @rows[-1][0], @rows[-1][-1]]
      end

      def result_image
        row_images = @rows.map { |row| CameraImage.join_horizontally(row.map(&:without_border)) }
        CameraImage.join_vertically(row_images)
      end

      private

      def build_rows
        place rotate_to_top_left_corner(unplaced_corner)
        place_next_image until @unplaced.empty?
        finish_row
      end

      def place_next_image
        if @current_row.empty?
          place first_tile_of_row
        else
          next_tile = unplaced_tile_fitting_right
          if next_tile
            place next_tile
          else
            finish_row
          end
        end
      end

      def finish_row
        @rows << @current_row
        @current_row = []
      end

      def first_tile_of_row
        first_tile_of_previous_row = @rows[-1][0]
        @unplaced.flat_map(&:variations).find { |image| first_tile_of_previous_row.fits_bottom(image) }
      end

      def place(placed_image)
        @current_row << placed_image
        @unplaced.reject! { |image| image.id == placed_image.id }
      end

      def unplaced_corner
        @unplaced.find { |image| image.directions_without_fitting_neighbor(@unplaced - [image]).size == 2 }
      end

      def unplaced_tile_fitting_right
        most_right_tile = @current_row[-1]
        @unplaced.flat_map(&:variations).find { |image| most_right_tile.fits_right(image) }
      end

      def rotate_to_top_left_corner(corner_image)
        directions_without_fitting_neighbor = corner_image.directions_without_fitting_neighbor(@unplaced - [corner_image])

        if directions_without_fitting_neighbor == Set[:top, :right]
          corner_image.rotated_left
        elsif directions_without_fitting_neighbor == Set[:bottom, :right]
          corner_image.rotated_left.rotated_left
        elsif directions_without_fitting_neighbor == Set[:bottom, :left]
          corner_image.rotated_left.rotated_left.rotated_left
        else
          corner_image
        end
      end
    end

    if $PROGRAM_NAME == __FILE__
      image_blocks = read_input(__FILE__).split("\n\n")
      images = Set.new(image_blocks.map { |image_block| CameraImage.parse image_block })

      reconstructor = SatelliteImageReconstructor.new(images)

      puts "1) Solution 1: #{reconstructor.corner_tiles.map(&:id).reduce(1, :*)}"

      result_image = reconstructor.result_image
      number_of_sea_monsters = result_image.variations.map(&:number_of_sea_monsters).max
      sea_monster_chars = CameraImage::SEA_MONSTER.map { |row| row.chars.count { |char| char == '#' } }.sum
      total_chars = result_image.lines.map { |row| row.chars.count { |char| char == '#' } }.sum
      puts "2) Solution 2: #{total_chars - number_of_sea_monsters * sea_monster_chars}"
    end
  end
end
