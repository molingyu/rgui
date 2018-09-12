# encoding:utf-8

require_relative 'base'

module RGUI
  module Component
    class Label < BaseComponent
      attr_reader :text
      attr_reader :size
      attr_reader :font
      attr_reader :outline
      attr_reader :pixel
      attr_reader :color
      attr_reader :sprite
      attr_reader :align

      def initialize(conf = {})
        super(conf)
        @text = conf[:text] || ''
        @font = conf[:font] || Font.default_name
        @size = conf[:size] || 16
        @outline = conf[:outline].nil? ? false : conf[:outline]
        @pixel = conf[:pixel].nil? ? false : conf[:pixel]
        @color = conf[:color] || Color::WHITE
        @align = conf[:align] || 0
        @sprite = Sprite.new
        @sprite.x, @sprite.y = @x, @y
        @sprite.z = @z if @z
        @sprite.bitmap = Bitmap.new(@width, @height)
        @sprite.opacity = @visible ? @opacity : 0
        def_attrs_writer :text, :size, :color, :font, :outline, :pixel
        create
      end

      def create
        refresh
        super
      end

      def dispose
        super
        @sprite.dispose
      end

      def refresh
        @sprite.bitmap.font.name = @font
        @sprite.bitmap.font.size = @size
        @sprite.bitmap.font.outline = @outline
        @sprite.bitmap.font.pixel = @pixel
        @sprite.bitmap.font.color = @color
        rect = Rect.new(0, 0, @width, @height)
        @sprite.bitmap.clear
        @sprite.bitmap.draw_text(rect, @text, @align)
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

        @event_manager.on([:change_text, :change_size, :change_color, :change_align]) do |em|
          em.object.refresh
        end

      end

    end
  end
end