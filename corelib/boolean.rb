class Boolean
  def &(other)
    `self.valueOf() ? (other !== false && other !== nil) : false`
  end

  def |(other)
    `self.valueOf() ? true : (other !== false && other !== nil)`
  end

  def ^(other)
    `self.valueOf() ? (other === false || other === nil) : (other !== false && other !== nil)`
  end

  def ==(other)
    `self.valueOf() === other.valueOf()`
  end

  def class
    `self.valueOf() ? RubyTrueClass : RubyFalseClass`
  end

  def to_s
    `self.valueOf() ? 'true' : 'false'`
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

TRUE = true
FALSE = false
