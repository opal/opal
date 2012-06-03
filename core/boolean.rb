class Boolean < `Boolean`
  %x{
    def._isBoolean = true;
  }

  def &(other)
    `(this == true) ? (other !== false && other != null) : false`
  end

  def |(other)
    `(this == true) ? true : (other !== false && other != null)`
  end

  def ^(other)
    `(this == true) ? (other === false || other == null) : (other !== false && other != null)`
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
