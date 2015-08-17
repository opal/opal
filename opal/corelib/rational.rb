require 'corelib/numeric'

class Rational < Numeric
  def self.reduce(num, den)
    num = num.to_i
    den = den.to_i

    if den == 0
      raise ZeroDivisionError, "divided by 0"
    elsif den < 0
      num = -num
      den = -den
    elsif den == 1
      return num, den
    end

    gcd = num.gcd(den)

    return num / gcd, den / gcd
  end

  attr_reader :numerator, :denominator

  def initialize(numerator, denominator = 1)
    @numerator, @denominator = Rational.reduce(numerator, denominator)
  end

  def coerce(other)
    case other
    when Rational
      [other, self]

    when Integer
      [other.to_r, self]

    when Float
      [other, to_f]
    end
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

  def <=>(other)
    case other
    when Rational
      @numerator * other.denominator - @denominator * other.numerator <=> 0

    when Integer
      @numerator - @denominator * other <=> 0

    when Float
      to_f <=> other

    else
      __coerced__ :<=>, other
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
      __coerced__ :+, other
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
      __coerced__ :-, other
    end
  end

  def *(other)
    case other
    when Rational
      num = @numerator * other.numerator
      den = @denominator * other.denominator

      Rational.new(num, den)
    when Integer
      Rational(@numerator * other, @denominator)

    when Float
      to_f * other

    else
      __coerced__ :*, other
    end
  end

  def /(other)
    case other
    when Rational
      num = @numerator * other.denominator
      den = @denominator * other.numerator

      Rational.new(num, den)

    when Integer
      if other == 0
        to_f / 0.0
      else
        Rational.new(@numerator, @denominator * other)
      end

    when Float
      to_f / other

    else
      __coerced__ :/, other
    end
  end

  def **(other)
    case other
    when Integer
      if self == 0 && other < 0
        return Float::INFINITY
      elsif other > 0
        Rational.new(@numerator ** other, @denominator ** other)
      elsif other < 0
        Rational.new(@denominator ** -other, @numerator ** -other)
      else
        Rational.new(1, 1)
      end

    when Float
      to_f ** other

    when Rational
      if other == 0
        Rational.new(1, 1)
      elsif other.denominator == 1
        if other < 0
          Rational.new(@denominator ** other.numerator.abs, @numerator ** other.numerator.abs)
        else
          Rational.new(@numerator ** other.numerator, @denominator ** other.numerator)
        end
      elsif self == 0 && other < 0
        raise ZeroDivisionError, "divided by 0"
      else
        to_f ** other
      end

    else
      __coerced__ :**, other
    end
  end

  def abs
    Rational.new(@numerator.abs, @denominator.abs)
  end

  def ceil(precision = 0)
    if precision == 0
      (-(-@numerator / @denominator)).ceil
    else
      with_precision(:ceil, precision)
    end
  end

  alias divide /

  def floor(precision = 0)
    if precision == 0
      (-(-@numerator / @denominator)).floor
    else
      with_precision(:floor, precision)
    end
  end

  def hash
    "Rational:#@numerator:#@denominator"
  end

  def inspect
    "(#{to_s})"
  end

  alias quo /

  def rationalize(eps = undefined)
    %x{
      if (arguments.length > 1) {
        #{raise ArgumentError, "wrong number of arguments (#{`arguments.length`} for 0..1)"};
      }

      if (eps == null) {
        return self;
      }

      var e = #{eps.abs},
          a = #{self - `e`},
          b = #{self + `e`};

      var p0 = 0,
          p1 = 1,
          q0 = 1,
          q1 = 0,
          p2, q2;

      var c, k, t;

      while (true) {
        c = #{`a`.ceil};

        if (#{`c` < `b`}) {
          break;
        }

        k  = c - 1;
        p2 = k * p1 + p0;
        q2 = k * q1 + q0;
        t  = #{1 / (`b` - `k`)};
        b  = #{1 / (`a` - `k`)};
        a  = t;

        p0 = p1;
        q0 = q1;
        p1 = p2;
        q1 = q2;
      }

      return #{Rational.new(`c * p1 + p0`, `c * q1 + q0`)};
    }
  end

  def round(precision = 0)
    return with_precision(:round, precision) unless precision == 0
    return 0 if @numerator == 0
    return @numerator if @denominator == 1

    num = @numerator.abs * 2 + @denominator
    den = @denominator * 2

    approx = (num / den).truncate

    if @numerator < 0
      -approx
    else
      approx
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
      with_precision(:truncate, precision)
    end
  end

private
  def with_precision(method, precision)
    raise TypeError, "not an Integer" unless Integer === precision

    p = 10 ** precision
    s = self * p

    if precision < 1
      (s.send(method) / p).to_i
    else
      Rational.new(s.send(method), p)
    end
  end
end

module Kernel
  def Rational(numerator, denominator = nil)
    if denominator
      Rational.new(numerator, denominator)
    elsif Integer === numerator
      Rational.new(numerator, 1)
    elsif Float === numerator
      numerator.to_r
    else
      raise NotImplementedError
    end
  end
end
