#encoding: utf-8
#author: shitake
#data: 16-4-20

class Game

  attr_accessor :exit,:view, :start_view

  def init(width, height, &block)
    Graphics.resize_screen(width, height)
    Graphics.resize_window(width, height)
    block.call
    init_view
  end

  def get_path(path)
    Dir.glob(path)
  end

  def load_libs
    require_relative './libs/main'
  end

  def load_games

  end

  def load_views
    require_relative 'views/title_view'
  end

  def update
    Graphics.update
    Input.update
    @view.update
  end

  def init_view
    @view = @start_view.new
  end

  def change_view(view)
    @view.dispose if @view
    @view = view.new
  end

  def width
    Graphics.width
  end

  def height
    Graphics.height
  end

  def load_image(filename)
    @cache ||= {}
    if filename.empty?
      empty_bitmap
    else
      ['Data/Graphics/', ''].each do |path|
        return normal_bitmap(path + filename) if File.exist?(path + filename)
      end
      empty_bitmap
    end
  end

  def empty_bitmap
    Bitmap.new(32, 32)
  end

  def normal_bitmap(path)
    @cache[path] = Bitmap.new(path) unless include?(path)
    @cache[path]
  end

  def include?(key)
    @cache[key] && !@cache[key].disposed?
  end

  def clear
    @cache ||= {}
    @cache.clear
    GC.start
  end

  def cut_bitmap(src_bitmap, width, height)
    number = src_bitmap.width / width
    bitmaps = []
    number.times do |i|
      dx = width * i
      bitmap = Bitmap.new(width,height)
      bitmap.blt(0, 0, src_bitmap, Rect.new(dx, 0, width, height))
      bitmaps.push(bitmap)
    end
    bitmaps
  end

end
