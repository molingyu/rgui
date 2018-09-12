require_relative 'rect'

class Numeric

  def fpart
    self - self.to_i
  end

  def rfpart
    1 - fpart
  end

end

class Bitmap

  alias :rgss_blt :blt

  def blt(x, y, src_bitmap, src_rect = src_bitmap.rect, opacity = 255)
    rgss_blt(x, y, src_bitmap, src_rect, opacity)
  end

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
