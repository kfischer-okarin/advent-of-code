# frozen_string_literal: true

require 'set'

require_relative '../common'

module AOC2020
  module Task06
    class AnswerGroup
      def self.parse(answer_block)
        new answer_block.split
      end

      def initialize(answers)
        @answers = answers
      end

      def unique_answers_anyone
        Set.new @answers.flat_map(&:chars)
      end

      def unique_answers_everyone
        answer_sets = @answers.map { |answer| Set.new answer.chars }
        answer_sets.reduce(Set.new('a'..'z'), :&)
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input(__FILE__)

      answer_blocks = data.split("\n\n")

      answer_groups = answer_blocks.map { |answer_block| AnswerGroup.parse(answer_block) }

      puts "1) Solution 1: #{answer_groups.map { |answer_group| answer_group.unique_answers_anyone.count }.sum}"
      puts "2) Solution 2: #{answer_groups.map { |answer_group| answer_group.unique_answers_everyone.count }.sum}"
    end
  end
end
