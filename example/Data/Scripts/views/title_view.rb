#encoding: utf-8
#author: shitake
#data: 16-4-20

class TestView < View

  def initialize
    super
    @pos = [0, 0]
    @mouse_pos = Sprite.new
    @mouse_pos.bitmap = Bitmap.new(640, 480)
    @mouse_pos.x, @mouse_pos.y = 1, 1
    image = $g.load_image('Pictures/bg1.png')
    @ImageBox = RGUI::Component::ImageBox.new({
                                                  x: 100,
                                                  y: 100,
                                                  width:300,
                                                  height:300,
                                                  image: image,
                                                  focus: true,
                                                  type: RGUI::Component::ImageBoxType::Tiling})
    @ImageBox.event_manager.on(:KEY_A){ |em| em.object.x_scroll(-5) }
    @ImageBox.event_manager.on(:KEY_D){ |em| em.object.x_scroll(+5) }
    @ImageBox.event_manager.on(:KEY_W){ |em| em.object.y_scroll(-5) }
    @ImageBox.event_manager.on(:KEY_S){ |em| em.object.y_scroll(+5) }
  end
  
  def update
    super
    mouse_pos
    @ImageBox.update
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
