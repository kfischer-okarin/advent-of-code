# frozen_string_literal: true

require 'set'

require_relative '../common'

module AOC2020
  module Task07
    class BagRule
      attr_reader :contains

      def initialize(type)
        @type = type
        @containable_by = {}
        @contains = {}
      end

      def can_be_contained_by(type:, times:)
        @containable_by[type] = times
      end

      def can_contain(type:, times:)
        @contains[type] = times
      end

      def types_that_directly_contain
        Set.new @containable_by.keys
      end
    end

    class BagRules
      def parse_rule(rule)
        type, rest = rule.split(' bags contain')
        rest.scan(/ (.+?) (bags|bag)(,|\.)/) do |match|
          description = match[0]
          next if description == 'no other'

          times = description[0].to_i
          contained_type = description[2..]
          get_rule_for(contained_type).can_be_contained_by(type: type, times: times)
          get_rule_for(type).can_contain(type: contained_type, times: times)
        end
      end

      def initialize
        @rules = {}
      end

      def get_rule_for(type)
        @rules[type] ||= BagRule.new(type)
      end

      def types_that_can_contain(type)
        types_that_directly_contain = get_rule_for(type).types_that_directly_contain
        result = types_that_directly_contain
        types_that_directly_contain.each do |directly_containing_type|
          result |= types_that_can_contain(directly_containing_type)
        end
        result
      end

      def number_of_bags_contained_by(type)
        result = 0
        get_rule_for(type).contains.each do |contained_type, times|
          result += times * (1 + number_of_bags_contained_by(contained_type))
        end
        result
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input_lines(__FILE__)
      rules = BagRules.new
      data.each do |rule|
        rules.parse_rule(rule)
      end

      puts "1) Solution 1: #{rules.types_that_can_contain('shiny gold').count}"
      puts "2) Solution 2: #{rules.number_of_bags_contained_by('shiny gold')}"
    end
  end
end
