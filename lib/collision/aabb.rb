# encoding:utf-8

require_relative 'collision_base'

module RGUI
  module Collision
    class AABB < CollisionBase

      def initialize(x, y, width, height)
        @x = x
        @y = y
        @width = width
        @height = height
      end

      def point_hit(x, y)
        @x < x && x < (@x + @width) && @y < y && y < (@y + @height)
      end

      def update_pos(x, y)
        @x = x
        @y = y
      end

      def update_size(width, height)
        @width = width
        @height = height
      end
    end
  end
end