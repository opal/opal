require 'corelib/numeric'

class Complex < Numeric
  def self.rect(real, imag = 0)
    unless real.real? && imag.real?
      raise TypeError, 'not a real'
    end

    new(real, imag)
  end

  def self.polar(r, theta = 0)
    unless r.real? && theta.real?
      raise TypeError, 'not a real'
    end

    new(r * Math.cos(theta), r * Math.sin(theta))
  end

  attr_reader :real, :imag

  def initialize(real, imag = 0)
    @real = real
    @imag = imag
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
      a, b = other.coerce(self)
      a + b
    end
  end

  def -(other)
    if Complex === other
      Complex(@real - other.real, @imag - other.imag)
    elsif Numeric === other && other.real?
      Complex(@real - other, @imag)
    else
      a, b = other.coerce(self)
      a - b
    end
  end

  def *(other)
    if Complex === other
      Complex(@real * other.real - @imag * other.imag,
              @real * other.imag + @imag * other.real)
    elsif Numeric === other && other.real?
      Complex(@real * other, @imag * other)
    else
      a, b = other.coerce(self)
      a * b
    end
  end

  def /(other)
    if Complex === other
      self * other.conj / other.abs2
    elsif Numeric === other && other.real?
      Complex(@real / other, @imag / other)
    else
      a, b = other.coerce(self)
      a / b
    end
  end

  def **(other)
    raise NotImplementedError
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

  def coerce(other)
    if Numeric === other && other.real?
      [Complex(other, 0), self]
    elsif Complex === other
      [other, self]
    end
  end

  def conj
    Complex(@real, -@imag)
  end

  alias conjugate conj

  def denominator
    @real.denominator.lcm(@imag.denominator)
  end

  alias divide /

  def eql?(other)
    Complex === other && @real.eql?(other.real) && @imag.eql?(other.imag)
  end

  alias fdiv /

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

  def real?
    false
  end

  def rect
    [@real, @imag]
  end

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
    result = @real.to_s

    if @imag.nan? || @imag.positive?
      result += ?+
    else
      result += ?-
    end

    result += @imag.abs.to_s

    if @imag.nan? || @imag.infinite?
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
    elsif Integer === real
      Complex.new(real, 0)
    else
      raise NotImplementedError
    end
  end
end
