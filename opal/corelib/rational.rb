require 'corelib/numeric'

class Rational < Numeric
  attr_reader :numerator, :denominator

  def initialize(numerator, denominator = 1)
    @numerator   = numerator
    @denominator = denominator
  end

  def ==(other)
    case other
    when Rational
      @numerator == other.numerator && @denominator == other.denominator

    when Integer
      @numerator == other && @denominator == 1

    when Float
      to_f == other

    else
      other == self
    end
  end

  def +(other)
    case other
    when Rational
      num = @numerator * other.denominator + @denominator * other.numerator
      den = @denominator * other.denominator

      Rational(num, den)

    when Integer
      Rational(@numerator + other * @denominator, @denominator)

    when Float
      to_f + other

    else
      a, b = other.coerce(self)
      a + b
    end
  end

  def -(other)
    case other
    when Rational
      num = @numerator * other.denominator - @denominator * other.numerator
      den = @denominator * other.denominator

      Rational(num, den)

    when Integer
      Rational(@numerator - other * @denominator, @denominator)

    when Float
      to_f - other

    else
      a, b = other.coerce(self)
      a - b
    end
  end

  def *(other)
    case other
    when Rational
      num = @numerator * other.numerator
      den = @denominator * other.denominator

      Rational(num, den)
    when Integer
      Rational(@numerator * other, @denominator)

    when Float
      to_f * other

    else
      a, b = other.coerce(self)
      a * b
    end
  end

  def /(other)
    case other
    when Rational
      num = @numerator * other.denominator
      den = @denominator * other.numerator

      Rational(num, den)

    when Integer
      raise ZeroDivisionError, "divided by 0" if other == 0

      Rational(@numerator, @denominator * other)

    when Float
      to_f / other

    else
      a, b = other.coerce(self)
      a / b
    end
  end

  def **(other)
    raise NotImplementedError
  end

  def abs
    if @numerator < 0
      Rational.new(-@numerator, @denominator)
    else
      self
    end
  end

  def ceil(precision = 0)
    if precision == 0
      to_f.ceil
    else
      raise NotImplementedError
    end
  end

  def coerce(other)
    case other
    when Integer
      [Rational.new(other, 1), self]

    when Float
      [other, to_f]

    else
      super
    end
  end

  alias divide /

  def floor(precision = 0)
    if precision == 0
      to_f.floor
    else
      raise NotImplementedError
    end
  end

  def inspect
    "(#{to_s})"
  end

  alias quo /

  def rationalize(eps = undefined)
    raise NotImplementedError
  end

  def round(precision = 0)
    return 0 if @numerator == 0

    if precision == 0
      return @numerator if @denominator == 1

      to_f.round
    else
      raise NotImplementedError
    end
  end

  def to_f
    @numerator / @denominator
  end

  def to_i
    truncate
  end

  def to_r
    self
  end

  def to_s
    "#@numerator/#@denominator"
  end

  def truncate(precision = 0)
    if precision == 0
      @numerator < 0 ? ceil : floor
    else
      raise NotImplementedError
    end
  end
end

module Kernel
  def Rational(numerator, denominator = nil)
    if denominator
      Rational.new(numerator, denominator)
    elsif Integer === numerator
      Rational.new(numerator, 1)
    else
      raise NotImplementedError
    end
  end
end
