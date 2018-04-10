# encoding:utf-8
# File lib/rgss/api.rb

module API

  @api_cache = {}

  def self.to_api(str)
    @api_cache[str.hash] = Win32API.new(*str.split('|')) unless @api_cache.include? str.hash
    @api_cache[str.hash]
  end

  GetWindowThreadProcessId = self.to_api('user32|GetWindowThreadProcessId|LP|L')
  GetWindow = self.to_api('user32|GetWindow|LL|L')
  GetClassName = self.to_api('user32|GetClassName|LPL|L')
  GetCurrentThreadId = self.to_api('kernel32|GetCurrentThreadId|V|L')
  GetForegroundWindow = self.to_api('user32|GetForegroundWindow|V|L')
  GetClientRect = self.to_api('user32|GetClientRect|lp|i')

  def self.get_hwnd
    thread_id = GetCurrentThreadId.call
    hwnd = GetWindow.call(GetForegroundWindow.call, 0)
    while hwnd != 0
      if thread_id == GetWindowThreadProcessId.call(hwnd, 0)
        class_name = ' ' * 11
        GetClassName.call(hwnd, class_name, 12)
        break if class_name == 'RGSS Player'
      end
      hwnd = GetWindow.call(hwnd, 2)
    end
    hwnd
  end

  def self.get_rect
    rect = [0, 0, 0, 0].pack('l4')
    GetClientRect.call(API.get_hwnd, rect)
    Rect.array2rect(rect.unpack('l4'))
  end

end

# File lib/rgss/timer.rb

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

# File lib/rgss/rect.rb

class Rect

  def self.array2rect(array)
    Rect.new(array[0], array[1], array[2], array[3])
  end

  def rect2array
    [self.x, self.y, self.width, self.height]
  end

  def point_hit(x, y)

    self.x <= x && x <= self.width && self.y <= y && y <= self.height
  end

  def rect_hit(rect)
    rect.x < self.x + self.width || rect.y < self.y + self.height || rect.x + rect.width > self.x || rect.y + rect.height > self.y
  end

end

# File lib/rgss/input.rb

module Input

  KEY_VALUE = {
      MOUSE_LB: 0x01,
      MOUSE_RB: 0x02,
      MOUSE_MB: 0x04,

      KEY_BACK: 0x08,
      KEY_TAB: 0x09,

      KEY_CLEAR: 0x0C,
      KEY_ENTER: 0x0D,
      KEY_SHIFT: 0x10,
      KEY_CTRL: 0x11,
      KEY_ALT: 0x12,
      KEY_PAUSE: 0x13,
      KEY_CAPITAL: 0x14,
      KEY_ESC: 0x1B,
      KEY_SPACE: 0x20,
      KEY_PRIOR: 0x21,
      KEY_NEXT: 0x22,
      KEY_END: 0x23,
      KEY_HOME: 0x24,
      KEY_LEFT: 0x25,
      KEY_UP: 0x26,
      KEY_RIGHT: 0x27,
      KEY_DOWN: 0x28,
      KEY_SELECT: 0x29,
      KEY_EXECUTE: 0x2B,
      KEY_INS: 0x2D,
      KEY_DEL: 0x2E,
      KEY_HELP: 0x2F,

      KEY_0: 0x30,
      KEY_1: 0x31,
      KEY_2: 0x32,
      KEY_3: 0x33,
      KEY_4: 0x34,
      KEY_5: 0x35,
      KEY_6: 0x36,
      KEY_7: 0x37,
      KEY_8: 0x38,
      KEY_9: 0x39,

      KEY_A: 0x41,
      KEY_B: 0x42,
      KEY_C: 0x43,
      KEY_D: 0x44,
      KEY_E: 0x45,
      KEY_F: 0x46,
      KEY_G: 0x47,
      KEY_H: 0x48,
      KEY_I: 0x49,
      KEY_J: 0x4A,
      KEY_K: 0x4B,
      KEY_L: 0x4C,
      KEY_M: 0x4D,
      KEY_N: 0x4E,
      KEY_O: 0x4F,
      KEY_P: 0x50,
      KEY_Q: 0x51,
      KEY_R: 0x52,
      KEY_S: 0x53,
      KEY_T: 0x54,
      KEY_U: 0x55,
      KEY_V: 0x56,
      KEY_W: 0x57,
      KEY_X: 0x58,
      KEY_Y: 0x59,
      KEY_Z: 0x5A,
      KEY_NUM_0: 0x60,
      KEY_NUM_1: 0x61,
      KEY_NUM_2: 0x62,
      KEY_NUM_3: 0x63,
      KEY_NUM_4: 0x64,
      KEY_NUM_5: 0x65,
      KEY_NUM_6: 0x66,
      KEY_NUM_7: 0x67,
      KEY_NUM_8: 0x68,
      KEY_NUM_9: 0x69,
      KEY_NULTIPLY: 0x6A,
      KEY_ADD: 0x6B,
      KEY_SEPARATOR: 0x6C,
      KEY_SUBTRACT: 0x6D,
      KEY_DECIMAL: 0x6E,
      KEY_DIVIDE: 0x6F,

      KEY_F1: 0x70,
      KEY_F2: 0x71,
      KEY_F3: 0x72,
      KEY_F4: 0x73,
      KEY_F5: 0x74,
      KEY_F6: 0x75,
      KEY_F7: 0x76,
      KEY_F8: 0x77,
      KEY_F9: 0x78,
      KEY_F10: 0x79,
      KEY_F11: 0x7A,
      KEY_F12: 0x7B,

      KEY_NUMLOCK: 0x90,
      KEY_SCROLL: 0x91,
  }

  GetKeyboardState = API.to_api('user32|GetKeyboardState|p|i')
  GetMousePos = API.to_api('user32|GetCursorPos|p|i')
  Scr2Cli = API.to_api('user32|ScreenToClient|lp|i')

  class << self

    def init
      @old_keyboard_state = @keyboard_state = ' ' * 256
      @keyboard = Hash.new(0)
    end

    alias :shitake_core_plus_update :update

    def update
      shitake_core_plus_update
      update_keyboard
    end

    def update_keyboard
      @old_keyboard_state = @keyboard_state
      @keyboard_state = ' ' * 256
      GetKeyboardState.call(@keyboard_state)
      256.times do |i|
        next unless KEY_VALUE.index(i)
        @keyboard[i] = 2 if @keyboard[i] == 1
        @keyboard[i] = 0 if @keyboard[i] == 3
        if @keyboard_state[i] != @old_keyboard_state[i] && @old_keyboard_state[i] != ' '
          case @keyboard[i]
            when 0
              @keyboard[i] = 1
            when 2
              @keyboard[i] = 3
          end
        end
      end
    end

    def press?(key)
      key = key.to_sym if key.class == String
      value = KEY_VALUE[key]
      (@keyboard[value] == 1 || @keyboard[value] == 2)
    end

    def down?(key)
      key = key.to_sym if key.class == String
      value = KEY_VALUE[key]
      @keyboard[value] == 1
    end

    def up?(key)
      key = key.to_sym if key.class == String
      value = KEY_VALUE[key]
      @keyboard[value] == 3
    end

    def get_global_pos
      pos = [0, 0].pack('ll')
      return nil if GetMousePos.call(pos) == 0
      pos.unpack('ll')
    end

    def get_pos
      pos = [0, 0].pack('ll')
      return nil if GetMousePos.call(pos) == 0
      return nil if Scr2Cli.call(API.get_hwnd, pos) == 0
      return [-1, -1] unless API.get_rect.point_hit(*pos.unpack('ll'))
      pos.unpack('ll')
    end

    def scroll?
      false
    end

    def scroll_value
      0
    end

  end

  init

