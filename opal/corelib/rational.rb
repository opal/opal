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
      return new(num, den)
    end

    gcd = num.gcd(den)

    new(num / gcd, den / gcd)
  end

  def self.convert(num, den)
    if num.nil? || den.nil?
      raise TypeError, "cannot convert nil into Rational"
    end

    if Integer === num && Integer === den
      return reduce(num, den)
    end

    if Float === num || String === num || Complex === num
      num = num.to_r
    end

    if Float === den || String === den || Complex === den
      den = den.to_r
    end

    if den.equal?(1) && !(Integer === num)
      Opal.coerce_to!(num, Rational, :to_r)
    elsif Numeric === num && Numeric === den
      num / den
    else
      reduce(num, den)
    end
  end

  attr_reader :numerator, :denominator

  def initialize(num, den)
    @num = num
    @den = den
  end

  def numerator
    @num
  end

  def denominator
    @den
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
      @num == other.numerator && @den == other.denominator

    when Integer
      @num == other && @den == 1

    when Float
      to_f == other

    else
      other == self
    end
  end

  def <=>(other)
    case other
    when Rational
      @num * other.denominator - @den * other.numerator <=> 0

    when Integer
      @num - @den * other <=> 0

    when Float
      to_f <=> other

    else
      __coerced__ :<=>, other
    end
  end

  def +(other)
    case other
    when Rational
      num = @num * other.denominator + @den * other.numerator
      den = @den * other.denominator

      Rational(num, den)

    when Integer
      Rational(@num + other * @den, @den)

    when Float
      to_f + other

    else
      __coerced__ :+, other
    end
  end

  def -(other)
    case other
    when Rational
      num = @num * other.denominator - @den * other.numerator
      den = @den * other.denominator

      Rational(num, den)

    when Integer
      Rational(@num - other * @den, @den)

    when Float
      to_f - other

    else
      __coerced__ :-, other
    end
  end

  def *(other)
    case other
    when Rational
      num = @num * other.numerator
      den = @den * other.denominator

      Rational(num, den)

    when Integer
      Rational(@num * other, @den)

    when Float
      to_f * other

    else
      __coerced__ :*, other
    end
  end

  def /(other)
    case other
    when Rational
      num = @num * other.denominator
      den = @den * other.numerator

      Rational(num, den)

    when Integer
      if other == 0
        to_f / 0.0
      else
        Rational(@num, @den * other)
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
        Rational(@num ** other, @den ** other)
      elsif other < 0
        Rational(@den ** -other, @num ** -other)
      else
        Rational(1, 1)
      end

    when Float
      to_f ** other

    when Rational
      if other == 0
        Rational(1, 1)
      elsif other.denominator == 1
        if other < 0
          Rational(@den ** other.numerator.abs, @num ** other.numerator.abs)
        else
          Rational(@num ** other.numerator, @den ** other.numerator)
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
    Rational(@num.abs, @den.abs)
  end

  def ceil(precision = 0)
    if precision == 0
      (-(-@num / @den)).ceil
    else
      with_precision(:ceil, precision)
    end
  end

  alias divide /

  def floor(precision = 0)
    if precision == 0
      (-(-@num / @den)).floor
    else
      with_precision(:floor, precision)
    end
  end

  def hash
    "Rational:#@num:#@den"
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

        if (#{`c` <= `b`}) {
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

      return #{Rational(`c * p1 + p0`, `c * q1 + q0`)};
    }
  end

  def round(precision = 0)
    return with_precision(:round, precision) unless precision == 0
    return 0 if @num == 0
    return @num if @den == 1

    num = @num.abs * 2 + @den
    den = @den * 2

    approx = (num / den).truncate

    if @num < 0
      -approx
    else
      approx
    end
  end

  def to_f
    @num / @den
  end

  def to_i
    truncate
  end

  def to_r
    self
  end

  def to_s
    "#@num/#@den"
  end

  def truncate(precision = 0)
    if precision == 0
      @num < 0 ? ceil : floor
    else
      with_precision(:truncate, precision)
    end
  end

  def with_precision(method, precision)
    raise TypeError, "not an Integer" unless Integer === precision

    p = 10 ** precision
    s = self * p

    if precision < 1
      (s.send(method) / p).to_i
    else
      Rational(s.send(method), p)
    end
  end
end

module Kernel
  def Rational(numerator, denominator = 1)
    Rational.convert(numerator, denominator)
  end
end
