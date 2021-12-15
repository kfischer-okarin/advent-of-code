require 'lib/a_star.rb'

# See AN ALGORITHM FOR DRAWING GENERAL UNDIRECTED GRAPHS
class GraphLayout
  # graph objects required methods
  #   - #nodes: Array[Node]
  #   - #neighbors_of: (Node) -> Array[Node]
  #
  # Node:
  #  - attr_accessor x: Numeric
  #  - attr_accessor y: Numeric
  #  - fixed?: Boolean
  def initialize(graph, display_size:, spring_factor: 10, movement_factor: 0.1, epsilon: 100)
    @graph = graph
    @spring_factor = spring_factor
    @movement_factor = movement_factor
    @epsilon = epsilon
    calc_distances
    @optimal_length = display_size / max_distance_between_two_nodes
    calc_spring_parameters
  end

  def layout_graph_step
    moving_node = node_with_biggest_delta_value
    return false if moving_node.nil?

    movement = movement_for(moving_node)
    moving_node.x += movement.x * @movement_factor
    moving_node.y += movement.y * @movement_factor
    true
  end

  private

  def calc_distances
    graph_for_a_star = AStarWrapper.new(@graph)
    @distances = {}
    @graph.nodes.each do |from_node|
      @graph.nodes.each do |to_node|
        next if from_node == to_node

        shortest_path = AStar.find_path(graph_for_a_star, from: from_node, to: to_node)
        @distances[from_node] ||= {}
        @distances[from_node][to_node] = shortest_path.length
        @distances[to_node] ||= {}
        @distances[to_node][from_node] = shortest_path.length
      end
    end
  end

  class AStarWrapper
    def initialize(graph)
      @graph = graph
    end

    def neighbors_of(node)
      @graph.neighbors_of(node)
    end

    # Djiksstra's algorithm / Uniform Cost Search
    # Just find path with the least number of edges
    def cost(_from_node, _to_node)
      1
    end

    def heuristic(_from_node, _to_node)
      0
    end
  end

  def max_distance_between_two_nodes
    @distances.values.map { |to_node_distances| to_node_distances.values.max }.max
  end

  def calc_spring_parameters
    @spring_lengths = {}
    @spring_strengths = {}
    @graph.nodes.each do |node|
      @spring_lengths[node] = @distances[node].transform_values { |distance|
        distance * @optimal_length
      }
      @spring_strengths[node] = @distances[node].transform_values { |distance|
        @spring_factor / (distance**2)
      }
    end
  end

  def node_with_biggest_delta_value
    delta_values = @graph.nodes.map { |node|
      next [node, -1] if node.fixed?

      [node, delta_value(node)]
    }.to_h
    biggest_delta_value_node = @graph.nodes.max_by { |node| delta_values[node] }
    return if delta_values[biggest_delta_value_node] < @epsilon

    biggest_delta_value_node
  end

  def delta_value(node)
    Math.sqrt((energy_derivative(node, :x)**2) + (energy_derivative(node, :y)**2))
  end

  def energy_derivative(node, x_or_y)
    @graph.nodes.inject(0) { |sum, other_node|
      next sum if other_node == node

      strength = @spring_strengths[node][other_node]
      diff_x = node.x - other_node.x
      diff_y = node.y - other_node.y
      length = @spring_lengths[node][other_node]
      main_diff = x_or_y == :x ? diff_x : diff_y
      sum + (
        strength * (main_diff - ((length * main_diff) / Math.sqrt((diff_x**2) + (diff_y**2))))
      )
    }
  end

  # x_2nd_derivative * dx +    xy_derivative * dy = -x_derivative
  #    xy_derivative * dx + y_2nd_derivative * dy = -y_derivative
  #
  #        x_derivative       xy_derivative           y_derivative    y_2nd_derivative
  # => - ---------------- - ---------------- * dy = - ------------- - ---------------- * dy
  #      x_2nd_derivative   x_2nd_derivative          xy_derivative     xy_derivative
  #
  #    -x_2nd_derivative * y_2nd_derivative + xy_derivative**2        -x_derivative * xy_derivative + y_derivative * x_2nd_derivative
  # => ------------------------------------------------------ * dy = ---------------------------------------------------------------
  #              xy_derivative * x_2nd_derivative                                xy_derivative * x_2nd_derivative
  #
  #          (-x_derivative * xy_derivative + y_derivative * x_2nd_derivative) * (xy_derivative * x_2nd_derivative)
  # => dy =  -----------------------------------------------------------------------------------------------------
  #               (xy_derivative * x_2nd_derivative) * (-x_2nd_derivative * y_2nd_derivative + xy_derivative**2)
  #
  #         -x_derivative * xy_derivative + y_derivative * x_2nd_derivative
  # => dy = --------------------------------------------------------------
  #             -x_2nd_derivative * y_2nd_derivative + xy_derivative**2
  #
  #           x_derivative  + xy_derivative * dy
  # => dx = - ----------------------------------
  #                  x_2nd_derivative
  def movement_for(node)
    x_derivative = energy_derivative(node, :x)
    y_derivative = energy_derivative(node, :y)
    x_2nd_derivative = energy_2nd_derivative(node, :x)
    y_2nd_derivative = energy_2nd_derivative(node, :x)
    xy_derivative = energy_xy_derivative(node)

    dy = (
      (-x_derivative * xy_derivative) + (y_derivative * x_2nd_derivative)
    ) / (
      (-x_2nd_derivative * y_2nd_derivative) + (xy_derivative**2)
    )
    dx = -(
      (x_derivative + (xy_derivative * dy)) / x_2nd_derivative
    )
    [dx, dy]
  end

  def energy_2nd_derivative(node, x_or_y)
    @graph.nodes.inject(0) { |sum, other_node|
      next sum if other_node == node

      strength = @spring_strengths[node][other_node]
      diff_x = node.x - other_node.x
      diff_y = node.y - other_node.y
      length = @spring_lengths[node][other_node]
      non_main_diff = x_or_y == :x ? diff_y : diff_x
      sum + (
        strength * (1 - ((length * (non_main_diff**2)) / Math.sqrt(((diff_x**2) + (diff_y**2))**3)))
      )
    }
  end

  def energy_xy_derivative(node)
    @graph.nodes.inject(0) { |sum, other_node|
      next sum if other_node == node

      strength = @spring_strengths[node][other_node]
      diff_x = node.x - other_node.x
      diff_y = node.y - other_node.y
      length = @spring_lengths[node][other_node]
      sum + (
        strength * ((length * diff_x * diff_y) / Math.sqrt(((diff_x**2) + (diff_y**2))**3))
      )
    }
  end
end
