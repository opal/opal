class Boolean < `Boolean`
  %x{
    def._isBoolean = true;
  }

  def &(other)
    `(this == true) ? (other !== false && other !== nil) : false`
  end

  def |(other)
    `(this == true) ? true : (other !== false && other !== nil)`
  end

  def ^(other)
    `(this == true) ? (other === false || other === nil) : (other !== false && other !== nil)`
  end

  def ==(other)
    `(this == true) === other.valueOf()`
  end

  def class
    `(this == true) ? #{TrueClass} : #{FalseClass}`
  end

  alias singleton_class class

  def to_json
    `this.valueOf() ? 'true' : 'false'`
  end

  def to_s
    `(this == true) ? 'true' : 'false'`
  end
end

TRUE  = true
FALSE = false