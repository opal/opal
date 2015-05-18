require 'corelib/biginteger.js'
require 'corelib/comparable'

class Bignum #< Integer
  include Comparable

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
    other = other.value if other.kind_of?(Bignum)
    create_new_bignum `#{value}.add(#{other})`
  end

  def -(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = other.value if other.kind_of?(Bignum)
    create_new_bignum `#{value}.subtract(#{other})`
  end

  def create_new_bignum(value)
    bignum = Bignum.new
    bignum.value = value
    bignum
  end

  def -@
    create_new_bignum `#{value}.negate()`
  end

  def coerce(other)
    [other, `#{value}.toJSValue()`]
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

  def <(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = other.value if other.kind_of?(Bignum)
    `#{value}.compare(#{other})` == -1 
  end

  def >(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    puts " > #######################"
    puts other.inspect
    puts self.inspect
    puts `#{value}.compare(#{other})` 
    other = other.value if other.kind_of?(Bignum)
    `#{value}.compare(#{other})` == 1 
  end

  def <=(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = other.value if other.kind_of?(Bignum)
    `#{value}.compare(#{other})` <= 0 
  end

  def >=(other)
    raise TypeError, "#{other.class} can't be coerced into Numeric" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    other = other.value if other.kind_of?(Bignum)
    `#{value}.compare(#{other})` >= 0 
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
