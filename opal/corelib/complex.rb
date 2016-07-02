require 'corelib/numeric'

class Complex < Numeric
  def self.rect(real, imag = 0)
    unless Numeric === real && real.real? && Numeric === imag && imag.real?
      raise TypeError, 'not a real'
    end

    new(real, imag)
  end

  class << self
    alias rectangular rect
  end

  def self.polar(r, theta = 0)
    unless Numeric === r && r.real? && Numeric === theta && theta.real?
      raise TypeError, 'not a real'
    end

    new(r * Math.cos(theta), r * Math.sin(theta))
  end

  attr_reader :real, :imag

  def initialize(real, imag = 0)
    @real = real
    @imag = imag
  end

  def coerce(other)
    if Complex === other
      [other, self]
    elsif Numeric === other && other.real?
      [Complex.new(other, 0), self]
    else
      raise TypeError, "#{other.class} can't be coerced into Complex"
    end
  end

  def ==(other)
    if Complex === other
      @real == other.real && @imag == other.imag
    elsif Numeric === other && other.real?
      @real == other && @imag == 0
    else
      other == self
    end
  end

  def -@
    Complex(-@real, -@imag)
  end

  def +(other)
    if Complex === other
      Complex(@real + other.real, @imag + other.imag)
    elsif Numeric === other && other.real?
      Complex(@real + other, @imag)
    else
      __coerced__ :+, other
    end
  end

  def -(other)
    if Complex === other
      Complex(@real - other.real, @imag - other.imag)
    elsif Numeric === other && other.real?
      Complex(@real - other, @imag)
    else
      __coerced__ :-, other
    end
  end

  def *(other)
    if Complex === other
      Complex(@real * other.real - @imag * other.imag,
              @real * other.imag + @imag * other.real)
    elsif Numeric === other && other.real?
      Complex(@real * other, @imag * other)
    else
      __coerced__ :*, other
    end
  end

  def /(other)
    if Complex === other
      if (Number === @real && @real.nan?) || (Number === @imag && @imag.nan?) ||
         (Number === other.real && other.real.nan?) || (Number === other.imag && other.imag.nan?)
        Complex.new(Float::NAN, Float::NAN)
      else
        self * other.conj / other.abs2
      end
    elsif Numeric === other && other.real?
      Complex(@real.quo(other), @imag.quo(other))
    else
      __coerced__ :/, other
    end
  end

  def **(other)
    if other == 0
      return Complex.new(1, 0)
    end

    if Complex === other
      r, theta = polar
      ore      = other.real
      oim      = other.imag
      nr       = Math.exp(ore * Math.log(r) - oim * theta)
      ntheta   = theta * ore + oim * Math.log(r)

      Complex.polar(nr, ntheta)
    elsif Integer === other
      if other > 0
        x = self
        z = x
        n = other - 1

        while n != 0
          while (div, mod = n.divmod(2); mod == 0)
            x = Complex(x.real * x.real - x.imag * x.imag, 2 * x.real * x.imag)
            n = div
          end

          z *= x
          n -= 1
        end

        z
      else
        (Rational.new(1, 1) / self) ** -other
      end
    elsif Float === other || Rational === other
      r, theta = polar

      Complex.polar(r ** other, theta * other)
    else
      __coerced__ :**, other
    end
  end

  def abs
    Math.hypot(@real, @imag)
  end

  def abs2
    @real * @real + @imag * @imag
  end

  def angle
    Math.atan2(@imag, @real)
  end

  alias arg angle

  def conj
    Complex(@real, -@imag)
  end

  alias conjugate conj

  def denominator
    @real.denominator.lcm(@imag.denominator)
  end

  alias divide /

  def eql?(other)
    Complex === other && @real.class == @imag.class && self == other
  end

  def fdiv(other)
    unless Numeric === other
      raise TypeError, "#{other.class} can't be coerced into Complex"
    end

    self / other
  end

  def hash
    "Complex:#@real:#@imag"
  end

  alias imaginary imag

  def inspect
    "(#{to_s})"
  end

  alias magnitude abs

  def numerator
    d = denominator

    Complex(@real.numerator * (d / @real.denominator),
            @imag.numerator * (d / @imag.denominator))
  end

  alias phase arg

  def polar
    [abs, arg]
  end

  alias quo /

  def rationalize(eps = undefined)
    %x{
      if (arguments.length > 1) {
        #{raise ArgumentError, "wrong number of arguments (#{`arguments.length`} for 0..1)"};
      }
    }

    if @imag != 0
      raise RangeError, "can't' convert #{self} into Rational"
    end

    real.rationalize(eps)
  end

  def real?
    false
  end

  def rect
    [@real, @imag]
  end

  alias rectangular rect

  def to_f
    unless @imag == 0
      raise RangeError, "can't convert #{self} into Float"
    end

    @real.to_f
  end

  def to_i
    unless @imag == 0
      raise RangeError, "can't convert #{self} into Integer"
    end

    @real.to_i
  end

  def to_r
    unless @imag == 0
      raise RangeError, "can't convert #{self} into Rational"
    end

    @real.to_r
  end

  def to_s
    result = @real.inspect

    if (Number === @imag && @imag.nan?) || @imag.positive? || @imag.zero?
      result += ?+
    else
      result += ?-
    end

    result += @imag.abs.inspect

    if Number === @imag && (@imag.nan? || @imag.infinite?)
      result += ?*
    end

    result + ?i
  end

  I = new(0, 1)
end

module Kernel
  def Complex(real, imag = nil)
    if imag
      Complex.new(real, imag)
    else
      Complex.new(real, 0)
    end
  end
end
