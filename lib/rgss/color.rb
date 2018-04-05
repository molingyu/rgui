# encoding:utf-8

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
