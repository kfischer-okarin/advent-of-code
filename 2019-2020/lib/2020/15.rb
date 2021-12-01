# frozen_string_literal: true

require_relative '../common'

module AOC2020
  module Task15
    class NumberGame
      attr_reader :turn

      def initialize
        @said_in_turns = {}
        @turn = 1
        @last_number = nil
      end

      def say_number(number)
        @said_in_turns[number] ||= []
        @said_in_turns[number] << @turn
        @last_number = number
        @turn += 1
      end

      def next_number
        if @said_in_turns[@last_number].count == 1
          0
        else
          @said_in_turns[@last_number][-1] - @said_in_turns[@last_number][-2]
        end
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = [0, 13, 16, 17, 1, 10, 6]

      number_game = NumberGame.new
      data.each do |start_number|
        number_game.say_number start_number
      end
      number_game.say_number(number_game.next_number) while number_game.turn < 2020

      puts "1) Solution 1: #{number_game.next_number}"

      number_game.say_number(number_game.next_number) while number_game.turn < 30_000_000
      puts "2) Solution 2: #{number_game.next_number}"
    end
  end
end
