#encoding: utf-8
#author: shitake
#data: 16-4-20
require_relative '../view'

class TestView < View

  include RGUI::Component
  def initialize
    super
    @pos = [0, 0]
    @mouse_pos = Sprite.new
    @mouse_pos.bitmap = Bitmap.new(640, 400)
    @mouse_pos.x, @mouse_pos.y = 1, 1
    @image_box = ImageBox.new({
                                x: 1032,
                                y: 120,
                                width: 200,
                                height: 200,
                                image: $g.load_image('Pictures/bg1.png'),
                                type: ImageBoxType::Tiling
                              })
    @image_box.em.on(:keypress_KEY_A){ |em| em.object.x_scroll(-5) }
    @image_box.em.on(:keypress_KEY_D){ |em| em.object.x_scroll(+5) }
    @image_box.em.on(:mouse_scroll_down){ |em| em.object.y_scroll(+5) }
    @image_box.em.on(:mouse_scroll_up){ |em| em.object.y_scroll(-5) }
    @image_box.am.add_action(:breath, {speed: 0.6})
    add_child(@image_box)
    @label = Label.new({
                         x: 320,
                         y: 120,
                         width: 640,
                         height: 320,
                         text: 'hello world',
                         size: 56,
                         align: 1
                       })
    add_child(@label)
    @button = SpriteButton.new({
                                 x: 400,
                                 y: 10,
                                 images: $g.load_image('Pictures/btn_1.png').cut_bitmap(3, 0)
                               })
    # @button.em.on(:click){ |em| Audio.se_play(RGUI::Resource.get(:btn_audio)) }
    add_child(@button)
  end

  def update
    super
    exit if Input.up?(:KEY_ESC)
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
