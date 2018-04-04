# encoding:utf-8

require_relative '../action_base'
require_relative '../interpolator'

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
