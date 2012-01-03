class NilClass
  def &(other)
    false
  end

  def |(other)
    `other !== false && other !== nil`
  end

  def ^(other)
    `other !== false && other !== nil`
  end

  def ==(other)
    `this === other`
  end

  def inspect
    'nil'
  end

  def nil?
    true
  end

  def to_a
    []
  end

  def to_i
    0
  end

  def to_f
    0.0
  end

  def to_native
    `var result; return result;`
  end

  def to_s
    ''
  end
end

NIL = nil
