# frozen_string_literal: true

require 'set'

require_relative '../common'

module AOC2020
  module Task22
    class CardHand
      def self.parse(data)
        lines = data.split("\n")
        new(lines[1..].map(&:to_i))
      end

      attr_reader :cards

      def initialize(cards)
        @cards = cards
      end

      def sub_deck(size)
        CardHand.new(@cards[0...size])
      end

      def number_of_cards
        @cards.size
      end

      def dup
        CardHand.new(cards.dup)
      end

      def empty?
        @cards.empty?
      end

      def ==(other)
        @cards == other.cards
      end

      def eql?(other)
        self == other
      end

      def hash
        @cards.hash
      end

      def play_card
        @cards.shift
      end

      def receive_cards(cards)
        @cards.concat(cards)
      end

      def score
        @cards.reverse_each.with_index.reduce(0) { |result, (value, index)|
          result + value * (index + 1)
        }
      end
    end

    class Combat
      def initialize(player1_hand, player2_hand)
        @player1_hand = player1_hand
        @player2_hand = player2_hand
      end

      def play
        until @player1_hand.empty? || @player2_hand.empty?
          player1_card = @player1_hand.play_card
          player2_card = @player2_hand.play_card
          if player1_card > player2_card
            @player1_hand.receive_cards [player1_card, player2_card]
          else
            @player2_hand.receive_cards [player2_card, player1_card]
          end
        end
      end

      def winner_hand
        @player1_hand.empty? ? @player2_hand : @player1_hand
      end
    end

    class RecursiveCombat
      attr_reader :winner

      def initialize(player1_hand, player2_hand)
        @played_rounds = Set.new
        @player1_hand = player1_hand
        @player2_hand = player2_hand
        @winner = nil
      end

      def play
        loop do
          if round_played_before?
            @winner = :player1
            break
          end
          @played_rounds << current_round
          play_round

          if @player1_hand.empty?
            @winner = :player2
            break
          elsif @player2_hand.empty?
            @winner = :player1
            break
          end
        end
      end

      def winner_hand
        @winner == :player1 ? @player1_hand : @player2_hand
      end

      private

      def current_round
        [@player1_hand.dup, @player2_hand.dup]
      end

      def round_played_before?
        @played_rounds.include? current_round
      end

      def play_round
        player1_card = @player1_hand.play_card
        player2_card = @player2_hand.play_card
        winner = nil
        if @player1_hand.number_of_cards >= player1_card && @player2_hand.number_of_cards >= player2_card
          winner = play_subgame(player1_card, player2_card)
        else
          winner = player1_card > player2_card ? :player1 : :player2
        end

        if winner == :player1
          @player1_hand.receive_cards([player1_card, player2_card])
        else
          @player2_hand.receive_cards([player2_card, player1_card])
        end
      end

      def play_subgame(player1_card, player2_card)
        sub_game = RecursiveCombat.new(@player1_hand.sub_deck(player1_card), @player2_hand.sub_deck(player2_card))
        sub_game.play
        sub_game.winner
      end
    end

    if $PROGRAM_NAME == __FILE__
      player1_data, player2_data = read_input(__FILE__).split("\n\n")
      player1_hand = CardHand.parse(player1_data)
      player2_hand = CardHand.parse(player2_data)
      game = Combat.new(player1_hand, player2_hand)
      game.play

      puts "1) Solution 1: #{game.winner_hand.score}"
      player1_hand = CardHand.parse(player1_data)
      player2_hand = CardHand.parse(player2_data)
      game = RecursiveCombat.new(player1_hand, player2_hand)
      game.play
      puts "2) Solution 2: #{game.winner_hand.score}"
    end
  end
end
