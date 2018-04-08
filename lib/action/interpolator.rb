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
        self
      end


      def get(index)
        @start_status + @proc[(@end_status - @start_status), @count, index]
      end

    end

    module Easing

      EasingBase = Struct.new(:in, :out, :in_out)
      Quadratic = EasingBase.new
      Linear = EasingBase.new

      class << self

        def linear_init
          callback = proc {|v, c, i| (v * i.to_f / c).to_i }
          Linear.out = callback
          Linear.in = callback
          Linear.in_out = callback
        end

        def quadratic_init
          # Quadratic.define_singleton_method(:out) {}
          # Quadratic.define_singleton_method(:in) {}
          # Quadratic.define_singleton_method(:in_out) {}
        end

      end

    end

    Easing.linear_init
    Easing.quadratic_init
  end
end