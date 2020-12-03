# frozen_string_literal: true

require_relative 'common'

def fuel_for(mass)
  (mass / 3) - 2
end

masses = read_input_lines('01').map(&:to_i)

naive_fuel = masses.map { |m| fuel_for(m) }.sum
p "Part 1: Naive fuel: #{naive_fuel}"

def real_fuel_for(mass)
  result = fuel_for(mass)
  added_fuel = result

  until added_fuel.zero?
    added_fuel = [fuel_for(added_fuel), 0].max
    result += added_fuel
  end
  result
end

real_fuel = masses.map { |m| real_fuel_for(m) }.sum
p "Part 2: Real fuel: #{real_fuel}"
