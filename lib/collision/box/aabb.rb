# encoding:utf-8

module RGUI
  module Collision
    class AABB

      def initialize(x, y, width, height)
        @x = x
        @y = y
        @width = width
        @height = height
      end

      def hit(x, y)
        @x < x && x < (@x + @width) && @y < y && y < (@y + @height)
      end

      def update_pos(x, y)
        @x = x
        @y = y
      end

      def update_size(x, y)
        @width = width
        @height = height
      end
    end
  end
end