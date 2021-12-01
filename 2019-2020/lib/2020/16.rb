# frozen_string_literal: true

require 'set'

require_relative '../common'

module AOC2020
  module Task16
    class Input
      def self.parse(data)
        ticket_fields_data, your_ticket_data, nearby_tickets_data =
          data.split("\n\n").map { |sub_data| sub_data.split("\n") }
        fields = ticket_fields_data.map { |line| TicketField.parse(line) }
        your_ticket = parse_ticket your_ticket_data[1]
        nearby_tickets = nearby_tickets_data[1..].map { |line| parse_ticket line }

        [fields, your_ticket, nearby_tickets]
      end

      def self.parse_ticket(line)
        line.split(',').map(&:to_i)
      end
    end

    class TicketField
      REGEXP = /\A(.+): (\d+)-(\d+) or (\d+)-(\d+)\Z/.freeze

      def self.parse(field_description)
        match = REGEXP.match(field_description)
        new(match[1], (match[2].to_i..match[3].to_i), (match[4].to_i..match[5].to_i))
      end

      attr_reader :name

      def initialize(name, valid_range1, valid_range2)
        @name = name
        @valid_range1 = valid_range1
        @valid_range2 = valid_range2
      end

      def valid_value?(value)
        @valid_range1.include?(value) || @valid_range2.include?(value)
      end
    end

    class TicketScanner
      def initialize(fields, nearby_tickets)
        @fields = fields
        @nearby_tickets = nearby_tickets
      end

      def error_rate
        @nearby_tickets.flat_map { |ticket| invalid_values_for_all_fields(ticket) }.sum
      end

      def valid_tickets
        @nearby_tickets.select { |ticket| invalid_values_for_all_fields(ticket).empty? }
      end

      private

      def invalid_values_for_all_fields(ticket)
        ticket.select { |value| @fields.none? { |field| field.valid_value?(value) } }
      end
    end

    class FieldPositionFinder
      def initialize(tickets, fields)
        @tickets = tickets
        @fields = fields
        @fields_without_position = Set.new @fields
        @candidates = {}
        @field_by_position = {}
      end

      def find_positions
        until @fields_without_position.empty?
          @fields_without_position.each do |field|
            @candidates[field] ||= find_candidates_for(field)
            assign_position(field) if @candidates[field].size == 1
          end
          @fields_without_position.subtract @field_by_position.values
        end
      end

      def interprete_ticket(ticket)
        ticket.map.with_index { |value, position| [@field_by_position[position].name, value] }.to_h
      end

      private

      def positions
        (0...@tickets[0].size)
      end

      def find_candidates_for(field)
        Set.new(
          positions.select { |position|
            next false if @field_by_position.key? position

            @tickets.all? { |ticket| field.valid_value? ticket[position] }
          }
        )
      end

      def assign_position(field)
        position = @candidates[field].first
        @field_by_position[position] = field
        @candidates.each do |other_field, candidates|
          next if other_field == field

          candidates.delete position
        end
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input(__FILE__)

      fields, your_ticket, nearby_tickets = Input.parse(data)
      scanner = TicketScanner.new(fields, nearby_tickets)

      puts "1) Solution 1: #{scanner.error_rate}"

      field_position_finder = FieldPositionFinder.new(scanner.valid_tickets, fields)
      field_position_finder.find_positions
      interpreted_ticket = field_position_finder.interprete_ticket(your_ticket)
      departure_values = interpreted_ticket.select { |key| key.start_with? 'departure' }
      puts "2) Solution 2: #{departure_values.values.reduce(1, :*)}"
    end
  end
end
