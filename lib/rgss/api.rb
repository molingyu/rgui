# encoding:utf-8

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