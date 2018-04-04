# encoding:utf-8

module RGUI
  module Event
# Wrap the event callback function with Fiber.
    class EventCallbackFiber

      # event name
      # @return [Symbol]
      attr_reader :name
      # event callback info
      # @return [Hash]
      attr_reader :info
      # event callback
      # @return [Callback]
      attr_reader :callback
      # event trigger time
      # @return [Time]
      attr_reader :time
      # event trigger time
      # @return [Integer]
      attr_reader :count


      # @param [EventHelper] helper
      # @param [Symbol] name
      # @param [Callback] callback
      # @param [Hash] info
      def initialize(helper, name, callback, info)
        @time = Time.now
        @count = 1
        @name = name
        @info = info
        @callback = callback
        @fiber = Fiber.new do
          @callback[helper, @info]
          @fiber = nil
        end
        @return = false
        if @callback.immediately
          helper.current_fiber = self
          resume
          helper.current_fiber = nil
        end
      end

      # Resumes the event callback fiber from the point at which the last Fiber.
      # Look at {https://ruby-doc.org/core-2.2.0/Fiber.html#method-i-resume Fiber#esume} for more information.
      def resume
        if @return
          @fiber = nil
        else
          @return = @fiber.resume
        end
      end

      # Returns true if the event callback fiber can still be resumed (or transferred to).
      # @return [Boolean]
      # @see https://ruby-doc.org/core-2.2.0/Fiber.html#method-i-alive-3F Fiber#alive
      def alive?
        @fiber != nil
      end
    end
  end
end