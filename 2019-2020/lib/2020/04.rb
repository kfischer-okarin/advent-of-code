# frozen_string_literal: true

require_relative '../common'

module AOC2020
  module Task04
    class Passport
      FIELDS = %i[byr iyr eyr hgt hcl ecl pid].freeze

      def self.parse(passport_string)
        values = passport_string.split.map { |value_pair|
          field, value = value_pair.split(':')
          [field.to_sym, value]
        }.to_h
        new(values)
      end

      def initialize(values)
        @values = values
      end

      def fields_present?
        FIELDS.all? { |field| @values.key? field }
      end

      def valid?
        valid_fields == FIELDS
      end

      def valid_fields
        FIELDS.select { |field| send(:"#{field}_valid?", @values[field]) }
      end

      private

      def byr_valid?(value)
        /\A\d{4}\Z/ =~ value && (1920..2002).include?(value.to_i)
      end

      def iyr_valid?(value)
        /\A\d{4}\Z/ =~ value && (2010..2020).include?(value.to_i)
      end

      def eyr_valid?(value)
        /\A\d{4}\Z/ =~ value && (2020..2030).include?(value.to_i)
      end

      def hgt_valid?(value)
        match = /\A(\d+)(in|cm)\Z/.match(value)
        return false unless match

        case match[2]
        when 'cm'
          (150..193).include?(match[1].to_i)
        when 'in'
          (59..76).include?(match[1].to_i)
        else
          false
        end
      end

      def hcl_valid?(value)
        /\A#[a-f0-9]{6}\Z/ =~ value
      end

      def ecl_valid?(value)
        %w[amb blu brn gry grn hzl oth].include? value
      end

      def pid_valid?(value)
        /\A\d{9}\Z/ =~ value
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input(__FILE__)

      passports = data.split("\n\n").map { |passport_string| Passport.parse(passport_string) }

      puts "1) Solution 1: #{passports.count(&:fields_present?)}"
      puts "2) Solution 2: #{passports.count { |passport| passport.fields_present? && passport.valid? }}"
    end
  end
end
