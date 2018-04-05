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


  def cut_bitmap(width, height, type)
    case type
      when 0
        bitmaps = cut_row(width, height)
      when 1
        bitmaps = cut_rank(width, height)
      when 2
        bitmaps = cut_row_rank(width, height)
      when 3
        bitmaps = cut_rank_row(width, height)
      else
        raise "Error:Bitmap cut type error(#{type})."
    end
    bitmaps
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

  def cut_row(width, height)
    number = self.width / width
    bitmaps = []
    number.times do |i|
      dx = width * i
      bitmap = Bitmap.new(width,height)
      bitmap.blt(0, 0, self, Rect.new(dx, 0, width, height))
      bitmaps.push(bitmap)
    end
    bitmaps
  end

  def cut_rank(width, height)
    number = self.height / height
    bitmaps = []
    number.times do |i|
      dx = height * i
      bitmap = Bitmap.new(width,height)
      bitmap.blt(0, 0, self, Rect.new(0, dx, width, height))
      bitmaps.push(bitmap)
    end
    bitmaps
  end

  def cut_row_rank(width, height)
    bitmaps = []
    w_bitmaps = cut_row(width, self.height)
    w_bitmaps.each{ |bitmap| bitmaps += bitmap.cut_rank(width, height) }
    bitmaps
  end

  def cut_rank_row(width, height)
    bitmaps = []
    h_bitmaps = cut_rank(self.width, height)
    h_bitmaps.each{ |bitmap| bitmaps += bitmap.cut_row(width, height) }
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
