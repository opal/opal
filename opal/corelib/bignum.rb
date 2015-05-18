require 'corelib/biginteger.js'
require 'corelib/comparable'

class Bignum #< Integer
  include Comparable

  attr_reader :value

  private :value

  def initialize(value, base = 10)
    @value = `BigInteger.parse(#{value}, #{base})`
  end
  
  def +(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = other.value if other.kind_of?(Bignum)
    Bignum.new `#{value}.add(#{other})`
  end

  def -(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = other.value if other.kind_of?(Bignum)
    Bignum.new `#{value}.subtract(#{other})`
  end

  def -@
    Bignum.new `#{value}.negate()`
  end

  def coerce(other)
    [self, other]
  end

  def eql?(other)
    return false unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    self == other
  end

  def ==(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = other.value if other.kind_of?(Bignum)
    `#{value}.compare(#{other})` == 0
  end

  def to_f
    1
  end


  def inspect
    `#{value}.toString()`
  end


  
end
