# frozen_string_literal: true

require 'io/console'

require_relative 'common'
require_relative 'intcode_computer'

module Task13
  class Game
    attr_reader :score, :ball, :paddle

    def initialize(program)
      @program = program
      @ball = nil
      @paddle = nil
      reset
    end

    def reset
      @computer = IntcodeComputerV3.new(program.dup)
      @tiles = {}
      @score = 0
    end

    def play(input = nil)
      computer.input = input if input
      computer.execute
      update
    end

    def over?
      computer.finished?
    end

    def block_count
      tiles.values.count { |t| t == 2 }
    end

    def render
      puts GameRenderer.new(tiles).render
    end

    private

    PADDLE = 3
    BALL = 4

    SCORE_POSITION = Vector.new(-1, 0)

    attr_reader :program, :computer, :tiles

    def update
      while computer.has_output?
        position = Vector.new(computer.output, computer.output)
        if position == SCORE_POSITION
          @score = computer.output
        else
          current = computer.output
          tiles[position] = current
          case current
          when PADDLE
            @paddle = position
          when BALL
            @ball = position
          end
        end
      end
    end

    class GameRenderer < MapRenderer
      def render_element(element)
        case element
        when 1 # Wall
          'X'
        when 2 # Block
          'o'
        when 3 # Paddle
          '_'
        when 4 # Ball
          '.'
        else
          ' '
        end
      end
    end
  end

  class Player
    attr_reader :game, :render

    def initialize(game, render: false)
      @game = game
      @render = render
      game.play
    end

    def play
      until game.over?
        if render
          sleep 0.01
          puts "\e[H\e[2J"
          puts game.render
        end
        game.play get_player_input
      end
    end

    private

    attr_reader :game

    def get_player_input
      # input = STDIN.getch
      if game.ball.x > game.paddle.x
        1
      elsif game.ball.x < game.paddle.x
        -1
      else
        0
      end
    end
  end

  if $PROGRAM_NAME == __FILE__
    program = read_intcode_program('13')

    game = Game.new(program)
    game.play

    puts "1) Number of block tiles: #{game.block_count}"

    program[0] = 2  # Insert coin

    game = Game.new(program)
    player = Player.new(game)
    player.play
    puts "2) Final score: #{game.score}"
  end
end
