# encoding:utf-8

require_relative 'event'
require_relative 'event_helper'
require_relative 'event_callback_fiber'

module RGUI
  module Event
    class Callback < Proc
      attr_reader :immediately
      def initialize(immediately, &callback)
        super(&callback)
        @immediately = immediately
      end
    end

    # Event manager.
    class EventManager
      class << self
        attr_reader :type_getters
        # @return [RGUI::Component::BaseComponent]
        attr_accessor :focus_object

        # @param [Symbol] name  event name.
        # @return [Symbol] event type.
        def get_type(name)
          @type_getters.each do |_, getter|
            if getter[name]
              return getter[name]
            end
          end
          [name, nil]
        end

        def add(type, &type_proc)
          @type_getters[type] = type_proc
        end

        def init
          @focus_object = nil
          @type_getters = {}
          add(:event_system){ |name|  [name, :event_system] if name.to_s =~ /^event_manager_.*/ }
          add(:mouse){ |name| [name, :mouse] if name.to_s =~ /^mouse_.*/ }
          add(:keyboard){ |name| [name, :keypress] if Input::KEY_VALUE.include?(name) }
          add(:keyup){ |name| [$1.to_sym, :keyup] if name.to_s =~ /^keyup_(.*)/ }
          add(:keydown){ |name| [$1.to_sym, :keydown] if name.to_s =~ /^keydown_(.*)/ }
          add(:keypress){ |name| [$1.to_sym, :keypress] if name.to_s =~ /^keypress_(.*)/ }
          add(:click){ |name| [:MOUSE_LB, :keyup] if name == :click }
        end

      end

      include EventHelper

      # @return [RGUI::Component::BaseComponent]
      attr_reader :object
      attr_reader :filter_timers
      attr_reader :filter_counters

      # @param [RGUI::Component::BaseComponent] object
      def initialize(object)
        @object = object
        @events = {}
        @event_callback_fibers = []
        @mouse_focus = false
        @keyboard_events = []
        @mouse_events = []
        @filter_timers = {}
        @filter_counters = {}
      end

      def update_fiber
        return if @event_callback_fibers.length == 0
        @event_callback_fibers.each do
          # @type fiber [EventCallbackFiber]
        |fiber|
          @current_fiber = fiber
          fiber.resume
          @current_fiber = nil
          @event_callback_fibers.delete(fiber) unless fiber.alive?
        end
      end

      def update_mouse
        x, y = Input.get_pos
        collision = @object.collision_box
        if !@mouse_focus && collision.point_hit(x, y)
          trigger(:mouse_in, {:x=>x, :y=>y})
          @mouse_focus = true
        elsif @mouse_focus && !collision.point_hit(x, y)
          trigger(:mouse_out, {:x=>x, :y=>y})
          @mouse_focus = false
        end
        if @object.focus
          trigger(:mouse_scroll_down, {:value => Input.mouse_wheel }) if Input.wheel_down?
          trigger(:mouse_scroll_up, {:value => Input.mouse_wheel }) if Input.wheel_up?
        end
      end

      # @param [Event] event
      def update_keyboard(event)
        return if event.name.to_s.include?('MOUSE') && !@mouse_focus
        case event.type
          when :keydown
            return trigger(event.name) if Input.down?(event.key_name)
        when :keypress
            return trigger(event.name) if Input.press?(event.key_name)
          when :keyup
            return trigger(event.name) if Input.up?(event.key_name)
          else
            raise 'Error:Keyboard event type error!'
        end
      end

      def update
        update_fiber
        if @object.status && @object.visible
          update_mouse
          @mouse_events.each{ |o| update_keyboard(o) } if @mouse_focus
          @keyboard_events.each{ |o| update_keyboard(o) } if @object.focus
        end
      end

      # @param [Symbol] name
      # @param [Hash] info
      def trigger(name, info = {})
        # @type [Event]
        event = @events[name]
        return unless event
        event.each do
          # @type callback [Callback]
        |callback|
          next callback[info] if callback.immediately
          @filter_counters[callback.object_id] += 1 if @filter_counters[name]
          @event_callback_fibers << EventCallbackFiber.new(self, name, callback, info)
        end
      end

      # @param [Regexp] name_regexp
      # @param [Hash] info
      def triggers(name_regexp, info = {})
        @events.each do |name|
          trigger(name, info) if name_regexp.match(name)
        end
      end

      # @param [Symbol|Array<Symbol>] name
      # @param [Boolean] immediately
      # @param [Proc] callback
      def on(name, immediately = false, &callback)
        if name.class == Array
          return name.each{ |str| on(str, immediately, &callback)  }
        end
        key_name, type = EventManager.get_type(name)
        @events[name] = Event.new(name, type, key_name) unless @events[name]
        @events[name].push(Callback.new(immediately, &callback))
        if [:keydown, :keyup, :keypress].include? type
          if name.to_s.include? 'MOUSE'
            @mouse_events << @events[name] unless  @mouse_events.include? @events[name]
          else
            @keyboard_events << @events[name] unless  @keyboard_events.include? @events[name]
          end
        end
      end

    end

    EventManager.init

  end
end