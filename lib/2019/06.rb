require 'set'

require_relative 'common'

class Planet
  attr_reader :name, :orbited_by, :orbit_center

  def initialize(name)
    @name = name
    @orbit_center = nil
    @orbited_by = Set.new
  end

  def orbits_around(planet)
    @orbit_center = planet
    @orbit_center.add_orbiting_planet self
  end

  def add_orbiting_planet(planet)
    orbited_by << planet
  end

  def orbiting_count
    if orbit_center
      1 + orbit_center.orbiting_count
    else
      0
    end
  end

  def hash
    @name.hash
  end

  def ==(other)
    name == other.name
  end
end

class Ship
  def initialize(start)
    @current = nil
    @distance_from_start = {}
    @distance_from_start[start] = 0
    @frontier = Queue.new
    frontier << start
  end

  def find(goal)
    while true do
      current = frontier.pop

      return distance_from_start[current] if current == goal

      neighbors_of(current).reject { |planet| visited?(planet) }.each do |planet|
        frontier << planet
        distance_from_start[planet] = distance_from_start[current] + 1
      end
    end
  end

  private

  attr_accessor :current, :distance_from_start, :frontier

  def neighbors_of(planet)
    Set.new(planet.orbited_by).tap do |result|
      result << planet.orbit_center if planet.orbit_center
    end
  end

  def visited?(planet)
    distance_from_start.key? planet
  end
end

class Space
  def initialize
    @planets = {}
  end

  def planet(name)
    @planets[name] ||= Planet.new(name)
  end

  def total_orbits
    @planets.values.map(&:orbiting_count).sum
  end

  alias :describe :instance_eval
end

if $PROGRAM_NAME == __FILE__
  planets = read_input_lines('06').map { |line| line.split(')') }

  space = Space.new
  space.describe do
    planets.each do |center, orbiting|
      planet(orbiting).orbits_around planet(center)
    end
  end

  puts "1) Total orbits: #{space.total_orbits}"

  ship = Ship.new(space.planet('YOU').orbit_center)
  traveled_distance = ship.find(space.planet('SAN').orbit_center)
  puts "2) Shortest way from YOU to SAN: #{traveled_distance}"
end
