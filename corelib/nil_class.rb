class NilClass
  def nil?
    true
  end

  def ==(other)
    `other === self`
  end

  def &(other)
    false
  end

  def |(other)
    `other !== false && other !== nil`
  end

  def ^(other)
    `other !== false && other !== nil`
  end

  def inspect
    'nil'
  end

  def to_i
    0
  end

  def to_f
    0.0
  end

  def to_s
    ""
  end

  def to_a
    []
  end
end

NIL = nil
