# encoding:utf-8

class Timer

  @@list = []

  def self.update
    @@list.each{|o| o.update if o != nil } if @@list != []
  end

  attr_reader :status

  TimerEvent = Struct.new(:start_time, :time, :block)

  def initialize
    @@list.push(self)
    @afters = []
    @everys = []
    @status = :run
    @stops_time = 0
  end

  def start
    return if @status == :run
    @stops_time += Time.now - @stop_time
    @status = :run
  end

  def stop
    return if @status == :stop
    @stop_time = Time.now
    @status = :stop
  end

  def after(time, &block)
    @afters.push object = TimerEvent.new(Time.now, time, block)
    object
  end

  def every(time, &block)
    @everys.push object = TimerEvent.new(Time.now, time, block)
    object
  end

  def delete_every(object)
    @everys.delete(object)
  end

  def delete_after(object)
    @afters.delete(object)
  end

  def dispose
    @@list.delete(self)
    @afters.clear
    @everys.clear
  end

  def update_afters
    return if @afters == []
    @afters.each do |o|
      if Time.now - o.start_time - @stops_time >= o.time
        o.block.call
        @afters.delete(o)
      end
    end
  end

  def update_everys
    return if @everys == []
    @everys.each do |o|
      if Time.now - o.start_time - @stops_time >= o.time
        o.block.call
        o.start_time = Time.now
        @stops_time = 0
      end
    end
  end

  def update
    update_afters
    update_everys
  end

end