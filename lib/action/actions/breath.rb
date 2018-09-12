# encoding:utf-8

require_relative '../action_base'
require_relative '../interpolator'
require_relative '../action_manager'

module RGUI
  module Action
    class Breath < ActionBase

      def initialize(conf)
        super(conf[:speed])
        @start_alpha = conf[:start_alpha] || 255
        @end_alpha = conf[:end_alpha]  || 20
        @count = 60.to_f / @speed
        @sym = ''
        @interpolator = Interpolator.new(@start_alpha).to(@end_alpha).easing(Easing::Linear.out).start(@count)
      end

      # @param [RGUI::BaseComponent] object
      def update(object)
        @sym = :- if @index >= @count
        @sym = :+ if @index <= 0
        object.opacity = @interpolator.get(@index)
        @index = @index.send(@sym, 1)
      end

      def close(object)
        object.opacity = 255
      end

    end

    ActionManager.use(:breath, Breath)
  end
end
