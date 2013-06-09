class Boolean
  `def._isBoolean = true`

  def &(other)
    `(#{self} == true) ? (other !== false && other != null) : false`
  end

  def |(other)
    `(#{self} == true) ? true : (other !== false && other != null)`
  end

  def ^(other)
    `(#{self} == true) ? (other === false || other == null) : (other !== false && other != null)`
  end

  def ==(other)
    `if (other == null) { return false; }`
    `(#{self} == true) === other.valueOf()`
  end

  def as_json
    self
  end

  alias singleton_class class

  def to_json
    `(#{self} == true) ? 'true' : 'false'`
  end

  def to_s
    `(#{self} == true) ? 'true' : 'false'`
  end

  def to_n
    self
  end
end

TrueClass = Boolean
FalseClass = Boolean
