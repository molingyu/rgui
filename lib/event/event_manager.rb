# encoding:utf-8

require_relative 'event'
require_relative 'event_helper'
require_relative 'event_callback_fiber'

module RGUI
  module Event
    # Event manager.
    class EventManager

      class Callback < Proc
        attr_reader :async
        attr_reader :immediately

        def initialize(async, immediately, &callback)
          super(&callback)
          @async = async
          @immediately = immediately
        end
      end

      class << self
        attr_accessor :type_getters

        # @param [Symbol] name  event name.
        # @return [Symbol] event type.
        def get_type(name)
          @type_getters.each do |_, getter|
            return getter[name] if getter[name]
          end
        end

        def init
          @type_getters = {:event_system => proc{ |name| return :event_system if /^event_manager_.*/.match(name.to_s) } }
        end

      end

      include EventHelper

      def initialize(object)
        EventManager.init
        @object = object
        @events = {}
        @event_callback_fibers = {}
        @mouse_focus = false
        @keyboard_events = []
      end

      def update_fiber
        return if @event_callback_fibers.length == []
        @event_callback_fibers.each do |fiber|
          @current_fiber = fiber
          fiber.resume
          @current_fiber = nil
          @event_callback_fibers.delete(fiber) unless fiber.alive?
        end
      end

      def update_mouse
        x, y = Input.get_pos
        collision = @object.collision_manager
        if !@mouse_focus && collision.point_hit(x, y)
          trigger('mouse_in', {:x=>x, :y=>y})
          @mouse_focus = true
        elsif @mouse_focus && !collision.point_hit(x, y)
          trigger('mouse_out', {:x=>x, :y=>y})
          @mouse_focus = false
        end
        trigger('mouse_scroll', {:value => Input.scroll_value}) if Input.scroll?
      end

      def update_keyboard(event)
        type, name = event.name,split('|')
        return if name['MOUSE'] && !@mouse_focus
        case type
          when 'keydown'
            trigger(event.name) if Input.down?(name)
          when 'keypress'
            trigger(event.name) if Input.press?(name)
          when 'keyup'
            trigger(event.name) if Input.up?(name)
          else
            raise 'Error:Keyboard event type error!'
        end
      end

      def update
        update_fiber
        if @object.status && @object.visible
          update_mouse
          @keyboard_events.each{ |o| update_keyboard(o) }
        end
      end

      # @param [Symbol] name
      # @param [Hash] info
      def trigger(name, info = {})
        event = @events[name]
        return unless event
        event.each do |callback|
          next callback[info] if !callback.async && callback.immediately
          unless @event_callback_fibers[callback.object_id]
            @event_callback_fibers[callback.object_id] = EventCallbackFiber.new(self, name, callback, info)
          else
            @event_callback_fibers[callback.object_id].count += 1
          end
        end
      end

      # @param [Regexp] name_regexp
      # @param [Hash] info
      def triggers(name_regexp, info = {})
        @events.each do |name|
          trigger(name, info) if name_regexp.match(name)
        end
      end

      # @private
      def _on(name, immediately, async, callback)
        @events[name] = Event.new(name, EventManager.get_type(name)) unless @events[name]
        @events[name].push(Callback.new(async, immediately, &callback))
      end

      # @param [Symbol|Array<Symbol>] name
      # @param [Boolean] immediately
      # @param [Proc] callback
      def on(name, immediately = false, &callback)
        if name.class == Array
          return names.each{ |name| on(name, false, &callback)  }
        end
        _on(name, immediately, false, callback)
      end

      # @param [Symbol|Array<Symbol>] name
      # @param [Boolean] immediately
      # @param [Proc] callback
      def on_async(name, immediately = false, &callback)
        if name.class == Array
          return names.each{ |name| on_async(name, false, &callback)  }
        end
        _on(name, immediately, true, callback)
      end

    end
  end
end