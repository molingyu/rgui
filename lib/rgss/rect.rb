# encoding:utf-8

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