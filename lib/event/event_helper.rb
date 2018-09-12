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
        await { Time.now - @filter_timers[@current_fiber.callback.object_id] > time }
      end

      def count_await(count)
        await { @filter_counters[@current_fiber.callback.object_id] > count }
      end

      def filter(info = nil, &callback)
        Fiber.yield true unless callback[info]
      end

      def time_equal(sym, time)
        if @filter_timers[@current_fiber.callback.object_id]
          value = (Time.now - @filter_timers[@current_fiber.callback.object_id]).send(sym, time)
          @filter_timers[current_fiber.callback.object_id] = nil
          value
        else
          @filter_timers[@current_fiber.callback.object_id] = Time.now
          Fiber.yield true
        end
      end

      def time_max(time)
        time_equal(:>, time)
      end

      def time_min(time)
        time_equal(:<, time)
      end

      def count_equal(sym, count)
        if @filter_counters[@current_fiber.callback.object_id]
          value = @filter_counters[@current_fiber.callback.object_id].send(sym, count)
          @filter_counters[current_fiber.callback.object_id] = nil
          value
        else
          @filter_counters[@current_fiber.callback.object_id] = 1
          Fiber.yield true
        end
      end

      def count_max(count)
        count_equal(:>, count)
      end

      def count_min(count)
        count_equal(:<, count)
      end

    end
  end
end