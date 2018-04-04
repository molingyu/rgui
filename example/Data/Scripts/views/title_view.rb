#encoding: utf-8
#author: shitake
#data: 16-4-20

class TitleView < View

  def initialize
    super
    @pos = [0, 0]
    @mouse_pos = Sprite.new
    @mouse_pos.bitmap = Bitmap.new(544, 416)
    @mouse_pos.x, @mouse_pos.y = 1, 1

  end
  
  def update
    super
    mouse_pos
  end

  def mouse_pos
    pos = Input.get_pos
    if pos != @pos
      @mouse_pos.bitmap.clear
      @mouse_pos.bitmap.draw_text(10, 0, 400, 24, sprintf("x:%03d y:%03d", pos[0], pos[1]))
      @pos = pos
    end
  end

end
