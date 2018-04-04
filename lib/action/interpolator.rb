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

      end

    end

    Easing.linear_init
  end
end