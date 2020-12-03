# frozen_string_literal: true

def read_input_lines(number)
  open("#{File.dirname(__FILE__)}/#{number}-input.txt") do |f|
    f.readlines.map(&:strip)
  end
end

def read_input_columns(number)
  lines = read_input_lines(number)
  lines.map { |l| l.split(',') }
end

def read_intcode_program(number)
  read_input_columns(number)[0].map(&:to_i)
end

def greatest_common_factor(big, small)
  return big if small.zero?
  return small if big.zero?

  return greatest_common_factor(small, big) if small > big

  rest = big % small
  return small if rest.zero?

  greatest_common_factor(small, rest)
end

def prime_numbers_until(n)
  result = (2..n).to_a
  current = 0
  while current < result.size
    result = result.reject do |k|
      k != result[current] && (k % result[current]).zero?
    end
    current += 1
  end
  result
end

def prime_factors(number, prime_numbers: prime_numbers_until(number))
  result = []
  remain = number
  prime_numbers.each do |p|
    break if p > remain

    while (remain % p).zero?
      remain /= p
      result << p
    end
  end
  result
end

def least_common_multiple(*numbers)
  prime_numbers = prime_numbers_until(numbers.max)
  factors = numbers.map { |k| prime_factors(k, prime_numbers: prime_numbers) }
  result = 1
  until factors.all?(&:empty?)
    factor = factors.map(&:first).compact.min
    max_count = factors.map { |f| f.count { |k| k == factor } }.max
    result *= factor**max_count
    factors.each { |f| f.delete factor }
  end
  result
end

Vector = Struct.new('Vector', :x, :y) do
  def +(other)
    ensure_vector other

    self.class.new(x + other.x, y + other.y)
  end

  def -(other)
    ensure_vector other

    self.class.new(x - other.x, y - other.y)
  end

  def negated
    self.class.new(-x, -y)
  end

  def hash
    [x, y].hash
  end

  def eql?(other)
    x == other.x && y == other.y
  end

  def inspect
    "(#{x}, #{y})"
  end

  private

  def ensure_vector(other)
    raise unless other.is_a? Vector
  end
end

class MapRenderer
  def initialize(elements)
    @elements = elements
  end

  def render
    y_range.map do |y|
      x_range.map { |x| render_element elements[Vector.new(x, y)] }.join ''
    end.join("\n")
  end

  protected

  def render_element(_element)
    ' '
  end

  private

  attr_reader :elements

  def y_range
    elements.keys.map(&:y).instance_eval { (min..max).enum_for(:reverse_each) }
  end

  def x_range
    elements.keys.map(&:x).instance_eval { (min..max).enum_for(:each) }
  end
end
