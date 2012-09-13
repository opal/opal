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
    `other === nil`
  end

  def inspect
    'nil'
  end

  def nil?
    true
  end

  def singleton_class
    NilClass
  end

  def to_a
    []
  end

  def to_i
    0
  end

  alias to_f to_i

  def to_json
    'null'
  end

  def to_native
    `null`
  end

  def to_s
    ''
  end
end

NIL = nil