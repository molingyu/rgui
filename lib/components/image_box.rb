# encoding:utf-8

require_relative 'base'

module RGUI
  module Component
    class ImageBox < BaseComponent

      attr_reader :image
      attr_reader :type
      attr_reader :x_wheel
      attr_reader :y_wheel

      def initialize(conf)
        super(conf)

        create
      end

      def create
        super
      end

      def x_scroll(value)

      end

      def y_scroll(value)

      end

    end
  end
end
