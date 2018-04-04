
# File C:/Users/z1522/Documents/GitHub/RGUI/lib/version.rb
module RGUI
  VERSION = '0.1.0'
end
# File C:/Users/z1522/Documents/GitHub/RGUI/lib/event/event.rb
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
# File C:/Users/z1522/Documents/GitHub/RGUI/lib/event/event_helper.rb
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
# File C:/Users/z1522/Documents/GitHub/RGUI/lib/event/event_callback_fiber.rb
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
# File C:/Users/z1522/Documents/GitHub/RGUI/lib/event/event_manager.rb
# encoding:utf-8

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
          update_mouse if RGUI::MOUSE
          @keyboard_events.each{ |o| update_keyboard(o) } if RGUI::KEYBOARD
        end
      end

      # @param [Symbol] name
      # @param [Hash] info
      def trigger(name, info = {})
        event = @events[name]
        return unless event
        event.each do |callback|
          next callback[info] if !callback.async && callback.immediately
          if @event_callback_fibers[callback.object_id]
            @event_callback_fibers[callback.object_id].count += 1
          else
            @event_callback_fibers[callback.object_id] = EventCallbackFiber.new(self, name, callback, info)
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
# File C:/Users/z1522/Documents/GitHub/RGUI/lib/action/action_base.rb
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
# File C:/Users/z1522/Documents/GitHub/RGUI/lib/action/interpolator.rb
# encoding:utf-8

module RGUI
  module Action

    class Interpolator
      def initialize(start)
        @start_status = start
      end

      def to(end_status)
        @end_status = end_status
        self
      end

      def easing(easing_proc)
        @proc = easing_proc
        self
      end

      def start(count)
        @count = count
      end


      def get(index)
        @start_status + @proc[(@end_status - @start_status).abs, @count, index]
      end

    end

    module Easing

      module Quadratic end
      module Linear end

      class << self

        def linear_init
          callback = proc {|v, c, i| return v * (i / c).floor }
          Linear.define_singleton_method(:out, &callback)
          Linear.define_singleton_method(:in, &callback)
          Linear.define_singleton_method(:in_out, &callback)
        end

        def quadratic_init
          Quadratic.define_singleton_method(:out) {}
          Quadratic.define_singleton_method(:in) {}
          Quadratic.define_singleton_method(:in_out) {}
        end

      end

    end

    Easing.linear_init
    Easing.quadratic_init
  end
end
# File C:/Users/z1522/Documents/GitHub/RGUI/lib/action/action_manager.rb
# encoding:utf-8

module RGUI
  module Action
    class ActionManager
      class << self
        attr_reader :actions

        def init
          @actions = {}
        end

        def use(name, action_class)
          @actions[name] = action_class
        end
      end

      attr_reader :actions

      # @param [RGUI::Base] object
      def initialize(object)
        @object = object
        @actions = []
      end

      def add_action(name, param)
        action_class = @@actions[name]
        raise("error action name") unless action
        action = action_class.new(param)
        @actions.push(action)
        @object.event_manager.on(:action_end) { action.close }
      end

      def update
        return @object.event_manager.trigger(:action_end) if @actions == []
        @actions.each do |action|
          action.update(@object)
          @actions.delete unless action.alive?
        end
      end
    end

    ActionManager.init

  end
end
# File C:/Users/z1522/Documents/GitHub/RGUI/lib/action/actions/breath.rb
# encoding:utf-8

module RGUI
  module Action
    class Breath < ActionBase

      def initialize(conf)
        super(conf.speed)
        @start_alpha = conf.start_alpha || 255
        @end_alpha = conf.end_alpha  || 20
        @count = conf.speed * 60
        @interpolator = Interpolator.new(@start_alpha).to(@end_alpha).easing(Easing::Linear.out).start(@count)
      end

      # @param [RGUI::Base] object
      def update(object)
        object.opacity = @interpolator.get(@index - 1) if @index == @count
        object.opacity = @interpolator.get(@index + 1) if @index == 0
      end

      def close(object)
        object.opacity = 255
      end

    end

    ActionManager.use(:breath, Breath)
  end
end

# File C:/Users/z1522/Documents/GitHub/RGUI/lib/action/actions/index.rb

# File C:/Users/z1522/Documents/GitHub/RGUI/lib/collision/box/aabb.rb
# encoding:utf-8

module RGUI
  module Collision
    class AABB

      def initialize(x, y, width, height)
        @x = x
        @y = y
        @width = width
        @height = height
      end

      def hit(x, y)
        @x < x && x < (@x + @width) && @y < y && y < (@y + @height)
      end

      def update_pos(x, y)
        @x = x
        @y = y
      end

      def update_size(x, y)
        @width = width
        @height = height
      end
    end
  end
