# encoding:utf-8

require_relative 'base'

module RGUI
  module Component

    class SpriteButton < BaseComponent

      attr_reader :default_image
      attr_reader :highlight_image
      attr_reader :press_image
      attr_reader :disable_image
      attr_reader :sprite

      def initialize(conf = {})
        super(conf)
        @default_image = conf[:default_image] || conf[:images][0]
        @highlight_image = conf[:highlight_image] || conf[:images][1]
        @press_image = conf[:press_image] || conf[:images][2]
        @disable_image = conf[:disable_image] || conf[:images][3]
        @sprite = Sprite.new
        @sprite.x, @sprite.y = @x, @y
        @sprite.z = @z if @z
        @sprite.opacity = @visible ? @opacity : 0
        def_attrs_writer :default_image, :highlight_image, :press_image, :disable_image
        create
      end


      def create
        super
        @sprite.bitmap = @status ? @default_image : @disable_image
        @width = sprite.bitmap.width
        @height = sprite.bitmap.height
        @collision_box.update_size(@width, @height)
      end

      def dispose
        super
        @sprite.dispose
      end

      def def_event_callback
        super
        @event_manager.on([:change_x, :change_y, :change_z, :move, :move_to, :change_width, :change_height, :change_size]) do |em|
          sprite = em.object.sprite
          sprite.x, sprite.y = em.object.x, em.object.y
          sprite.z = em.object.z if em.object.z
          sprite.zoom_x = em.object.width.to_f / sprite.bitmap.width
          sprite.zoom_y = em.object.height.to_f / sprite.bitmap.height
        end
        @event_manager.on(:mouse_in){ |em| em.object.sprite.bitmap = em.object.highlight_image }
        @event_manager.on([:mouse_out, :keydown_MOUSE_LB]){ |em| em.object.sprite.bitmap = em.object.default_image }
        @event_manager.on(:keydown_MOUSE_LB){ |em| em.object.sprite.bitmap = em.object.press_image }
        @event_manager.on([:change_status, :enable, :disable]){ |em|
          em.object.sprite.bitmap = em.object.status ? em.object.default_image : em.object.disable_image
        }
      end
    end
  end
end
