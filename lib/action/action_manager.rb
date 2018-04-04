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

      def initialize(object)
        @object = object
        @actions = []
      end

      def add_action(name, param)
        action = @@actions[name]
        raise("error action name") unless action
        @actions.push(action.new(param))
      end

      def update
        return @object.event_manager.trigger(:action_end) if @actions == []
        @actions.each do |action|
          action.update(@object)
          @actions.delete unless action.alive?
        end
      end
    end
  end
end