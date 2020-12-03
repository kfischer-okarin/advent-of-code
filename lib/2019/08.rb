require_relative 'common'

def count(n, layer)
  layer.count { |k| k == n }
end

class Image
  class Layer
    attr_reader :content

    def initialize(content)
      @content = content
    end

    def count(k)
      @content.count { |digit| digit == k }
    end
  end

  attr_reader :layer_count

  def initialize(w, h, encoded_image)
    @w = w
    @h = h
    layer_length = (w * h)
    @layer_count = encoded_image.size / layer_length
    @layers = layer_count.times.map { |k|
      Layer.new(encoded_image[(k * layer_length)...((k + 1) * layer_length)])
    }
  end

  def minimum_zero_layer
    @layers.min { |a, b| a.count(0) <=> b.count(0) }
  end

  def print_image
    final_pixels = layers.each_with_object([]) { |layer, result|
      layer.content.each_with_index do |pixel, index|
        result[index] = pixel if !result[index] || result[index] == 2
      end
    }
    @h.times do |y|
      @w.times do |x|
        print final_pixels[(@w * y) + x]
      end
      print "\n"
    end
  end

  private

  attr_reader :layers
end



if $PROGRAM_NAME == __FILE__
  encoded_image = read_input_lines('08')[0].chars.map(&:to_i)

  image = Image.new(25, 6, encoded_image)

  minimum_zero_layer = image.minimum_zero_layer
  puts "1) Layer with minimum zeros, ones * twos: #{minimum_zero_layer.count(1) * minimum_zero_layer.count(2)}"
  puts "2) Final image:"
  image.print_image
end
