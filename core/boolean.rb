class Boolean < `Boolean`
  %x{
    def._flags = T_OBJECT | T_BOOLEAN;
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

  def to_s
    `(this == true) ? 'true' : 'false'`
  end
end

class TrueClass
  def self.===(obj)
    `obj === true`
  end
end

class FalseClass
  def self.===(obj)
    `obj === false`
  end
end

TRUE  = true
FALSE = false
