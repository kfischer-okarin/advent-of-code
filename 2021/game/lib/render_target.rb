class RenderTarget
  attr_accessor :x, :y, :w, :h, :r, :g, :b, :a, :source_x, :source_y, :source_w, :source_h

  def initialize(name, size: nil, **values)
    @name = name
    @size = size
    @clear = true
    @queued_primitives = []
    values.each do |attr, value|
      send("#{attr}=", value)
    end
    self.w ||= size.x
    self.h ||= size.y
  end

  def primitives
    @queued_primitives
  end

  def render(args)
    draw_to_render_target(args) if dirty?
    args.outputs.primitives << {
      x: @x, y: @y, w: @w, h: @h,
      path: @name, source_x: @source_x, source_y: @source_y, source_w: @source_w, source_h: @source_h,
      r: @r, g: @g, b: @b, a: @a
    }.sprite!
  end

  private

  def dirty?
    @queued_primitives.any? || @clear
  end

  def draw_to_render_target(args)
    target = get_target(args)
    target.primitives << @queued_primitives
    @queued_primitives = []
  end

  def get_target(args)
    args.outputs[@name].tap { |render_target|
      render_target.width, render_target.height = @size if @size
      render_target.clear_before_render = @clear
      @clear = false
    }
  end
end
