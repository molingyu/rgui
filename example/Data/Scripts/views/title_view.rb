#encoding: utf-8
#author: shitake
#data: 16-4-20

class TestView < View

  def initialize
    super
    @pos = [0, 0]
    @mouse_pos = Sprite.new
    @mouse_pos.bitmap = Bitmap.new(640, 400)
    @mouse_pos.x, @mouse_pos.y = 1, 1
    @image_box = RGUI::Component::ImageBox.new({
                                                   image: $g.load_image('Pictures/bg1.png'),
                                                   focus_object: false,
                                                   type: RGUI::Component::ImageBoxType::Responsive
                                               })
    @image_box.event_manager.on(:KEY_A){ |em| em.object.x_scroll(-5) }
    @image_box.event_manager.on(:KEY_D){ |em| em.object.x_scroll(+5) }
    @image_box.event_manager.on(:KEY_W){ |em| em.object.y_scroll(-5) }
    @image_box.event_manager.on(:KEY_S){ |em| em.object.y_scroll(+5) }
    @image_box.action_manager.add_action(:breath, {speed: 0.6})
    add_child(@image_box)
    images = $g.load_image('Pictures/btn_1.png').cut_bitmap(3, 0)
    @label = RGUI::Component::Label.new({
                                            width: 640,
                                            height: 320,
                                            text: 'hello world',
                                            size: 56
                                        })
    @button = RGUI::Component::SpriteButton.new({
                                                    x: 400,
                                                    y: 10,
                                                    images: images
                                                })
    @button.event_manager.on(:click){
      log.info 'button click' }
    add_child(@button)
  end
  
  def update
    super
    exit if Input.down?(:KEY_ESC)
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
