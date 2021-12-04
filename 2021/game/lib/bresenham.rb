module Bresenham
  def self.steps(start_point, end_point)
    Enumerator.new do |yielder|
      x = start_point.x
      y = start_point.y
      end_x = end_point.x
      end_y = end_point.y

      dx = (end_x - x).abs
      sx = x < end_x ? 1 : -1
      dy = -(end_y - y).abs
      sy = y < end_y ? 1 : -1
      err = dx + dy

      loop do
        break if x == end_x && y == end_y

        e2 = 2 * err
        if e2 > dy
          err += dy
          x += sx
          yielder << [sx, 0]
        elsif e2 <= dx
          err += dx
          y += sy
          yielder << [0, sy]
        end
      end
    end
  end

  def self.points(start_point, end_point)
    Enumerator.new do |yielder|
      x = start_point.x
      y = start_point.y
      yielder << [x, y]

      steps(start_point, end_point).each do |step|
        x += step[0]
        y += step[1]
        yielder << [x, y]
      end
    end
  end
end
