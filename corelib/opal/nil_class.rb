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
    `$opal.hash()`
  end

  def to_i
    0
  end

  alias to_f to_i

  def to_n
    `null`
  end

  def to_s
    ''
  end

  def object_id
    `#{NilClass}._id || (#{NilClass}._id = $opal.uid())`
  end
  alias hash object_id
end
