# encoding:utf-8

require_relative 'base'

module RGUI
  module Component
    class ProgressBar < BaseComponent
      attr_reader :bg_image
      attr_reader :fg_image
      attr_reader :ox
      attr_reader :oy
      attr_reader :value
      # 0竖向↑ 1竖向↓ 2横向← 3横向→
      attr_reader :direction
      attr_reader :bg_sprite
      attr_reader :fg_sprite

      def initialize(conf)
        super(conf)
        @bg_image = conf[:bg_image] || nil
        @fg_image = conf[:fg_image] || nil
        raise "Must have fg image" unless @fg_image
        @ox = conf[:ox] || 0
        @oy = conf[:oy] || 0
        @direction = conf[:direction] || 2
        @value = conf[:value] || 1
        if @fg_image
          @bg_sprite = Sprite.new
          @bg_sprite.x, @bg_sprite.y = @x, @y
          @bg_sprite.z = @z if @z
          @bg_sprite.bitmap = @bg_image
          @bg_sprite.opacity = @visible ? @opacity : 0

        end
        @fg_sprite = Sprite.new
        @fg_sprite.x, @fg_sprite.y = @x + @ox, @y + @oy
        @fg_sprite.z = @z if @z
        @fg_sprite.bitmap = Bitmap.new(@fg_image.width, @fg_image.height)
        @fg_sprite.opacity = @visible ? @opacity : 0
        @width = @bg_image ? @bg_image.width : @fg_image.width
        @height = @bg_image ? @bg_image.height : @fg_image.height
        @collision_box.update_size(@width, @height)
        def_attrs_writer :bg_image, :ox, :oy, :fg_image, :direction
        create
      end

      def value=(value)
        value = value.range(0, 1)
        return if value == @value
        old = @value
        @value = value
        @event_manager.trigger(('change_value').to_sym, {:old => old, :new => value})
      end

      def create
        refresh
        super
      end

      def dispose
        super
        @bg_sprite.dispose if @bg_sprite
        @fg_sprite.dispose
      end

      def refresh
        @fg_sprite.bitmap.clear
        x, y, w, h = 0
        case @direction
        when 0 # ↑
          w = @fg_image.width
          h = (@fg_image.height * @value).round
        when 1 # ↓
          x = 0
          w = @fg_image.width
          h = (@fg_image.height * @value).round
          y = @fg_image.height - h
        when 2 # ←
          w = (@fg_image.width * @value).round
          h = @fg_image.height
        when 3 # →
          y = 0
          w = (@fg_image.width * @value).round
          x = @fg_image.width - w
          h = @fg_image.height
        end
        rect = Rect.new(x, y, w, h)
        @fg_sprite.bitmap.stretch_blt(rect, @fg_image, rect)
      end

      def def_event_callback
        super
        @event_manager.on([:change_x, :change_y, :change_ox, :change_oy, :change_z, :move, :move_to, :change_width, :change_height, :change_size, :change_bg_image]) do |em|
          bg_sprite = em.object.bg_sprite
          if bg_sprite
            bg_sprite.x, bg_sprite.y = em.object.x, em.object.y
            bg_sprite.z = em.object.z if em.object.z
            bg_sprite.zoom_x = em.object.width.to_f / bg_sprite.bitmap.width
            bg_sprite.zoom_y = em.object.height.to_f / bg_sprite.bitmap.height
          end
          fg_sprite = em.object.fg_sprite
          fg_sprite.x, fg_sprite.y = em.object.x + em.object.ox, em.object.y + em.object.oy
          fg_sprite.z = em.object.z if em.object.z
          fg_sprite.zoom_x = em.object.width.to_f / fg_sprite.bitmap.width
          fg_sprite.zoom_y = em.object.height.to_f / fg_sprite.bitmap.height
          @width = bg_sprite ? @bg_image.width : @fg_image.width
          @height = bg_sprite ? @bg_image.width : @fg_image.height
          @collision_box.update_size(@width, @height)
        end
        @event_manager.on([:change_value, :fg_image, :direction]) { |_| refresh }
      end

    end
  end
end
