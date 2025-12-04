class Flags
  attr_accessor :names, :value

  def initialize(names, value = 0)
    @names, @value = names, value
  end

  def mask
    (1 << @names.size) - 1
  end

  def check_name!(name)
    raise ArgumentError.new("#{name} is not a valid flag") unless @names.include?(name)
  end

  def set?(name)
    check_name!(name)
    @value[@names.index(name)] > 0
  end

  def set(name)
    check_name!(name)
    @value |= (1 << @names.index(name))
  end

  def unset(name)
    check_name!(name)
    index = @names.index(name)
    @value &= mask - (1 << index)
  end

  def to_s
    @value.to_s(2)
  end
end
