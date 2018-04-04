# encoding:utf-8
module RGUI
  module Event
    module EventHelper

      # event trigger time
      # @return [EventCallbackFiber]
      attr_accessor :current_fiber

      def have?(name)
        @events.each{ |event| return true if event.name == name }
      end

      def delete
        after_delete
        Fiber.yield true
      end

      # Delete this callback
      def after_delete
        @events[@current_fiber.name].delete(@current_fiber.callback)
      end

      # @param [Hash] info
      # @param [Proc] callback
      def await(info = nil, &callback)
        loop do
          break if callback[info]
          Fiber.yield
        end
      end

      def time_await(time)
        await { Time.now - current_fiber.time > time }
      end

      def count_await(count)
        await { current_fiber.count > count }
      end

      def filter(info = nil, &callback)
        Fiber.yield true unless callback[info]
      end

      def time_filter(time)
        filter { Time.now - current_fiber.time > time }
      end

      def count_filter(count)
        filter { current_fiber.count > count }
      end
    end
  end
end