end
# File C:/Users/z1522/Documents/GitHub/RGUI/lib/collision/collision_manager.rb
# encoding:utf-8

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
        block[self]
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
# File C:/Users/z1522/Documents/GitHub/RGUI/lib/components/base.rb
# encoding:utf-8

module RGUI
  module Component
    class BaseComponent
      attr_reader :x
      attr_reader :y
      attr_reader :z
      attr_reader :width
      attr_reader :height
      attr_reader :viewport
      attr_reader :focus
      attr_reader :visible
      attr_reader :opacity
      attr_reader :status
      attr_reader :parent
      attr_reader :event_manager
      attr_reader :action_manager
      attr_reader :collision_manager

      def initialize(conf = {})
        @x = conf[:x] || 0
        @y = conf[:y] || 0
        @z = conf[:z]
        @width = conf[:width] || 0
        @height = conf[:height] || 0
        @viewport = conf[:viewport]
        @z = @viewport.z if @viewport
        @focus = conf[:focus]
        @visible = conf[:visible]
        @opacity = conf[:opacity] if 255
        @status = conf[:status]
        @parent = conf[:parent]
        @event_manager = Event::EventManager.new(self)
        @action_manager = Action::ActionManager.new(self)
        @collision_manager = Collision::CollisionManager.new(self)
        def_attrs_writer([
            :x, :y, :z, :width, :height, :viewport,
            :focus, :visible, :opacity, :status, :parent
        ])
      end

      def def_attrs_writer(attrs)
        attrs.each do |atttr_name|
          define_singleton_method((atttr_name.to_s + '=').to_sym) do |value|
            attr_value = class_variable_get(('@' + atttr_name.to_s).to_sym)
            unless attr_value == value
              old, attr_value = attr_value, value
              @event_manager.trigger(('change_' + atttr_name.to_s).to_sym, {:old => old, :new => attr_value})
            end
          end
        end
      end

      def def_event_callback
        @event_manager.on([:change_x, :change_y, :move, :move_to]) do |em|
          em.object.collision_manager.update_pos
        end

        @event_manager.on([:change_width, :change_height, :change_size]) do |em|
          em.object.collision_manager.update_size
        end
      end

      def create
        def_event_callback
        @event_manager.trigger(:create)
      end

      def update
        @event_manager.update
        @action_manager.update
        @collision_manager.update
      end

      def close
        @event_manager.trigger(:close)
        if @action_manager.actions != []
          @event_manager.on(:action_end) { self.dispose }
        else
          dispose
        end
      end

      def dispose
        @event_manager.trigger(:dispose) unless disposed?
      end

      def disposed?
      end

      def get_focus
        return if @focus
        self.focus = true
        @event_manager.trigger(:get_focus)
      end

      def lost_focus
        return unless @focus
        self.focus = false
        @event_manager.trigger(:lost_focus)
      end

      def show
        return if @visible
        self.visible = true
        @event_manager.trigger(:show)
      end

      def hide
        return unless @visible
        self.visible = false
        @event_manager.trigger(:hide)
      end

      def enable
        return if @status
        self.status = true
        @event_manager.trigger(:enable)
      end

      def disable
        return unless @status
        self.status = false
        @event_manager.trigger(:disable)
      end

      def move(x, y = x)
        return if x == 0 && y == 0
        old = {:x => self.x, :y => self.y }
        self.x += x
        self.y += y || x
        @event_manager.trigger(:move, {:old => old, :new => {:x => self.x, :y => self.y }})
      end

      def move_to(x, y = x)
        return if @x == x && @y == y
        old = {:x => self.x, :y => self.y }
        self.x = x
        self.y = y
        @event_manager.trigger(:move_to, {:old => old, :new => {:x => self.x, :y => self.y }})
      end

      def change_size(width, height = width)
        return if @width == width && @height == height
        old = { :width => self.width, :height => self.height }
        self.width = width
        self.height = height
        @event_manager.trigger(:change_size, {:old => old, :new => { :width => self.width, :height => self.height }})
      end
    end
  end
end
# File C:/Users/z1522/Documents/GitHub/RGUI/lib/components/image_box.rb
# encoding:utf-8

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

# File C:/Users/z1522/Documents/GitHub/RGUI/lib/components/index.rb

# File lib/rgui.rb
# encoding:utf-8

module RGUI

  MOUSE = true
  KEYBOARD = true
  CONTROLS = 0

end