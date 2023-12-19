struct Point(T)
  macro [](x, y)
    Point(typeof({{x}})).new({{x}},{{y}})
  end

  property x : T
  property y : T

  def initialize(@x, @y)
  end

  def ==(other)
    @x == other.x && @y == other.y
  end

  {% for op in %w[* / // + - % **] %}
    def {{ op.id }}(other)
      Point[@x {{op.id}} other.x, @y {{op.id}} other.y]
    end
  {% end %}

  def dist(other)
    (other.x - @x).abs + (other.y - @y).abs
  end

  def max
    {@x, @y}.max
  end
end