end

# File lib/rgss/bitmap.rb

class Numeric

  def fpart
    self - self.to_i
  end

  def rfpart
    1 - fpart
  end

end

class Bitmap

  def cut_bitmap(width_count, height_count)
    return [] if height_count == 0 && width_count == 0
    return cut_row(width_count) if height_count == 0
    return cut_rank(height_count) if width_count == 0
    cut_table(width_count, height_count)
  end

  def cut_bitmap_conf(config)
    bitmaps = []
    config.each do |i|
      bitmap = Bitmap.new(i[2], i[3])
      bitmap.blt(0, 0, self, Rect.new(i[0],i[1], i[2], i[3]))
      bitmaps.push(bitmap)
    end
    bitmaps
  end

  def cut_row(number)
    bitmaps = []
    dw = self.width / number
    number.times do |i|
      dx = dw * i
      bitmap = Bitmap.new(dw, self.height)
      bitmap.blt(0, 0, self, Rect.new(dx, 0, dw, self.height))
      bitmaps.push(bitmap)
    end
    bitmaps
  end

  def cut_rank(number)
    bitmaps = []
    dh = self.height / number
    number.times do |i|
      dx = dh * i
      bitmap = Bitmap.new(self.width, dh)
      bitmap.blt(0, 0, self, Rect.new(0, dx, self.width, dh))
      bitmaps.push(bitmap)
    end
    bitmaps
  end

  def cut_table(width, height)
    bitmaps = []
    w_bitmaps = cut_row(width)
    w_bitmaps.each{ |bitmap| bitmaps += bitmap.cut_rank(height) }
    bitmaps
  end

  def scale9bitmap(a, b, c, d, width, height)
    raise "Error:width too min!(#{width} < #{self.width})" if width < self.width
    raise "Error:height too min!(#{height} < #{self.height})" if height < self.height
    w = self.width - a - b
    h = self.height - c - d
    config = [
        [0, 0, a, c],
        [a, 0, w, c],
        [self.width - b, 0, b, c],
        [0, c, a, h],
        [a, c, w, h],
        [self.width - b, c, b, h],
        [0, self.height - d, a, d],
        [a, self.height - d, w, d],
        [self.width - b, self.height - d, b, d]
    ]
    bitmaps = cut_bitmap_conf(config)
    w_number = (width - a - b) / w
    w_yu = (width - a - b) % w
    h_number = (height - c - d) / h
    h_yu = (height - c - d) % h
    bitmap = Bitmap.new(width, height)
    # center
    w_number.times do |n|
      h_number.times do | i|
        bitmap.blt(a + n * w, c + i * h, bitmaps[4], bitmaps[4].rect)
        bitmap.blt(a + w_number * w, c + i * h, bitmaps[4], Rect.new(0, 0, w_yu, h)) if n == 0
      end
      bitmap.blt(a + n * w, c + h_number * h, bitmaps[4], Rect.new(0, 0, w, h_yu))
    end
    bitmap.blt(a + w_number * w, c + h_number * h, bitmaps[4], Rect.new(0, 0, w_yu, h_yu))
    #w
    w_number.times do |n|
      bitmap.blt(a + n * w, 0, bitmaps[1], bitmaps[1].rect)
      bitmap.blt(a + n * w, height - d, bitmaps[7], bitmaps[7].rect)
    end
    bitmap.blt(a + w_number * w, 0, bitmaps[1], Rect.new(0, 0, w_yu, c))
    bitmap.blt(a + w_number * w, height - d, bitmaps[7], Rect.new(0, 0, w_yu, d))
    #h
    h_number.times do |n|
      bitmap.blt(0, c + n * h, bitmaps[3], bitmaps[3].rect)
      bitmap.blt(width - b, c + n * h, bitmaps[5], bitmaps[5].rect)
    end
    bitmap.blt(0, c + h_number * h, bitmaps[3], Rect.new(0, 0, a, h_yu))
    bitmap.blt(width - b, c + h_number * h, bitmaps[5], Rect.new(0, 0, b, h_yu))

    bitmap.blt(0, 0, bitmaps[0], bitmaps[0].rect)
    bitmap.blt(width - b, 0, bitmaps[2], bitmaps[2].rect)
    bitmap.blt(0, height - d, bitmaps[6], bitmaps[6].rect)
    bitmap.blt(width - b, height - d, bitmaps[8], bitmaps[8].rect)
    bitmap
  end

