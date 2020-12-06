# frozen_string_literal: true

require_relative '../common'

module AOC2020
  module Task05
    class BoardingPass
      def self.binary_cut(range, letter)
        case letter
        when 'F', 'L'
          new_end = (range.begin + range.end - 1) / 2
          (range.begin..new_end)
        when 'B', 'R'
          new_begin = (range.begin + range.end + 1) / 2
          (new_begin..range.end)
        end
      end

      def self.parse(boarding_pass_string)
        row = boarding_pass_string[0..6].chars.reduce((0..127)) { |range, letter| binary_cut(range, letter) }.first
        seat = boarding_pass_string[7..].chars.reduce((0..7)) { |range, letter| binary_cut(range, letter) }.first
        new(row, seat)
      end

      def initialize(row, seat)
        @row = row
        @seat = seat
      end

      def id
        @row * 8 + @seat
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input_lines(__FILE__)

      ids = data.map { |boarding_pass_string| BoardingPass.parse(boarding_pass_string).id }.sort

      puts "1) Solution 1: #{ids.last}"

      index_before_missing_seat = ids.size.times.find { |index| ids[index] == ids[index + 1] - 2 }
      missing_seat = ids[index_before_missing_seat] + 1
      puts "2) Solution 2: #{missing_seat}"
    end
  end
end
