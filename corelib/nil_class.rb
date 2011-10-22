class NilClass
  def nil?
    true
  end

  def ==(other)
    # allow nil to be equal to either null or undefined
    `other == null`
  end

  def &(other)
    false
  end

  def |(other)
    `other !== false && other != null`
  end

  def ^(other)
    `other !== false && other != null`
  end

  def __id__
    13 # hardcoded, eeek
  end

  def class
    # FIXME: Special override - as nil is the native "null", it cannot lookup
    # constants (yet), so we hardcode its class.
    ::NilClass
  end

  alias_method :hash, :__id__

  def inspect
    'nil'
  end

  alias_method :object_id, :__id__


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