end

# File lib/rgss/color.rb

class Color

  #Common Color 10
  RED = Color.new(255, 0 ,0)
  ORANGE = Color.new(255, 165, 0)
  YELLOW = Color.new(255, 255, 0)
  GREEN = Color.new(0, 255, 0)
  CHING = Color.new(0, 255, 255)
  BLUE = Color.new(0, 0, 255)
  PURPLE = Color.new(139, 0, 255)
  BLACK = Color.new(0, 0, 0)
  WHITE = Color.new(255 ,255, 255)
  GREY = Color.new(100,100,100)

  #24 Color Ring
  CR1 = Color.new(230, 3, 18)
  CR2 = Color.new(233, 65, 3)
  CR3 = Color.new(240, 126, 15)
  CR4 = Color.new(240, 186, 26)
  CR5 = Color.new(234, 246, 42)
  CR6 = Color.new(183, 241, 19)
  CR7 = Color.new(122, 237, 0)
  CR8 = Color.new(62, 234, 2)
  CR9 = Color.new(50, 198, 18)
  CR10 = Color.new(51, 202, 73)
  CR11 = Color.new(56, 203, 135)
  CR12 = Color.new(60, 194, 197)
  CR13 = Color.new(65, 190, 255)
  CR14 = Color.new(46, 153, 255)
  CR15 = Color.new(31, 107, 242)
  CR16 = Color.new(10, 53, 231)
  CR17 = Color.new(0, 4, 191)
  CR18 = Color.new(56, 0, 223)
  CR19 = Color.new(111, 0, 223)
  CR20 = Color.new(190, 4, 220)
  CR21 = Color.new(227, 7, 213)
  CR22 = Color.new(226, 7, 169)
  CR23 = Color.new(227, 3, 115)
  CR24 = Color.new(227, 2, 58)

  #32 Gray Level
  GL1 = Color.new(0, 0, 0)
  GL2 = Color.new(8, 8, 8)
  GL3 = Color.new(16, 16, 16)
  GL4 = Color.new(24, 24, 24)
  GL5 = Color.new(32, 32, 32)
  GL6 = Color.new(40, 40, 40)
  GL7 = Color.new(48, 48, 48)
  GL8 = Color.new(56, 56, 56)
  GL9 = Color.new(64, 64, 64)
  GL10 = Color.new(72, 72, 72)
  GL11 = Color.new(80, 80, 80)
  GL12 = Color.new(88, 88, 88)
  GL13 = Color.new(96, 96, 96)
  GL14 = Color.new(104, 104, 104)
  GL15 = Color.new(112, 112, 112)
  GL16 = Color.new(120, 120, 120)
  GL17 = Color.new(128, 128, 128)
  GL18 = Color.new(136, 136, 136)
  GL19 = Color.new(144, 144, 144)
  GL20 = Color.new(152, 152, 152)
  GL21 = Color.new(160, 160, 160)
  GL22 = Color.new(168, 168, 168)
  GL23 = Color.new(176, 176, 176)
  GL24 = Color.new(184, 184, 184)
  GL25 = Color.new(192, 192, 192)
  GL26 = Color.new(200, 200, 200)
  GL27 = Color.new(208, 208, 208)
  GL28 = Color.new(216, 216, 216)
  GL29 = Color.new(224, 224, 224)
  GL30 = Color.new(232, 232, 232)
  GL31 = Color.new(240, 240, 240)
  GL32 = Color.new(248, 248, 248)

  def self.str2color(str)
    regexp = /rgba\(( *[0-9]|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]),( *[0-9]|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]),( *[0-9]|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5]),( *[0-9]|[0-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\)/
    raise "Error:Color string error(#{str})." if str[regexp]
    Color.new($1.to_i, $2.to_i, $3.to_i, $4.to_i)
  end

  def self.hex2color(hex)
    regexp = /#([0-9a-f]|[0-9a-f][0-9a-f])([0-9a-f]|[0-9a-f][0-9a-f])([0-9a-f]|[0-9a-f][0-9a-f])/
    raise "Error:Color hex string error(#{hex})." if hex[regexp]
    Color.new($1.to_i(16), $2.to_i(16), $3.to_i(16))
  end

  def inverse
    Color.new(255 - self.red, 255 - self.green, 255 - self.blue, self.alpha)
  end

  def to_rgba
    "rgba(#{self.red.to_i}, #{self.green.to_i}, #{self.blue.to_i}, #{self.alpha.to_i})"
  end

  def to_hex
    sprintf('#%02x%02x%02x', self.red, self.green, self.blue)
  end

end

# File lib/event/event.rb

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

# File lib/event/event_helper.rb

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
        await { Time.now - @filter_timers[@current_fiber.callback.object_id] > time }
      end

      def count_await(count)
        await { @filter_counters[@current_fiber.callback.object_id] > count }
      end

      def filter(info = nil, &callback)
        Fiber.yield true unless callback[info]
      end

      def time_equal(sym, time)
        if @filter_timers[@current_fiber.callback.object_id]
          value = (Time.now - @filter_timers[@current_fiber.callback.object_id]).send(sym, time)
          @filter_timers[current_fiber.callback.object_id] = nil
          value
        else
          @filter_timers[@current_fiber.callback.object_id] = Time.now
          Fiber.yield true
        end
      end

      def time_max(time)
        time_equal(:>, time)
      end

      def time_min(time)
        time_equal(:<, time)
      end

      def count_equal(sym, count)
        if @filter_counters[@current_fiber.callback.object_id]
          value = @filter_counters[@current_fiber.callback.object_id].send(sym, count)
          @filter_counters[current_fiber.callback.object_id] = nil
          value
        else
          @filter_counters[@current_fiber.callback.object_id] = 1
          Fiber.yield true
        end
      end

      def count_max(count)
        count_equal(:>, count)
      end

      def count_min(count)
        count_equal(:<, count)
      end

    end
  end
end

# File lib/event/event_callback_fiber.rb

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

      # @param [EventManager] helper
      # @param [Symbol] name
      # @param [Callback] callback
      # @param [Hash] info
      def initialize(helper, name, callback, info)
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

# File lib/event/event_manager.rb

module RGUI
  module Event
    class Callback < Proc
      attr_reader :immediately
      def initialize(immediately, &callback)
        super(&callback)
        @immediately = immediately
      end
    end

    # Event manager.
    class EventManager
      class << self
        attr_reader :type_getters
        # @return [RGUI::Component::BaseComponent]
        attr_reader :focus_object

        # @param [Symbol] name  event name.
        # @return [Symbol] event type.
        def get_type(name)
          @type_getters.each do |_, getter|
            if getter[name]
              return getter[name]
            end
          end
          [name, nil]
        end

        def add(type, &type_proc)
          @type_getters[type] = type_proc
        end

        def init
          @focus_object = nil
          @type_getters = {}
          add(:event_system){ |name|  [name, :event_system] if name.to_s =~ /^event_manager_.*/ }
          add(:mouse){ |name| [name, :mouse] if name.to_s =~ /^mouse_.*/ }
          add(:keyboard){ |name| [name, :keypress] if Input::KEY_VALUE.include?(name) }
          add(:keyup){ |name| [$1.to_sym, :keyup] if name.to_s =~ /^keyup_(.*)/ }
          add(:keydown){ |name| [$1.to_sym, :keydown] if name.to_s =~ /^keydown_(.*)/ }
          add(:keypress){ |name| [$1.to_sym, :keypress] if name.to_s =~ /^keypress_(.*)/ }
          add(:click){ |name| [:MOUSE_LB, :keyup] if name == :click }
        end

      end

      include EventHelper

      # @return [RGUI::Component::BaseComponent]
      attr_reader :object
      attr_reader :filter_timers
      attr_reader :filter_counters

      # @param [RGUI::Component::BaseComponent] object
      def initialize(object)
        @object = object
        @events = {}
        @event_callback_fibers = []
        @mouse_focus = false
        @keyboard_events = []
        @mouse_events = []
        @filter_timers = {}
        @filter_counters = {}
      end

      def update_fiber
        return if @event_callback_fibers.length == 0
        @event_callback_fibers.each do
          # @type fiber [EventCallbackFiber]
        |fiber|
          @current_fiber = fiber
          fiber.resume
          @current_fiber = nil
          @event_callback_fibers.delete(fiber) unless fiber.alive?
        end
      end

      def update_mouse
        x, y = Input.get_pos
        collision = @object.collision_box
        if !@mouse_focus && collision.point_hit(x, y)
          trigger(:mouse_in, {:x=>x, :y=>y})
          @mouse_focus = true
        elsif @mouse_focus && !collision.point_hit(x, y)
          trigger(:mouse_out, {:x=>x, :y=>y})
          @mouse_focus = false
        end
        trigger(:mouse_scroll, {:value => Input.scroll_value}) if Input.scroll?
      end

      # @param [Event] event
      def update_keyboard(event)
        return if event.name.to_s.include?('MOUSE') && !@mouse_focus
        case event.type
          when :keydown
            return trigger(event.name) if Input.down?(event.name)
          when :keypress
            return trigger(event.name) if Input.press?(event.name)
          when :keyup
            return trigger(event.name) if Input.up?(event.name)
          else
            raise 'Error:Keyboard event type error!'
        end
      end

      def update
        update_fiber
        if @object.status && @object.visible
          update_mouse
          @mouse_events.each{ |o| update_keyboard(o) } if @mouse_focus
          @keyboard_events.each{ |o| update_keyboard(o) } if @object.focus
        end
      end

      # @param [Symbol] name
      # @param [Hash] info
      def trigger(name, info = {})
        # @type [Event]
        event = @events[name]
        return unless event
        event.each do
          # @type callback [Callback]
        |callback|
          next callback[info] if callback.immediately
          @filter_counters[callback.object_id] += 1 if @filter_counters[name]
          @event_callback_fibers << EventCallbackFiber.new(self, name, callback, info)
        end
      end

      # @param [Regexp] name_regexp
      # @param [Hash] info
      def triggers(name_regexp, info = {})
        @events.each do |name|
          trigger(name, info) if name_regexp.match(name)
        end
      end

      # @param [Symbol|Array<Symbol>] name
      # @param [Boolean] immediately
      # @param [Proc] callback
      def on(name, immediately = false, &callback)
        if name.class == Array
          return name.each{ |str| on(str, false, &callback)  }
        end
        name, type = EventManager.get_type(name)
        @events[name] = Event.new(name, type) unless @events[name]
        @events[name].push(Callback.new(immediately, &callback))
        if [:keydown, :keyup, :keypress].include? type
          if name.to_s.include? 'MOUSE'
            @mouse_events << @events[name] unless  @mouse_events.include? @events[name]
          else
            @keyboard_events << @events[name] unless  @keyboard_events.include? @events[name]
          end
        end
      end

    end

    EventManager.init

  end
end

# File lib/action/action_base.rb

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

# File lib/action/interpolator.rb

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

# File lib/action/action_manager.rb

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
        raise("error action name") unless action_class
        action = action_class.new(param)
        @actions.push(action)
        @object.event_manager.on(:action_end) { action.close }
      end

      def update
        @actions.each do |action|
          action.update(@object)
          @actions.delete unless action.alive?
        end
      end
    end

    ActionManager.init

  end
end

# File lib/action/actions/breath.rb

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
        @sym = :- if @index == @count
        @sym = :+ if @index == 0
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

# File lib/collision/collision_base.rb

module RGUI
  module Collision
    class CollisionBase

      def hit(x, y)

      end

      def update_pos(x, y)

      end

      def update_size(width, height)

      end

    end
  end
end

# File lib/collision/aabb.rb

module RGUI
  module Collision
    class AABB < CollisionBase

      def initialize(x, y, width, height)
        @x = x
        @y = y
        @width = width
        @height = height
      end

      def point_hit(x, y)
        @x < x && x < (@x + @width) && @y < y && y < (@y + @height)
      end

      def update_pos(x, y)
        @x = x
        @y = y
      end

      def update_size(width, height)
        @width = width
        @height = height
      end
    end
  end
end

# File lib/components/base.rb

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

        # click => double click
        @event_manager.on(:click)do
          # @type helper [RGUI::Event::EventManager|RGUI::Event::EventHelper]
        |helper|
          helper.object.get_focus
          RGUI::Event::EventManager.focus_object.lost_focus if RGUI::Event::EventManager.focus_object
          helper.filter{ helper.time_min(0.3) }
          helper.trigger(:double_click)
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
        @event_manager.trigger(:change_size, {:old => old, :new => { :width => self.width, :height => self.height }})
      end
    end
  end
end

# File lib/components/image_box.rb

module RGUI
  module Component

    module ImageBoxType
      Tiling = 0
      Filling = 1
      Responsive = 2
    end

    class ImageBox < BaseComponent

      # ImageBox image
      # @return [Bitmap]
      attr_reader :image
      # Display style
      # @return [Integer]
      attr_reader :type
      # Scroll lateral component values
      # @return [Integer]
      attr_reader :x_wheel
      # Scroll vertical component values
      # @return [Integer]
      attr_reader :y_wheel
      attr_reader :sprite

      def initialize(conf)
        super(conf)
        @image = conf[:image] || Bitmap.new(32, 32).fill_rect(0, 0, 32, 32, Color.new(0, 0, 0, 255))
        @sprite = Sprite.new
        @sprite.x, @sprite.y = @x, @y
        @sprite.z = @z if @z
        @sprite.opacity = @visible ? @opacity : 0
        @type = conf[:type] || 0
        @x_wheel = conf[:x_wheel] || 0
        @y_wheel = conf[:y_wheel] || 0
        def_attrs_writer :image, :type, :x_wheel, :y_wheel
        create
      end

      def def_event_callback
        super
        @event_manager.on(:change_opacity){ |em|
          em.object.sprite.opacity = em.object.opacity
        }
        @event_manager.on([:change_x, :change_y, :change_z, :move, :move_to, :change_width, :change_height, :change_size,
                           :change_image, :change_type, :x_scroll, :y_scroll, :change_x_wheel, :change_wheel]) do
          refresh
        end
      end

      def create
        refresh
        super
      end

      def dispose
        super
        @sprite.dispose
      end

      def refresh
        @sprite.x, @sprite.y = @x, @y
        @sprite.z = @z if @z
        case @type
          when ImageBoxType::Tiling
            @sprite.bitmap = @image
            @sprite.src_rect = Rect.new(@x_wheel, @y_wheel, @width, @height)
          when ImageBoxType::Filling
            @sprite.bitmap = @image
            @sprite.zoom_x = @width.to_f / @image.width
            @sprite.zoom_y = @height.to_f / @image.height
          when ImageBoxType::Responsive
            @sprite.bitmap = @image
            change_size(@image.width, @image.height)
          else
            raise "ImageBox:type error"
        end
      end

      def x_scroll(value)
        return if value == 0 || @type != ImageBoxType::Tiling
        @x_wheel += value if @x_wheel + value > 0 && @x_wheel + value < @image.width - @width
        @event_manager.trigger(:x_scroll)
      end

      def y_scroll(value)
        return if value == 0 || @type != ImageBoxType::Tiling
        @y_wheel += value if @y_wheel + value > 0 && @y_wheel + value < @image.height - @height
        @event_manager.trigger(:y_scroll)
      end

    end
  end
end

# File lib/components/sprite_button.rb

module RGUI
  module Component

    class SpriteButton < BaseComponent

      attr_reader :default_image
      attr_reader :highlight_image
      attr_reader :press_image
      attr_reader :disable_image
      attr_reader :sprite

      def initialize(conf = {})
        super(conf)
        @default_image = conf[:default_image] || conf[:images][0]
        @highlight_image = conf[:highlight_image] || conf[:images][1]
        @press_image = conf[:press_image] || conf[:images][2]
        @disable_image = conf[:disable_image] || conf[:images][3]
        @sprite = Sprite.new
        @sprite.x, @sprite.y = @x, @y
        @sprite.z = @z if @z
        @sprite.opacity = @visible ? @opacity : 0
        def_attrs_writer :default_image, :highlight_image, :press_image, :disable_image
        create
      end


      def create
        super
        @sprite.bitmap = @status ? @default_image : @disable_image
        @width = sprite.bitmap.width
        @height = sprite.bitmap.height
        @collision_box.update_size(@width, @height)
      end

      def dispose
        super
        @sprite.dispose
      end

      def def_event_callback
        super
        @event_manager.on([:change_x, :change_y, :change_z, :move, :move_to, :change_width, :change_height, :change_size]) do |em|
          sprite = em.object.sprite
          sprite.x, sprite.y = em.object.x, em.object.y
          sprite.z = em.object.z if em.object.z
          sprite.zoom_x = em.object.width.to_f / sprite.bitmap.width
          sprite.zoom_y = em.object.height.to_f / sprite.bitmap.height
        end
        @event_manager.on(:mouse_in){ |em| em.object.sprite.bitmap = em.object.highlight_image }
        @event_manager.on([:mouse_out, :keydown_MOUSE_LB]){ |em| em.object.sprite.bitmap = em.object.default_image }
        @event_manager.on(:keydown_MOUSE_LB){ |em| em.object.sprite.bitmap = em.object.press_image }
        @event_manager.on([:change_status, :enable, :disable]){ |em|
          em.object.sprite.bitmap = em.object.status ? em.object.default_image : em.object.disable_image
        }
      end
    end
  end
end

# File lib/components/label.rb

module RGUI
  module Component
    class Label < BaseComponent
      attr_reader :text
      attr_reader :size
      attr_reader :color
      attr_reader :sprite
      attr_reader :align

      def initialize(conf = {})
        super(conf)
        @text = conf[:text] || ''
        @size = conf[:size] || 16
        @color = conf[:color] || Color::WHITE
        @align = conf[:align] || 1
        @sprite = Sprite.new
        @sprite.x, @sprite.y = @x, @y
        @sprite.z = @z if @z
        @sprite.bitmap = Bitmap.new(@width, @height)
        @sprite.opacity = @visible ? @opacity : 0
        def_attrs_writer :text, :size, :color
        create
      end

      def create
        refresh
        super
      end

      def dispose
        super
        @sprite.dispose
      end

      def refresh
        @sprite.bitmap.font.size = @size
        @sprite.bitmap.font.color = @color
        rect = Rect.new(0, 0, @width, @height)
        @sprite.bitmap.draw_text(rect, @text, @align)
      end

      def def_event_callback
        super
        @event_manager.on([:change_x, :change_y, :change_z, :move, :move_to, :change_width, :change_height, :change_size]) do |em|
          sprite = em.object.sprite
          sprite.x, sprite.y = em.object.x, em.object.y
          sprite.z = em.object.z if em.object.z
          sprite.zoom_x = em.object.width.to_f / sprite.bitmap.width
          sprite.zoom_y = em.object.height.to_f / sprite.bitmap.height
        end

        @event_manager.on([:change_text, :change_size, :change_color, :change_align]) do |em|
          em.object.refresh
        end

      end

    end
  end
end

# File lib/resource.rb

module RGUI::Resource

  RESOURCES = {
    btn_audio: '.ogg|T2dnUwACAAAAAAAAAACqfwAAAAAAAIQD5h0BHgF2b3JiaXMAAAAAAkSsAAAA|AAAAAPoAAAAAAAC4AU9nZ1MAAAAAAAAAAAAAqn8AAAEAAACvUtqpEC3/////|/////////////8EDdm9yYmlzHQAAAFhpcGguT3JnIGxpYlZvcmJpcyBJIDIw|MDUwMzA0AAAAAAEFdm9yYmlzIUJDVgEAAAEAGGNUKUaZUtJKiRlzlDFGmWKS|SomlhBZCSJ1zFFOpOdeca6y5tSCEEBpTUCkFmVKOUmkZY5ApBZlSEEtJJXQS|OiedYxBbScHWmGuLQbYchA2aUkwpxJRSikIIGVOMKcWUUkpCByV0DjrmHFOO|SihBuJxzq7WWlmOLqXSSSuckZExCSCmFkkoHpVNOQkg1ltZSKR1zUlJqQegg|hBBCtiCEDYLQkFUAAAEAwEAQGrIKAFAAABCKoRiKAoSGrAIAMgAABKAojuIo|jiM5kmNJFhAasgoAAAIAEAAAwHAUSZEUybEkS9IsS9NEUVV91TZVVfZ1Xdd1|Xdd1IDRkFQAAAQBASKeZpRogwgxkGAgNWQUAIAAAAEYowhADQkNWAQAAAQAA|Yig5iCa05nxzjoNmOWgqxeZ0cCLV5kluKubmnHPOOSebc8Y455xzinJmMWgm|tOaccxKDZiloJrTmnHOexOZBa6q05pxzxjmng3FGGOecc5q05kFqNtbmnHMW|tKY5ai7F5pxzIuXmSW0u1eacc84555xzzjnnnHOqF6dzcE4455xzovbmWm5C|F+eccz4Zp3tzQjjnnHPOOeecc84555xzgtCQVQAAEAAAQRg2hnGnIEifo4EY|RYhpyKQH3aPDJGgMcgqpR6OjkVLqIJRUxkkpnSA0ZBUAAAgAACGEFFJIIYUU|UkghhRRSiCGGGGLIKaecggoqqaSiijLKLLPMMssss8wy67CzzjrsMMQQQwyt|tBJLTbXVWGOtueecaw7SWmmttdZKKaWUUkopCA1ZBQCAAAAQCBlkkEFGIYUU|UoghppxyyimooAJCQ1YBAIAAAAIAAAA8yXNER3RER3RER3RER3REx3M8R5RE|SZRESbRMy9RMTxVV1ZVdW9Zl3fZtYRd23fd13/d149eFYVmWZVmWZVmWZVmW|ZVmWZVmC0JBVAAAIAACAEEIIIYUUUkghpRhjzDHnoJNQQiA0ZBUAAAgAIAAA|AMBRHMVxJEdyJMmSLEmTNEuzPM3TPE30RFEUTdNURVd0Rd20RdmUTdd0Tdl0|VVm1XVm2bdnWbV+Wbd/3fd/3fd/3fd/3fd/3dR0IDVkFAEgAAOhIjqRIiqRI|juM4kiQBoSGrAAAZAAABACiKoziO40iSJEmWpEme5VmiZmqmZ3qqqAKhIasA|AEAAAAEAAAAAACia4imm4imi4jmiI0qiZVqipmquKJuy67qu67qu67qu67qu|67qu67qu67qu67qu67qu67qu67qu67ouEBqyCgCQAADQkRzJkRxJkRRJkRzJ|AUJDVgEAMgAAAgBwDMeQFMmxLEvTPM3TPE30RE/0TE8VXdEFQkNWAQCAAAAC|AAAAAAAwJMNSLEdzNEmUVEu1VE21VEsVVU9VVVVVVVVVVVVVVVVVVVVVVVVV|VVVVVVVVVVVVVVVVVVU1TdM0TSA0ZCUAEAUAADpLLdbaK4CUglaDaBBkEHPv|kFNOYhCiYsxBzEF1EEJpvcfMMQat5lgxhJjEWDOHFIPSAqEhKwSA0AwAgyQB|kqYBkqYBAAAAAAAAgORpgCaKgCaKAAAAAAAAACBpGqCJIqCJIgAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAkqYBnikCmigCAAAAAAAAgCaKgGiqgKiaAAAAAAAA|AKCJIiCqIiCaKgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAkqYBmigCnigCAAAA|AAAAgCaKgKiagCiqAAAAAAAAAKCJJiCaKiCqJgAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAgAAAgAAHAIAAC6HQkBUBQJwAgMFxLAsAABxJ0iwAAHAk|S9MAAMDSNFEEAABL00QRAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA|AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAMCAAwBAgAll|oNCQlQBAFACAQTE8DWBZAMsCaBpA0wCeB/A8gCgCAAEAAAUOAAABNmhKLA5Q|aMhKACAKAMCgKJZlWZ4HTdM0UYSmaZooQtM0TxShaZomihBFzzNNeKLnmSZM|UxRNE4iiaQoAAChwAAAIsEFTYnGAQkNWAgAhAQAGR7EsT/M8zxNF01RVaJrn|iaIoiqZpqio0zfNEURRN0zRVFZrmeaIoiqapqqoKTfM8URRF01RVVYXniaIo|mqZpqqrrwvNEURRN0zRV1XUhiqJomqapqqrrukAUTdM0VVVVXReIommapqq6|riwDUTRN01RV15VlYJqqqqqq67qyDFBNVVVV15VlgKq6quu6riwDVFV1XdeV|ZRnguq7ryrJs2wBc13Vl2bYFAAAcOAAABBhBJxlVFmGjCRcegEJDVgQAUQAA|gDFMKaaUYUxCKCE0ikkIKYRMSkqplVRBSCWlUioIqaRUSkalpZRSyiCUUlIq|FYRUSiqlAACwAwcAsAMLodCQlQBAHgAAQYhSjDHGnJRSKcacc05KqRRjzjkn|pWSMMeeck1IyxphzzkkpHXPOOeeklIw555xzUkrnnHPOOSmllM4555yUUkoI|nXNOSimlc845JwAAqMABACDARpHNCUaCCg1ZCQCkAgAYHMeyNE3TPE8UNUnS|NM/zPFE0TU2yNM3zPE8UTZPneZ4oiqJpqirP8zxRFEXTVFWuK4qmaZqqqqpk|WRRF0TRVVXVhmqapqqrqujBNUVRV1XVdyLJpqqrryjJs2zRV1XVlGaiqqsqu|LAPXVVXXlWUBAOAJDgBABTasjnBSNBZYaMhKACADAIAgBCGlFEJKKYSUUggp|pRASAAAw4AAAEGBCGSg0ZEUAECcAACAkpYJOSiWhlFJKKaWUUkoppZRSSiml|lFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSiml|lFJKKaWUUkoppZNSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSiml|lFJKKaWUUkoppZSSUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkkp|pZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkop|pZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkop|pZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkop|pZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkop|pZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkoppZRSSimllFJKKaWUUkop|pZRSSimllAoA0I1wANB9MKEMFBqyEgBIBQAAjFGKMQipxVYhxJhzElprrUKI|MecktJRiz5hzEEppLbaeMccglJJai72UzklJrbUYeyodo5JSSzH23kspJaXY|Yuy9p5BCji3G2HvPMaUWW6ux915jSrHVGGPvvfcYY6ux1t577zG2VmuOBQBg|NjgAQCTYsDrCSdFYYKEhKwGAkAAAwhilGGPMOeecc05KyRhzzkEIIYQQSikZ|Y8w5CCGEEEIpJWPOOQchhFBCKKVkzDnoIIRQQiillM45Bx2EEEIJpZSSMecg|hBBCCaWUUjrnIIQQQiilhFRKKZ2DEEIoIYRSSkkphBBCCKGEUFIpKYUQQggh|hFBCSiWlEEIIIYQQSkilpJRSCCGEEEIIpZSUUgollBBCKKGkkkoppYQQSgih|pFRSKqmUEkIIJYSSSkoplVRKKCGEUgAAwIEDAECAEXSSUWURNppw4QEoNGQl|ABAFAAAZBx2UlhuAkHLUWocchBRbC5FDDFqMnXKMQUopZJAxxqSVkkLHGKTU|YkuhgxR7z7mV1AIAACAIAAgwAQQGCAq+EAJiDABAECIzREJhFSwwKIMGh3kA|8AARIREAJCYo0i4uoMsAF3Rx14EQghCEIBYHUEACDk644Yk3POEGJ+gUlToQ|AAAAAIAFAHgAAEAogIiIZq7C4gIjQ2ODo8PjA0QAAAAAALAA4AMAAAkBIiKa|uQqLC4wMjQ2ODo8PkAAAQAABAAAAABBAAAICAgAAAAAAAQAAAAICT2dnUwAE|kxgAAAAAAACqfwAAAgAAAEi3B20IGU9YQ1BNJiGE6+UPv+F6+fGnUW/MMgAA|AAgAgK0oOwYDWrrec3dps4mE7nlwonS9527SZhMJ3fPGCR/6vu/7vu/7aSMI|AAAAICEAAAAAAAAAFEaSwiCMxGPxWDQSjYSRUBASiSfF4pG38xhjDIgkBf6Z|nuBTBAdZtf9u7p0S3Rg+0xN8iuAgq/bfzb1TohuDVbA9LAkAACZCRERCAABg|kwiciBjJAIZhng1p0kJ0NCxMGecmABBvBZEaVahEqKimQkRk0kKBRQG+WV72|h7//bYX/h+cWGjbLy/7w978t8//wPEIDtLE9rAAAAAAAAIAAIAAAAACgMBYj|ERgAbSmNRqMLA2ZmEwBo45MDnsj97yh+h2nKydhzBRK5/x3F7zClnIg9VwAF|QPZERIiIRAgAOTick9sGAEiUJd+94SkZotenxBzOt7piXSXGDynBSJJrgApV|AqlCTRiQLACeyP33KH6BduX+wxYxJHL/PYpfIF05P9giBmAFEHxMRIREhAAA|ACCbCTkJAMhMFy6dWmlIQaDtwDjWwHEhOvi6YMJVgYCCYYG6ECCwAJ7I/e8s|X7oADpDI/e8sX7oADgAAIIAEkAgAAAAAAAAQgVSBKiEAnsj97yxfugBuIJH7|31m+dAHcAAAAAAAAAAAAAAAAAAAA|' ,

  }

  TEMP_PATH = '.temp'

  class << self
    def init
      make_temp
      ObjectSpace.define_finalizer("clear_temp",  proc { RGUI::Resource.clear_temp })
    end

    # @param [String] src
    def pack_base64(src)
      str = [open(src, 'rb').read].pack('m')
      open(src + '.base64', 'wb'){ |f| f.write "#{File.extname(src)}|" + str.gsub("\n", '|') }
    end

    def make_temp
      Dir.mkdir TEMP_PATH unless Dir.exist? TEMP_PATH
    end

    def make_temp_file(name, content)
      open(name, 'wb') { |f| f.write content }
    end

    def delete_directory(path)
      if File.directory?(path)
        Dir.foreach(path) do |subFile|
          if subFile != '.' and subFile != '..'
            delete_directory(File.join(path, subFile));
          end
        end
        Dir.rmdir(path)
      else
        File.delete(path)
      end
    end

    def clear_temp
      delete_directory(TEMP_PATH) if Dir.exist? TEMP_PATH
    end

    def get(name)
      raise "ResourceError: undefined resource #{name} for Resource" unless RESOURCES[name]
      str =  RESOURCES[name].split('|')
      name = File.join(TEMP_PATH, [name, str.shift].join)
      content = str.concat(['']).join("\n").unpack('m')[0]
      make_temp_file(name, content)
      name
    end
  end

end

RGUI::Resource.init

# File lib/version.rb

module RGUI
  VERSION = '0.1.0'
end