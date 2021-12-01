# frozen_string_literal: true

require 'set'

require_relative '../common'

module AOC2020
  module Task21
    class IngredientList
      REGEXP = /\A([^(]+)\(contains ([^)]+)\)\Z/.freeze
      def self.parse(line)
        match = REGEXP.match(line)
        ingredients = match[1].split
        allergens = match[2].split(', ')
        new(ingredients, allergens)
      end

      def initialize(ingredients, allergens)
        @ingredients = Set.new ingredients
        @allergens = Set.new allergens
      end

      def ingredients
        @ingredients.dup
      end

      def allergens
        @allergens.dup
      end
    end

    class AllergenFinder
      def initialize(ingredient_lists)
        @ingredient_lists = ingredient_lists
        @all_allergens = ingredient_lists.map(&:allergens).reduce(:|)
        @allergen_candidates = {}
        @safe_ingredients_by_allergen = {}
        @allergen_ingredients = {}
        find
      end

      def safe_ingredients
        @safe_ingredients ||= @safe_ingredients_by_allergen.values.map { |ingredients|
          ingredients - @allergen_candidates.values.reduce(:|)
        }.reduce(:|)
      end

      def safe_ingredient_count
        @ingredient_lists.sum { |list| (list.ingredients & safe_ingredients).size }
      end

      def canonical_dangerous_ingredient_list
        @all_allergens.to_a.sort.map { |allergen| @allergen_ingredients[allergen] }.join(',')
      end

      private

      def find
        @all_allergens.each do |allergen|
          find_safe_ingredients(allergen)
        end
        find_allergens
      end

      def find_safe_ingredients(allergen)
        lists_with_allergen = @ingredient_lists.select { |list| list.allergens.include? allergen }.map(&:ingredients)
        @allergen_candidates[allergen] = lists_with_allergen.reduce(:&)
        return if lists_with_allergen.size == 1

        @safe_ingredients_by_allergen[allergen] = lists_with_allergen.map { |list| list - @allergen_candidates[allergen] }
                                                                     .reduce(:|)
      end

      def find_allergens
        while @allergen_ingredients.size < @all_allergens.size
          found_allergen = @all_allergens.find { |allergen|
            !@allergen_ingredients.key?(allergen) && remaining_candidates(allergen).size == 1
          }
          @allergen_ingredients[found_allergen] = remaining_candidates(found_allergen).first
        end
      end

      def remaining_candidates(allergen)
        @allergen_candidates[allergen] - @allergen_ingredients.values
      end
    end

    if $PROGRAM_NAME == __FILE__
      data = read_input_lines(__FILE__)
      ingredient_lists = data.map { |line| IngredientList.parse(line) }
      allergen_finder = AllergenFinder.new(ingredient_lists)
      puts "1) Solution 1: #{allergen_finder.safe_ingredient_count}"

      puts "2) Solution 2: #{allergen_finder.canonical_dangerous_ingredient_list}"
    end
  end
end
