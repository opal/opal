require 'corelib/bignum/fixnum'
require 'corelib/bignum/bignum_impl.js'
require 'corelib/bignum/string'
require 'corelib/comparable'

class Bignum 
  include Comparable

  def self.create_bignum(other)
    bignum `new BigInteger(#{other.to_s}, 10)`
  end

  def self.numbers_for_radix(radix)
    char = "0"
    numbers = char
    (2..radix).each do 
      char = char.succ
      if char == "10"
        char = "A"
      end
      numbers = "#{numbers},#{char}"
    end
    numbers
  end

  def self.create_from_string(string, radix)
    string = string.upcase
    x = string.match("^([\-|\+]?[#{numbers_for_radix(radix)}]*)")
    value = "0"
    value = x[0] if x && x[0] && x[0] != "" && x[0] != "-" && x[0] != "+"
    bignum `new BigInteger(#{value}, #{radix})`
  end

  def self.bignum(value)
    bignum = Bignum.new
    bignum.value = value
    bignum
  end

  attr_accessor :value
  private :value

  def send_coerce(method, other)
    unless other.kind_of? Numeric
      coerced = other.coerce(self) 
      raise RuntimeError unless coerced.kind_of? Array
      return coerced
    end
    [self, other]
    rescue StandardError
    case type(method)
    when :operation
      raise TypeError, "#{other.class} can't be coerced into Bignum"

    when :comparison
      raise ArgumentError, "comparison of #{self.class} with #{other.class} failed"
    end
  end

  def type(method)
    case method
      when :+, :-, :*, :/, :%, :&, :|, :^, :**, :divmod
        :operation

      when :>, :>=, :<, :<=, :<=>
        :comparison
    end
  end

  def unwrapp_values(method, other)
    this, other = send_coerce(method, other)
    [wrapped_value_of(this), wrapped_value_of(other)]
  end

  def %(other)
    divmod(other)[1]
  end
  alias :modulo :%
  alias :remainder :%

  def +@
    self
  end

  def -@
    bignum `#{value}.negate()`
  end

  def <=>(other)
    return 1 if other == -Float::INFINITY && self < 0
    this, other = unwrapp_values(:<=>, other) 
    calculate_compare_result `#{this}.compareTo(#{other})`
  rescue TypeError, ArgumentError
    nil
  end

  def calculate_compare_result(result)
    return 1 if result > 0
    return -1 if result < 0
    return 0 if result == 0
  end

  def abs
    bignum `#{value}.abs()`
  end
  alias :magnitude :abs

  def -(other)
    binary_operation :-, 'subtract', other
  end

  def +(other)
    binary_operation :+, 'add', other
  end


  def *(other)
    binary_operation :*, 'multiply', other
  end

  def divmod(other)
    this_unwrapped, other_unwrapped = unwrapp_values(:divmod, other)
    is_divisible other
    return calculate_as_float(:divmod, other) if is_float(other)
    x = call_js_method_with_arg this_unwrapped, :divideAndRemainder, other_unwrapped
    [bignum_or_integer(x[0]), bignum_or_integer(x[1])]
  end

  def call_js_method_with_arg(obj, method, arg)
    `#{obj}[#{method}](#{arg})`
  end

  def calculate_as_float(method, other)
    self.to_f.send method, other
  end

  def is_divisible(other)
    raise ZeroDivisionError if other == 0
    raise FloatDomainError if  other.class == Numeric && other.nan?
  end

  def /(other)
    divmod(other)[0]
  end
  alias :div :/


  def fdiv(other)
    this_unwrapped, other_unwrapped = unwrapp_values(:/, other)
    `#{this_unwrapped}.intValue()` / `#{other_unwrapped}.intValue()` 
  end

  def **(other)
    this_unwrapped, other_unwrapped = unwrapp_values(:**, other)
    return calculate_as_float(:**, other) if is_float(other)
    # result cann only be 1 if x^0 or 1^x or -1^x where x is even
    # nevertheless result is 1 number is to big => infinity
    return 1 if `#{wrapped_value_of(self)}.intValue()` == 1 
    return 1 if `#{wrapped_value_of(self)}.intValue()` == -1 && other.even?
    return -1 if `#{wrapped_value_of(self)}.intValue()` == -1 && other.odd?
    return 1 if other == 0
    result = call_js_method_with_arg this_unwrapped, :pow, other_unwrapped
    # return infinity if result is to big
    return `Infinity` if `#{result}.intValue()` == 1
    bignum_or_integer result
  end

  def &(other)
    binary_operation_integer :&, 'and', other
  end

  def |(other)
    binary_operation_integer :|, 'or', other
  end

  def ^(other)
    binary_operation_integer :^, 'xor', other
  end

  def <<(count)
    shift count, 'lShiftTo', 'rShiftTo'
  end

  def >>(count)
    shift count, 'rShiftTo', 'lShiftTo'
  end

  def shift(count, jsmethod, jsmethod_less_zero)
    count = Opal.coerce_to! count, Integer, :to_int

    jsmethod = jsmethod_less_zero if count < 0

    count = count.abs
    newJsBignum = `new BigInteger("0", 10)`
    `#{value}[#{jsmethod}](#{count}, #{newJsBignum})`
    bignum_or_integer newJsBignum
  end
  private :shift

  def bit_length
    `#{value}.bitLength()`
  end

  def ~
    bignum `#{value}.not()`
  end

  def is_a?(klass)
    return true if klass == Bignum 
    return true if klass == Integer 
    return true if klass == Numeric 
    false
  end

  alias kind_of? is_a?

  def is_float(other)
    return other % 1 != 0 if other.kind_of? Numeric
    return false
  end

  def integer?
    return self % 1 == 0
  end

  def coerce(other)
    raise TypeError, "#{other.class} can't be coerced into Bignum" unless other.kind_of?(Numeric) 
    return [other, self.to_s.to_f] unless other.integer?
    other = bignum(`new BigInteger(#{other.to_s}, 10)`)
    [other, self]
  end

  def eql?(other)
    return false unless other.kind_of?(Bignum)
    self == other
  end

  def ==(other)
    return calculate_as_float(:==, other) if other.instance_of? Numeric 
    return reverse_call(:==, other) if other.class != Bignum 
    (self <=> other) == 0
  end

  def reverse_call(method, other)
    return true if other.send(method, self)
    false
  end

  def [](index)
    index = Opal.coerce_to! index, Integer, :to_int
    string = self.to_s(2)
    string[string.length - 1 - index].to_i
  end

  def inspect
    to_s
  end

  def to_s(base=10)
    `#{value}.toString(#{base})`
  end

  def to_i
    self
  end
  alias :to_int :to_i

  def to_f
    self.to_s.to_f
  end

  def succ
    self + 1
  end
  alias :next :succ

  def pred
    self - 1
  end

  def even?
    `#{value}.isEven()`
  end

  def odd?
    !even?
  end
  
  def round(ndigits=0)
    self
  end

  def ceil
    self
  end

  def floor
    self
  end

  def ord
    self
  end

  def ===(other)
    return reverse_call(:==, other) unless other.kind_of? Numeric
    self == other
  end

  def hash
    hash = 0
    self.to_s.each_char do | x |
      hash = ((hash<<5)-hash)+x.ord
      hash = hash & hash
    end
    hash
  end

  def size
    `#{value}.toByteArray()`.size
  end

  private

  def wrapped_value_of(other)
      return other.value if other.kind_of?(Bignum)
      return `new BigInteger(#{other.to_s}, 10)` if other.kind_of?(Numeric)
  end

  def binary_operation_integer(method_sign, jsmethod, other)
    raise TypeError, "#{other.class} can't be coerced into Bignum" if is_float(other)
    binary_operation method_sign, jsmethod, other
  end

  def binary_operation(method_sign, jsmethod, other)
    this_unwrapped, other_unwrapped = unwrapp_values(method_sign, other)
    return calculate_as_float(method_sign, other) if is_float(other)
    bignum_or_integer call_js_method_with_arg(this_unwrapped, jsmethod, other_unwrapped)
  end

  def bignum_or_integer(value)
    big = bignum value
    return big unless Fixnum.fits_in(big)
    `value.intValue()`
  end

  def bignum(value)
    Bignum.bignum value
  end

end

class ZeroDivisionError < StandardError
end

