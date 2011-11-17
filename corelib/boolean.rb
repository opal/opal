class Boolean
  def to_s
    `self ? 'true' : 'false'`
  end

  def class
    `self.valueOf() === true ? #{ TrueClass } : #{ FalseClass }`
  end

  def &(other)
    `self ? (other !== false && other !== null) : false`
  end

  def |(other)
    `self ? true : (other !== false && other !== null)`
  end

  def ^(other)
    `self ? (other === false || other === null) : (other !== false && other !== null)`
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
