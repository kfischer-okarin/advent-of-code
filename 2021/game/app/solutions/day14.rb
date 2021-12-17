class Day14
  def self.title
    '--- Day 14: Extended Polymerization ---'
  end

  def initialize(state)
    @state = state
    setup
  end

  def tick(args)
    render(args)
    process_input(args)
  end

  private

  def setup
    read_input('14')
    @state.steps = 0
    count_elements
  end

  def read_input(input_id)
    lines = read_problem_input(input_id).split("\n")
    read_initial_polymer lines.first.chars
    read_rules lines.drop(2)
  end

  def read_initial_polymer(elements)
    @state.polymer = elements
    @state.pair_counts = {}.tap { |pairs|
      elements.each_cons(2) do |pair|
        add_into_hash pairs, pair, 1
      end
    }
    @state.last_element = elements.last
  end

  def read_rules(rule_lines)
    @state.rules = rule_lines.map { |line|
      pair, inserted_element = line.split(' -> ')
      {
        pair: pair.chars,
        new_pairs: [[pair[0], inserted_element], [inserted_element, pair[1]]],
        inserted_element: inserted_element
      }
    }
  end

  def render(args)
    render_info(args)
  end

  def render_info(args)
    args.outputs.primitives << top_right_labels(
      'Press Space to simulate polymer growh',
      "Steps: #{@state.steps}",
      *@state.element_counts.map { |element, count| "#{element}: #{count}" },
      "Result: #{@state.result}"
    )
  end

  def process_input(args)
    return unless args.inputs.keyboard.key_down.space

    simulate_polymer_growth
  end

  def simulate_polymer_growth
    rule_applications = determine_rule_applications
    update_pair_counts rule_applications
    count_elements
    @state.steps += 1
  end

  def determine_rule_applications
    {}.tap { |result|
      @state.rules.each do |rule|
        number_of_pairs = @state.pair_counts[rule.pair]
        next unless number_of_pairs&.positive?

        result[rule] = number_of_pairs
      end
    }
  end

  def update_pair_counts(rule_applications)
    rule_applications.each do |rule, times|
      @state.pair_counts[rule.pair] -= times
      rule.new_pairs.each do |pair|
        add_into_hash @state.pair_counts, pair, times
      end
    end
  end

  def count_elements
    @state.element_counts = {}.tap { |element_counts|
      count_first_pair_elements element_counts
      add_into_hash element_counts, @state.last_element, 1
    }
    @state.result = highest_element_count - lowest_element_count
  end

  def count_first_pair_elements(result_hash)
    @state.pair_counts.each do |pair, count|
      add_into_hash result_hash, pair[0], count
    end
  end

  def highest_element_count
    @state.element_counts.values.max
  end

  def lowest_element_count
    @state.element_counts.values.min
  end

  def add_into_hash(hash, key, value)
    hash[key] ||= 0
    hash[key] += value
  end
end

SOLUTIONS[14] = Day14
