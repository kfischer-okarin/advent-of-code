# frozen_string_literal: true

require_relative 'common'

module Task14
  ElementAmount = Struct.new('ElementAmount', :type, :amount) do
    def self.parse(description)
      amount, type = description.split
      ElementAmount.new(type, amount.to_i)
    end

    def *(other)
      ElementAmount.new(type, amount * other)
    end

    def inspect
      "#{amount} #{type}"
    end
  end

  class Materials
    def initialize
      @elements = Hash.new(0)
    end

    def amount_of(type)
      elements[type]
    end

    def consume(element_amount)
      elements[element_amount.type] -= element_amount.amount
    end

    def add(element_amount)
      elements[element_amount.type] += element_amount.amount
    end

    def missing_elements
      elements.select { |_type, amount| amount.negative? }.map { |type, amount| ElementAmount.new(type, -amount) }
    end

    private

    attr_reader :elements
  end

  class Reaction
    def initialize(input, output)
      @input = input
      @output = output
    end

    def produce(amount, materials:)
      reaction_count = amount / output.amount
      reaction_count += 1 unless (amount % output.amount).zero?

      input.each do |element_amount|
        materials.consume(element_amount * reaction_count)
      end
      materials.add(output * reaction_count)
    end

    def produced_element
      output.type
    end

    def produces?(type)
      produced_element == type
    end

    def inspect
      "#{input.map(&:inspect).join(', ')} => #{output.inspect}"
    end

    private

    attr_reader :input, :output
  end

  class Production
    def initialize(reaction_descriptions)
      @reactions = reaction_descriptions.map do |description|
        reaction = parse_reaction(description)
        [reaction.produced_element, reaction]
      end.to_h
      @materials = Materials.new
    end

    def produce_fuel(amount = 1)
      reactions['FUEL'].produce(amount, materials: materials)

      until missing_elements.empty?
        next_production = missing_elements.first
        reactions[next_production.type].produce(next_production.amount, materials: materials)
      end
    end

    def ore_needed
      -materials.amount_of('ORE')
    end

    def fuel_produced_with(ore_amount)
      produce_fuel 1
      ore_for_one_fuel = ore_needed
      result = 1

      until ore_needed > ore_amount
        next_produce_amount = [(ore_amount - ore_needed) / ore_for_one_fuel, 1].max
        produce_fuel next_produce_amount
        result += next_produce_amount
      end
      result - 1
    end

    private

    attr_reader :reactions, :materials

    def parse_reaction(reaction_description)
      input_part, output = reaction_description.split('=>').map(&:strip)
      inputs = input_part.split(', ').map(&:strip)
      Reaction.new(inputs.map { |description| ElementAmount.parse(description) }, ElementAmount.parse(output))
    end

    def missing_elements
      materials.missing_elements.reject { |element_amount| element_amount.type == 'ORE' }
    end
  end

  if $PROGRAM_NAME == __FILE__
    reaction_descriptions = read_input_lines('14')
    production = Production.new(reaction_descriptions)
    production.produce_fuel

    puts "1) Ore needed: #{production.ore_needed}"

    production = Production.new(reaction_descriptions)

    puts "2) Fuel produced with 1 trillion ore: #{production.fuel_produced_with(1_000_000_000_000)}"
  end
end
