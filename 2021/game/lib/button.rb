class Button
  attr_accessor :id, :rect, :label, :click_handler

  def initialize(id:, rect:, label:, color: nil, click_handler: nil)
    @id = id
    @rect = rect
    @label = label
    @hover = false
    @color = color || { r: 255, g: 255, b: 255 }
    @click_handler = click_handler || ->(_args, _button) {}
  end

  def tick(args)
    mouse = args.inputs.mouse
    @hover = mouse.inside_rect? @rect
    return unless @hover && mouse.down

    @click_handler.call(args, self)
  end

  def render(gtk_outputs)
    gtk_outputs.primitives << [
      @rect.to_solid(@color),
      button_background,
      {
        x: @rect.x + @rect.w.idiv(2), y: @rect.y + @rect.h.idiv(2),
        text: @label, alignment_enum: 1, vertical_alignment_enum: 1
      }.label!(label_color)
    ]
  end

  def inspect
    { id: @id, rect: @rect, label: @label }.inspect
  end

  private

  def button_background
    @hover ? @rect.to_solid : @rect.to_border
  end

  def label_color
    @hover ? { r: 255, g: 255, b: 255 } : { r: 0, g: 0, b: 0 }
  end
end
