class NilClass
  def !
    true
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
    `Opal.hash()`
  end

  def to_i
    0
  end

  alias to_f to_i

  def to_s
    ''
  end

  def object_id
    `#{NilClass}.$$id || (#{NilClass}.$$id = Opal.uid())`
  end

  def hash
    __id__
  end
end

NIL = nil
