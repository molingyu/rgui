# encoding:utf-8

require_relative '../event/event_manager'
require_relative '../action/action_manager'
require_relative '../collision/index'

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
      # @return [RGUI::Collision::CollisionBase]
      attr_reader :collision_box
      # @return [Boolean]
      attr_reader :i18n

      def initialize(conf = {})
        @x = conf[:x] || 0
        @y = conf[:y] || 0
        @z = conf[:z] || 0
        @width = conf[:width] || 0
        @height = conf[:height] || 0
        @focus = false
        @visible = conf[:visible] || true
        @opacity = conf[:opacity] || 255
        @status = conf[:status] || true
        @parent = conf[:parent]
        @event_manager = Event::EventManager.new(self)
        @action_manager = Action::ActionManager.new(self)
        @collision_box = Collision::AABB.new(@x, @y, @width, @height)
        @i18n = conf[:i18n] || false
        def_attrs_writer :x, :y, :z, :width, :height, :viewport, :focus_object, :visible, :opacity, :status, :parent
      end

      def def_attrs_writer(*attrs)
        attrs.each do |atttr_name|
          define_singleton_method((atttr_name.to_s + '=').to_sym) do |value|
            attr_value = instance_variable_get(('@' + atttr_name.to_s).to_sym)
            unless attr_value == value
              old = attr_value
              instance_variable_set(('@' + atttr_name.to_s).to_sym, value)
              @event_manager.trigger(('change_' + atttr_name.to_s).to_sym, {:old => old, :new => attr_value})
            end
          end
        end
      end

      def def_event_callback
        @event_manager.on([:change_x, :change_y, :move, :move_to]) do
          # @type em [RGUI::Event::EventManager]
        |em, info|
          em.object.collision_box.update_pos(info[:new][:x], info[:new][:y])
        end

        @event_manager.on([:change_width, :change_height, :change_size]) do
          # @type em [RGUI::Event::EventManager]
        |em, info|
          em.object.collision_box.update_size(info[:new][:width], info[:new][:height])
        end

        @event_manager.on(:keydown_MOUSE_LB)do
          # @type helper [RGUI::Event::EventManager|RGUI::Event::EventHelper]
        |em|
          em.object.get_focus
          RGUI::Event::EventManager.focus_object.lost_focus if RGUI::Event::EventManager.focus_object
          RGUI::Event::EventManager.focus_object = em.object
          em.filter{ em.time_min(0.3) }
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
        @focus = true
        @event_manager.trigger(:get_focus)
      end

      def lost_focus
        return unless @focus
        @focus = false
        @event_manager.trigger(:lost_focus)
      end

      def show
        return if @visible
        @visible = true
        @event_manager.trigger(:show)
      end

      def hide
        return unless @visible
        @visible = false
        @event_manager.trigger(:hide)
      end

      def enable
        return if @status
        @status = true
        @event_manager.trigger(:enable)
      end

      def disable
        return unless @status
        @status = false
        @event_manager.trigger(:disable)
      end

      def move(x, y = x)
        return if x == 0 && y == 0
        old = {:x => self.x, :y => self.y }
        @x += x
        @y += y || x
        @event_manager.trigger(:move, {:old => old, :new => {:x => self.x, :y => self.y }})
      end

      def move_to(x, y = x)
        return if @x == x && @y == y
        old = {:x => self.x, :y => self.y }
        @x = x
        @y = y
        @event_manager.trigger(:move_to, {:old => old, :new => {:x => self.x, :y => self.y }})
      end

      def change_size(width, height)
        return if @width == width && @height == height
        old = { :width => self.width, :height => self.height }
        @width = width
        @height = height
        @collision_box.update_size(@width, @height)
        @event_manager.trigger(:change_size, {:old => old, :new => { :width => self.width, :height => self.height }})
      end

      def em
        event_manager
      end

      def am
        action_manager
      end
    end
  end
end