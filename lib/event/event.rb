# encoding:utf-8

module RGUI
  module Event
    # noinspection RubyArgCount
    class Event < Array
      # event name
      # @return [Symbol]
      attr_reader :name
      # event type
      # @return [Symbol]
      attr_reader :type
      # keyboard event key name
      # @return [Symbol]
      attr_reader :key_name

      def initialize(name, type, key_name = nil)
        super()
        @name = name
        @type = type
        @key_name = key_name
      end
    end
  end
end