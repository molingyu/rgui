# encoding:utf-8

require_relative './box/aabb'

module RGUI
  module Collision
    class CollisionManager

      attr_reader :object

      def initialize(object)
        @object = object
        @boxes = []
        default_create
      end

      def default_create
        box = AABB.new(object.x, object.y, object.width, object.height)
        @boxes.push(box)
      end

      def update_create(&block)
        @boxes.clear
        block(self)
      end

      def update_pos
        @boxes.each { |box| box.update_pos(object.x, object.y) }
      end

      def update_size
        @boxes.each { |box| box.update_size(object.width, object.height) }
      end

      def hit(x, y)
        @boxes.each {|box| return true if box.hit(x, y) }
      end

    end
  end
end