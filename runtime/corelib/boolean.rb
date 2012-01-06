class Boolean
  def &(other)
    `this.valueOf() ? (other !== false && other !== nil) : false`
  end

  def |(other)
    `this.valueOf() ? true : (other !== false && other !== nil)`
  end

  def ^(other)
    `this.valueOf() ? (other === false || other === nil) : (other !== false && other !== nil)`
  end

  def ==(other)
    `this.valueOf() === other.valueOf()`
  end

  def class
    `this.valueOf() ? #{TrueClass} : #{FalseClass}`
  end

  def to_native
    `this.valueOf()`
  end

  def to_s
    `this.valueOf() ? 'true' : 'false'`
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
