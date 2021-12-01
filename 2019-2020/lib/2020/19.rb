# frozen_string_literal: true

require_relative '../common'

module AOC2020
  module Task19
    class Rules
      def self.parse(rule_lines)
        @rules = {}
        rule_lines.each { |rule_line|
          number, rule = rule_line.split(': ')
          @rules[number.to_i] = Rule.parse(rule)
          @rules[number.to_i].number = number.to_i
        }
      end

      def self.[](number)
        @rules[number]
      end

      def self.[]=(number, value)
        @rules[number] = value
      end
    end

    class Rule
      def self.parse(line)
        matcher_strings = line.split(' | ')
        new(
          matcher_strings.map { |string|
            if string.include? '"'
              LetterMatcher.parse(string)
            else
              RuleMatcher.parse(string)
            end
          }
        )
      end

      class LetterMatcher
        def self.parse(string)
          new string[1]
        end

        def initialize(letter)
          @letter = letter
        end

        def matches(string)
          string[0] == @letter ? [string[0]] : []
        end

        def inspect
          "LetterMatcher.new(#{@letter.inspect})"
        end
      end

      class RuleMatcher
        def self.parse(string)
          new string.split.map(&:to_i)
        end

        def initialize(rules)
          @rules = rules
        end

        def matches(string)
          results = ['']
          @rules.each do |rule|
            results = results.flat_map { |result|
              Rules[rule].matches(string[result.length..]).map { |match|
                result + match
              }
            }
          end
          results
        end

        def inspect
          "RuleMatcher.new(#{@rules.inspect})"
        end
      end

      attr_writer :number

      def initialize(matchers)
        @matchers = matchers
      end

      def matches(string)
        result = []
        @matchers.each do |matcher|
          result += matcher.matches(string)
        end
        result
      end

      def matches?(string)
        matches(string).include? string
      end

      def inspect
        "#{@number}: Rule.new(#{@matchers.inspect})"
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input(__FILE__)
      rule_lines, messages = data.split("\n\n").map { |text| text.split("\n") }
      Rules.parse(rule_lines)
      puts "1) Solution 1: #{messages.count { |message| Rules[0].matches?(message) }}"

      Rules[8] = Rule.parse '42 | 42 8'
      Rules[8].number = 8
      Rules[11] = Rule.parse '42 31 | 42 11 31'
      Rules[11].number = 11
      puts "2) Solution 2: #{messages.count { |message| Rules[0].matches?(message) }}"
    end
  end
end
