def read_input_lines(number)
  open("#{File.dirname(__FILE__)}/#{number}-input.txt") do |f|
    f.readlines.map(&:strip)
  end
end

def read_input_columns(number)
  lines = read_input_lines(number)
  lines.map { |l| l.split(',') }
end

Vector = Struct.new('Vector', :x, :y) do
  def +(other)
    ensure_vector other

    Vector.new(x + other.x, y + other.y)
  end

  def -(other)
    ensure_vector other

    Vector.new(x - other.x, y - other.y)
  end

  def inspect
    "(#{x}, #{y})"
  end

  private

  def ensure_vector(other)
    raise unless other.is_a? Vector
  end
end
