require 'corelib/jsbn.js'
require 'corelib/comparable'

class Bignum #< Integer
  include Comparable

  MININTEGER = -9007199254740992
  MAXINTEGER = 9007199254740992 

  attr_accessor :value

  private :value

  private_class_method :new

  #def initialize(value, base = 10)
    #@value = ``
  #end
  #
  def initialize
    nil
  end
  
  def +(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    if other.kind_of?(Bignum)
      other = other.value
    else
      other = `new forge.jsbn.BigInteger(#{other.to_s}, 10)` if other.kind_of?(Numeric)
    end
    bignum `#{value}.add(#{other})`
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
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    if other.kind_of?(Bignum)
      other = other.value
    else
      other = `new forge.jsbn.BigInteger(#{other.to_s}, 10)` if other.kind_of?(Numeric)
    end
    bignum `#{value}.subtract(#{other})`
  end

  def -@
    bignum `#{value}.negate()`
  end

  def get_js_impl(other)
    if other.kind_of?(Bignum)
      other = other.value
    else
      other = `new forge.jsbn.BigInteger(#{other.to_s}, 10)` if other.kind_of?(Numeric)
    end
    other
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
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    if other.kind_of?(Bignum)
      other = other.value
    else
      other = `new forge.jsbn.BigInteger(#{other.to_s}, 10)` if other.kind_of?(Numeric)
    end
    `#{value}.compareTo(#{other})` == 0
  end

  def <(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = get_js_impl(other)
    `#{value}.compareTo(#{other})` <= -1 
  end

  def >(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = get_js_impl(other)
    `#{value}.compareTo(#{other})` == 1 
  end

  def <=(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = get_js_impl(other)
    `#{value}.compareTo(#{other})` <= 0 
  end

  def >=(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = get_js_impl(other)
    `#{value}.compareTo(#{other})` >= 0 
  end

  def to_f
    1
  end


  def inspect
    to_s
  end

  def to_s
    `#{value}.toString()`
  end

  
end
