# encoding:utf-8

require_relative '../event/event_manager'
require_relative '../action/action_manager'
require_relative '../collision/collision_manager'

module RGUI
  module Component
    class BaseComponent
      # @return [Integer]
      attr_reader :x
      # @return [Integer]
      attr_reader :y
      # @return [Integer]
      attr_reader :z
      # @return [Integer]
      attr_reader :width
      # @return [Integer]
      attr_reader :height
      # @return [Boolean]
      attr_reader :focus
      # @return [Boolean]
      attr_reader :visible
      # @return [Integer]
      attr_reader :opacity
      # @return [Boolean]
      attr_reader :status
      # @return [BaseComponent]
      attr_reader :parent
      # @return [RGUI::Event::EventManager]
      attr_reader :event_manager
      # @return [RGUI::Action::ActionManager]
      attr_reader :action_manager
      # @return [RGUI::Collision::CollisionManager]
      attr_reader :collision_manager

      def initialize(conf = {})
        @x = conf[:x] || 0
        @y = conf[:y] || 0
        @z = conf[:z] || 0
        @width = conf[:width] || 0
        @height = conf[:height] || 0
        @focus = conf[:focus]
        @visible = conf[:visible]
        @opacity = conf[:opacity] if 255
        @status = conf[:status]
        @parent = conf[:parent]
        @event_manager = Event::EventManager.new(self)
        @action_manager = Action::ActionManager.new(self)
        @collision_manager = Collision::CollisionManager.new(self)
        def_attrs_writer :x, :y, :z, :width, :height, :viewport, :focus, :visible, :opacity, :status, :parent

      end

      def def_attrs_writer(*attrs)
        attrs.each do |atttr_name|
          define_singleton_method((atttr_name.to_s + '=').to_sym) do |value|
            attr_value = instance_variable_get(('@' + atttr_name.to_s).to_sym)
            unless attr_value == value
              old, attr_value = attr_value, value
              @event_manager.trigger(('change_' + atttr_name.to_s).to_sym, {:old => old, :new => attr_value})
            end
          end
        end
      end

      def def_event_callback
        @event_manager.on([:change_x, :change_y, :move, :move_to]) do
          # @type em [RGUI::Event::EventManager]
        |em|
          em.object.collision_manager.update_pos
        end

        @event_manager.on([:change_width, :change_height, :change_size]) do
          # @type em [RGUI::Event::EventManager]
        |em|
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