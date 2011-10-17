class NilClass
  def nil?
    true
  end

  def ==(other)
    # allow nil to be equal to either null or undefined
    `other == null`
  end

  def class
    # FIXME: Special override - as nil is the native "null", it cannot lookup
    # constants (yet), so we hardcode its class.
    ::NilClass
  end

  def & (other)
    false
  end

  def |(other)
    `other !== false && other != nil`
  end

  def ^(other)
    `other !== false && other != nil`
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

  def inspect
    'nil'
  end
end

NIL = nil

