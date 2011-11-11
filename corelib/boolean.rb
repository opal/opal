class Boolean
  def to_s
    `self.valueOf() === true ? 'true' : 'false'`
  end

  def class
    `self.valueOf() === true ? #{ TrueClass } : #{ FalseClass }`
  end

  def ==(other)
    `self.valueOf() === other.valueOf()`
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
