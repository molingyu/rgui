# encoding:utf-8

module RGUI
  module Action
    class ActionBase

      def initialize(speed)
        @alive = true
        @index = 0
        @speed = speed
      end

      def alive?
        @alive
      end
    end
  end
end