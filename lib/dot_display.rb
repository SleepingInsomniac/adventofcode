class DotDisplay
  MASKS = [
    0b00000001,
    0b00001000,
    0b00000010,
    0b00010000,
    0b00000100,
    0b00100000,
    0b01000000,
    0b10000000,
  ]

  # Given a UInt8 as the bits representing a 2x8 char, return the
  # corresponding braille character.
  def self.braille_char(bits)
    v = 0
    m = 0b10000000
    8.times do |n|
      v |= MASKS[n] unless bits & m == 0
      m >>= 1
    end

    code_point = 0x2800 + v
    code_point.chr(Encoding::UTF_8)
  end

  attr_accessor :width, :height
  attr_reader :bytes

  def initialize(width, height)
    @width = width
    @height = height
    @bytes = Array.new(@width * @height) { 0 }
  end

  def [](x, y)
    raise "out of bounds" if x < 0 || x >= @width || y < 0 || y >= @height

    byte, mask = byte_mask(x, y)
    @bytes[byte] & mask > 0
  end

  def []=(x, y, value)
    raise "out of bounds" if x < 0 || x >= @width || y < 0 || y >= @height

    byte, mask = byte_mask(x, y)

    if value
      @bytes[byte] |= mask
    else
      @bytes[byte] &= ~mask
    end
  end

  def to_s
    w = @width / 2
    h = @height / 4

    Array.new(h) do |y|
      string = +""
      w.times do |x|
        string += self.class.braille_char(@bytes[y * w + x])
      end
      string
    end.join("\n")
  end

  private

  def byte_mask(x, y)
    y1, y2 = y.divmod(4)
    x1, x2 = x.divmod(2)

    byte = y1 * (@width / 2) + x1
    bit = y2 * 2 + x2

    mask = 0b10000000 >> bit
    [byte, mask]
  end
end
