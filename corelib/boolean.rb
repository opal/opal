class Boolean
  def to_s
    `self.valueOf() === true ? 'true' : 'false'`
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
