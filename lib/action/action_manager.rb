# encoding:utf-8

require_relative 'action_base'
require_relative 'interpolator'

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
        action_class = ActionManager.actions[name]
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