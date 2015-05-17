class Bignum #< Integer
  include Comparable
  
  def +(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other
  end

  def -(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other
  end

  def coerce(other)
    [self, other]
  end

  def ==(other)
    false
  end

  def to_f
    1
  end

#  %x{
#  self.valueOf = function() {
#  1234
#  }
#  }
  
end
