class Grid
  include Enumerable

  def initialize(width, height)
    @width, @height = width, height
    @buffer = Array.new(@width * @height) { yield }
  end

  def in_bounds?(x, y)
    x >= 0 && x < @width && y >= 0 && y < @height
  end

  def [](x, y)
    return nil unless in_bounds?(x, y)
    @buffer[y * @width + x]
  end

  def []=(x, y, value)
    return nil unless in_bounds?(x, y)
    @buffer[y * @width + x] = value
  end

  def each
    0.upto(@height - 1) do |y|
      0.upto(@width - 1) do |x|
        yield x, y
      end
    end
  end
end
