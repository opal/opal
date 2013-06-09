class NilClass
  def &(other)
    false
  end

  def |(other)
    `other !== false && other != null`
  end

  def ^(other)
    `other !== false && other != null`
  end

  def ==(other)
    `other == null`
  end

  def as_json
    self
  end

  def dup
    raise TypeError
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

  def to_h
    `__opal.hash()`
  end

  def to_i
    0
  end

  alias to_f to_i

  def to_json
    'null'
  end

  def to_n
    `null`
  end

  def to_s
    ''
  end

  def object_id
    `#{NilClass}._id || (#{NilClass}._id = Opal.uid())`
  end
end
