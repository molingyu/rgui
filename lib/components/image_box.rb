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

      attr_reader :sprite

      def initialize(conf)
        super(conf)
        @image = conf[:image] || Bitmap.new(32, 32).fill_rect(0, 0, 32, 32, Color.new(0, 0, 0, 255))
        @sprite = Sprite.new
        @sprite.x, @sprite.y = @x, @y
        @sprite.z = @z if @z
        @sprite.opacity = @opacity
        @type = conf[:type] || 0
        @x_wheel = conf[:x_wheel] || 0
        @y_wheel = conf[:y_wheel] || 0
        def_attrs_writer :image, :type, :x_wheel, :y_wheel
        create
      end

      def def_event_callback
        super
        @event_manager.on(:change_opacity){ |em|
          em.object.sprite.opacity = em.object.opacity
        }
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
            @sprite.src_rect = Rect.new(@x_wheel, @y_wheel, @width, @height)
          when ImageBoxType::Filling
            @sprite.bitmap = @image
            @sprite.zoom_x = @width.to_f / @image.width
            @sprite.zoom_y = @height.to_f / @image.height
          when ImageBoxType::Responsive
            @sprite.bitmap = @image
            change_size(@image.width, @image.height)
          else
            raise "ImageBox:type error"
        end
      end

      def x_scroll(value)
        return if value == 0 || @type != ImageBoxType::Tiling
        @x_wheel += value if @x_wheel + value > 0 && @x_wheel + value < @image.width - @width
        @event_manager.trigger(:x_scroll)
      end

      def y_scroll(value)
        return if value == 0 || @type != ImageBoxType::Tiling
        @y_wheel += value if @y_wheel + value > 0 && @y_wheel + value < @image.height - @height
        @event_manager.trigger(:y_scroll)
      end

    end
  end
end
