require 'corelib/comparable'

class Numeric
  include Comparable

  # FIXME: temporary hack
  def self.===(other)
    return super unless self == Numeric

    `!!other._isNumber || #{super}`
  end

  def [](bit)
    bit = Opal.coerce_to! bit, Integer, :to_int
    min = -(2**30)
    max =  (2**30) - 1

    `(#{bit} < #{min} || #{bit} > #{max}) ? 0 : (self >> #{bit}) % 2`
  end

  def +@
    self
  end

  def -@
    0 - self
  end

  def abs
    self < 0 ? -self : self
  end

  def abs2
    self * self
  end

  def angle
    self < 0 ? Math::PI : 0
  end

  alias arg angle

  def ceil
    to_f.ceil
  end

  def conj
    self
  end

  alias conjugate self

  def denominator
    to_r.denominator
  end

  def floor
    to_f.floor
  end

  def i
    Complex(0, self)
  end

  def integer?
    false
  end

  def nonzero?
    zero? ? nil : self
  end

  def numerator
    to_r.numerator
  end

  def real
    self
  end

  def imag
    0
  end

  alias imaginary imag

  def real?
    true
  end

  def rect
    [self, 0]
  end

  alias rectangular rect

  def round(digits = undefined)
    to_f.round(digits)
  end

  def to_c
    Complex(self, 0)
  end

  def to_int
    to_i
  end

  def truncate
    to_f.truncate
  end

  def zero?
    self == 0
  end
end
