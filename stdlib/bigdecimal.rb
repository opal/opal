class BigDecimal < Numeric; end

require 'js'
require 'bigdecimal/kernel'
require 'bigdecimal/bignumber.js'

class BigDecimal
  ROUND_MODE = 256

  # NOTE: the numeric values of the ROUND_* constants
  # follow BigNumber.js, they are NOT the same as MRI
  ROUND_UP = 0
  ROUND_DOWN = 1
  ROUND_CEILING = 2
  ROUND_FLOOR = 3
  ROUND_HALF_UP = 4
  ROUND_HALF_DOWN = 5
  ROUND_HALF_EVEN = 6

  SIGN_NaN = 0
  SIGN_POSITIVE_ZERO = 1
  SIGN_NEGATIVE_ZERO = -1
  SIGN_POSITIVE_FINITE = 2
  SIGN_NEGATIVE_FINITE = -2
  SIGN_POSITIVE_INFINITE = 3
  SIGN_NEGATIVE_INFINITE = -3

  def self.limit(digits = nil)
    @digits = digits if digits
    @digits
  end

  def self.mode(mode, value = nil)
    case mode
    when ROUND_MODE
      @round_mode = value if value
      @round_mode || ROUND_HALF_UP
    end
  end

  attr_reader :bignumber

  def initialize(initial, digits = 0)
    @bignumber = JS.new(BigNumber, initial)
  end

  def ==(other)
    case other
    when self.class
      bignumber.JS.equals(other.bignumber)
    when Number
      bignumber.JS.equals(other)
    else
      false
    end
  end

  alias === ==

  def <=>(other)
    case other
    when self.class
      result = bignumber.JS.comparedTo(other.bignumber)
    when Number
      result = bignumber.JS.comparedTo(other)
    else
      result = nil
    end
    `#{result} === null ? nil : #{result}`
  end

  def abs
    self.class.new(bignumber.JS.abs)
  end

  def add(other, digits = 0)
    if digits == nil
      raise TypeError, 'wrong argument type nil (expected Fixnum)'
    end

    if digits < 0
      raise ArgumentError, 'argument must be positive'
    end

    other, _ = coerce(other)

    result = bignumber.JS.plus(other.bignumber)

    if digits > 0
      result = result.JS.toDigits(digits, self.class.mode(ROUND_MODE))
    end

    self.class.new(result)
  end

  alias + add

  def ceil(n = nil)
    unless bignumber.JS.isFinite
      raise FloatDomainError, "Computation results to 'Infinity'"
    end

    if n == nil
      bignumber.JS.round(0, ROUND_CEILING).JS.toNumber
    elsif n >= 0
      self.class.new(bignumber.JS.round(n, ROUND_CEILING))
    else
      self.class.new(bignumber.JS.round(0, ROUND_CEILING))
    end
  end

  def coerce(other)
    case other
    when self.class
      [other, self]
    when Number
      [self.class.new(other), self]
    else
      raise TypeError, "#{other.class} can't be coerced into #{self.class}"
    end
  end

  def div(other, digits = nil)
    return self / other if digits == 0

    other, _ = coerce(other)

    if nan? || other.nan?
      raise FloatDomainError, "Computation results to 'NaN'(Not a Number)"
    end

    if digits == nil
      if other.zero?
        raise ZeroDivisionError, "divided by 0"
      end

      if infinite?
        raise FloatDomainError, "Computation results to 'Infinity'"
      end

      return self.class.new(bignumber.JS.dividedToIntegerBy(other.bignumber))
    end

    self.class.new(bignumber.JS.dividedBy(other.bignumber).JS.round(digits, self.class.mode(ROUND_MODE)))
  end

  def finite?
    bignumber.JS.isFinite
  end

  def infinite?
    return nil if finite? || nan?
    bignumber.JS.isNegative ? -1 : 1
  end

  def minus(other)
    other, _ = coerce(other)
    self.class.new(bignumber.JS.minus(other.bignumber))
  end

  alias - minus

  def mult(other, digits = nil)
    other, _ = coerce(other)

    if digits == nil
      return self.class.new(bignumber.JS.times(other.bignumber))
    end

    self.class.new(bignumber.JS.times(other.bignumber).JS.round(digits, self.class.mode(ROUND_MODE)))
  end

  alias * mult

  def nan?
    bignumber.JS.isNaN
  end

  def quo(other)
    other, _ = coerce(other)
    self.class.new(bignumber.JS.dividedBy(other.bignumber))
  end

  alias / quo

  def sign
    if bignumber.JS.isNaN
      return SIGN_NaN
    end
    if bignumber.JS.isZero
      return bignumber.JS.isNegative ? SIGN_NEGATIVE_ZERO : SIGN_POSITIVE_ZERO
    end
  end

  def sub(other, precision)
    other, _ = coerce(other)
    self.class.new(bignumber.JS.minus(other.bignumber))
  end

  def to_f
    bignumber.JS.toNumber
  end

  def to_s(s = '')
    bignumber.JS.toString
  end

  def zero?
    bignumber.JS.isZero
  end
end
