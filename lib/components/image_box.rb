# encoding:utf-8

require_relative 'base'

module RGUI
  module Component

    module ImageBoxType
      Tiling = 0
      Filling = 1
      Responsive = 2
    end

    class ImageBox < BaseComponent

      # ImageBox image
      # @return [Bitmap]
      attr_reader :image
      # Display style
      # @return [Integer]
      attr_reader :type
      # Scroll lateral component values
      # @return [Integer]
      attr_reader :x_wheel
      # Scroll vertical component values
      # @return [Integer]
      attr_reader :y_wheel

      def initialize(conf)
        super(conf)
        @image = conf.image || Bitmap.new(32, 32).fill_rect(0, 0, 32, 32, Color.new(0, 0, 0, 255))
        @sprite = Sprite.new(Viewport.new)
        @sprite.viewport.rect = Rect.new(@x, @y, @width, @height)
        @sprite.x, @sprite.y = @x, @y
        @sprite.z = @z if @z
        @type = conf[:type] || 0
        @x_wheel = conf[:x_wheel] || 0
        @y_wheel = conf[:y_wheel] || 0
        @sprite.bitmap = @type == ImageBoxType::Responsive ? @image : Bitmap.new(@width, @height)
        def_attrs_writer :image, :type, :x_wheel, :y_wheel
        create
      end

      def def_event_callback
        super
        @event_manager.on([:change_x, :change_y, :move, :move_to, :change_width, :change_height, :change_size,
                           :change_image, :change_type, :x_scroll, :y_scroll, :change_x_wheel, :change_wheel]) do
          refresh
        end
      end

      def create
        super
        refresh
      end

      def refresh
        case @type
          when ImageBoxType::Tiling
            @sprite.bitmap = @image
            @sprite.viewport.rect = Rect.new(@x + @x_wheel, @y + @y_wheel, @width, @height)
          when ImageBoxType::Filling
            @sprite.bitmap = @image
            @sprite.zoom_x = @width / @image.width
            @sprite.zoom_y = @height / @image.height
          when ImageBoxType::Responsive
            @sprite.bitmap = @image
          else
            raise "ImageBox:type error"
        end
      end

      def x_scroll(value)
        return if value == 0 || @type != 0
        @x_wheel += value
        @event_manager.trigger(:x_scroll)
      end

      def y_scroll(value)
        return if value == 0 || @type != 0
        @y_wheel += value
        @event_manager.trigger(:y_scroll)
      end

    end
  end
end
