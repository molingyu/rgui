# encoding:utf-8
module RGUI
  module Event
    class Event < Array
      # event name
      # @return [Symbol]
      attr_reader :name
      # event type
      # @return [Symbol]
      attr_reader :type

      def initialize(name, type)
        super()
        @name = name
        @type = type
      end
    end
  end
end