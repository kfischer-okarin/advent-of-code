require 'lib/priority_queue.rb'

module AStar
  class << self
    # graph object needs methods #neighbors_of, #cost, #heuristic
    def find_path(graph, from:, to:)
      frontier = PriorityQueue.new
      frontier.insert from, 0
      came_from = {}
      cost_so_far = { from => 0 }

      until frontier.empty?
        current = frontier.pop

        break if current.eql? to

        graph.neighbors_of(current).each do |neighbor|
          move_cost = graph.cost(current, neighbor)
          next if move_cost.zero?

          new_cost = cost_so_far[current] + move_cost
          next unless !cost_so_far.key?(neighbor) || new_cost < cost_so_far[neighbor]

          cost_so_far[neighbor] = new_cost
          priority = new_cost + graph.heuristic(neighbor, to)
          frontier.insert neighbor, priority
          came_from[neighbor] = current
        end
      end

      construct_path(to, came_from)
    end

    private

    def construct_path(goal, came_from)
      return [] unless came_from.key? goal

      [].tap { |result|
        current = goal
        while came_from[current]
          previous = came_from[current]
          result.unshift current
          current = previous
        end
      }
    end
  end
end
