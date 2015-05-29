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

  attr_accessor :value

  private :value


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

  def binary_operation(method_sign, jsmethod, other)
    raise TypeError, "#{other.class} can't be coerced into Bignum" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
    if other % 1 != 0
      return self.to_f.send method_sign, other
    end
    other = wrapped_value_of(other)
    bignum `#{value}[#{jsmethod}](#{other})`
  end

  def -(other)
    binary_operation :-, 'subtract', other
  end

  def +(other)
    binary_operation :+, 'add', other
  end


  def *(other)
    binary_operation :*, 'multiply', other
  end

  def **(other)
    binary_operation :**, 'pow', other
  end

  def %(other)
    binary_operation :%, 'mod', other
  end

  def &(other)
    raise TypeError, "#{other.class} can't be coerced into Bignum" if is_float(other)
    binary_operation :%, 'and', other
  end

  def -@
    bignum `#{value}.negate()`
  end

  def is_float(other)
    return other % 1 != 0 if other.kind_of? Numeric
    return false
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
    check_class_is_compareable other
    other = wrapped_value_of(other)
    `#{value}.compareTo(#{other})` <= -1 
  end

  def >(other)
    check_class_is_compareable other
    other = wrapped_value_of(other)
    `#{value}.compareTo(#{other})` >= 1 
  end

  def <=(other)
    check_class_is_compareable other
    other = wrapped_value_of(other)
    `#{value}.compareTo(#{other})` <= 0 
  end

  def >=(other)
    check_class_is_compareable other
    other = wrapped_value_of(other)
    `#{value}.compareTo(#{other})` >= 0 
  end

  def check_class_is_compareable(other)
    raise ArgumentError, "comparison of Bignum with #{other.class} failed" unless other.kind_of?(Numeric) || other.kind_of?(Bignum)
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
