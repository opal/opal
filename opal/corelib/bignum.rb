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
    other = get_js_impl(other)
    create_new_bignum `#{value}.add(#{other})`
  end

  def -(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    puts self.inspect
    puts "-"
    puts other.inspect
    other = get_js_impl(other)
    
    puts create_new_bignum(`#{value}.subtract(#{other})`).inspect
    create_new_bignum `#{value}.subtract(#{other})`
  end

  def create_new_bignum(value)

    bignum = Bignum.new
    bignum.value = value
    if bignum >= Bignum::MAXINTEGER || bignum <= Bignum::MININTEGER
      return `value.intValue()`
    end
    bignum
  end

  def create_new_js_biginterger(value)
    `new forge.jsbn.BigInteger(#{value.to_s}, 10)`
  end

  def get_js_impl(number)
    if number.kind_of?(Numeric)
      return create_new_js_biginterger(number)
    end
    number.value 
  end

  def -@
    create_new_bignum `#{value}.negate()`
  end

  def coerce(other)
    [create_new_bignum(create_new_js_biginterger(other)), self]
  end

  def eql?(other)
    return false unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    self == other
  end

  def ==(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = other.value if other.kind_of?(Bignum)
    `#{value}.compareTo(#{other})` == 0
  end

  def <(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = other.value if other.kind_of?(Bignum)
    `#{value}.compareTo(#{other})` <= -1 
  end

  def >(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = other.value if other.kind_of?(Bignum)
    `#{value}.compareTo(#{other})` == 1 
  end

  def <=(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = other.value if other.kind_of?(Bignum)
    `#{value}.compareTo(#{other})` <= 0 
  end

  def >=(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = other.value if other.kind_of?(Bignum)
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
