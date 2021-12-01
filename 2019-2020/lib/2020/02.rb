# frozen_string_literal: true

require_relative '../common'

module AOC2020
  module Task02
    class PasswordChecker
      class OldPasswordPolicy
        # policy_string: eg. '8-10 l'
        def self.parse(policy_string)
          range_string, letter = policy_string.split
          min_amount, max_amount = range_string.split('-').map(&:to_i)
          new(letter, min_amount, max_amount)
        end

        def initialize(letter, min_amount, max_amount)
          @letter = letter
          @allowed_range = min_amount..max_amount
        end

        def valid?(password)
          letter_count = password.chars.count { |character| character == @letter }
          @allowed_range.include? letter_count
        end
      end

      class NewPasswordPolicy
        # policy_string: eg. '8-10 l'
        def self.parse(policy_string)
          two_indexes_string, letter = policy_string.split
          first_index, second_index = two_indexes_string.split('-').map { |index_string| index_string.to_i - 1 }
          new(letter, first_index, second_index)
        end

        def initialize(letter, first_index, second_index)
          @letter = letter
          @first_index = first_index
          @second_index = second_index
        end

        def valid?(password)
          password[@first_index] == @letter && password[@second_index] != @letter ||
            password[@first_index] != @letter && password[@second_index] == @letter
        end
      end

      def initialize(passwords_with_policies, policy_class)
        @passwords_with_policies = passwords_with_policies
        @policy_class = policy_class
      end

      def valid_password_count
        @passwords_with_policies.select { |password_with_policy| valid?(password_with_policy) }.count
      end

      private

      def valid?(password_with_policy)
        policy_string, password = password_with_policy.split(': ')
        policy = @policy_class.parse(policy_string)
        policy.valid? password
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input_lines(__FILE__)

      checker = PasswordChecker.new(data, PasswordChecker::OldPasswordPolicy)
      puts "1) Solution 1: #{checker.valid_password_count}"

      checker = PasswordChecker.new(data, PasswordChecker::NewPasswordPolicy)
      puts "2) Solution 2: #{checker.valid_password_count}"
    end
  end
end
