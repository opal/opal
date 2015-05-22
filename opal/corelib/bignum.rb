require 'corelib/jsbn.js'
require 'corelib/numeric'
require 'corelib/comparable'

class Bignum 

  def is_a?(klass)
    return true if klass == Bignum 
    return true if klass == Integer 
    return true if klass == Numeric 
    false
  end
  alias kind_of? is_a?

  def self.===(other)
    true
  end

  include Comparable

  MININTEGER = -9007199254740992
  MAXINTEGER = 9007199254740992 

  attr_accessor :value

  private :value

  def +(other)
    raise TypeError, "#{other.class} can't be coerced into Bignum" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = wrapped_value_of(other)
    bignum `#{value}.add(#{other})`
  end

  def wrapped_value_of(other)
    if other.kind_of?(Bignum)
      other = other.value
    else
      other = `new forge.jsbn.BigInteger(#{other.to_s}, 10)` if other.kind_of?(Numeric)
    end
    other
  end

  def abs
    bignum `#{value}.abs()`
  end

  def bignum(value)
    bignum = Bignum.new
    bignum.value = value
    bignum
  end

  def -(other)
    raise TypeError, "#{other.class} can't be coerced into Bignum" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = wrapped_value_of(other)
    bignum `#{value}.subtract(#{other})`
  end

  def **(other)
    raise TypeError, "#{other.class} can't be coerced into Bignum" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = wrapped_value_of(other)
    bignum `#{value}.pow(#{other})`
  end

def -@
  bignum `#{value}.negate()`
end

def coerce(other)
  other = `new forge.jsbn.BigInteger(#{other.to_s}, 10)` if other.kind_of?(Numeric)
  [bignum(other), self]
end

def eql?(other)
  return false unless other.kind_of?(Bignum)
  self == other
end

def ==(other)
  raise TypeError, "#{other.class} can't be coerced into Bignum" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
  other = wrapped_value_of(other)
  `#{value}.compareTo(#{other})` == 0
end

def <(other)
  raise TypeError, "#{other.class} can't be coerced into Bignum" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
  other = wrapped_value_of(other)
  `#{value}.compareTo(#{other})` <= -1 
end

def >(other)
  raise TypeError, "#{other.class} can't be coerced into Bignum" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
  other = wrapped_value_of(other)
  `#{value}.compareTo(#{other})` == 1 
end

def <=(other)
  raise TypeError, "#{other.class} can't be coerced into Bignum" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
  other = wrapped_value_of(other)
  `#{value}.compareTo(#{other})` <= 0 
end

def >=(other)
  raise TypeError, "#{other.class} can't be coerced into Bignum" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
  other = wrapped_value_of(other)
  `#{value}.compareTo(#{other})` >= 0 
end



def inspect
  to_s
end

def to_s
  `#{value}.toString()`
end

def to_f
  self.to_s.to_f
end

def self.===(other)
  %x{
      if (!other.$$is_number) {
        return false;
      }

      return (other % 1) === 0;
  }
end

end
