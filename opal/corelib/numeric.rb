require 'corelib/comparable'

class Numeric
  include Comparable

  def coerce(other)
    if other.instance_of? self.class
      return [other, self]
    end

    [Float(other), Float(self)]
  end

  def __coerced__(method, other)
    begin
      a, b = other.coerce(self)
    rescue
      case method
      when :+, :-, :*, :/, :%, :&, :|, :^, :**
        raise TypeError, "#{other.class} can't be coerce into Numeric"

      when :>, :>=, :<, :<=, :<=>
        raise ArgumentError, "comparison of #{self.class} with #{other.class} failed"
      end
    end

    a.__send__ method, b
  end

  def <=>(other)
    if equal? other
      return 0
    end

    nil
  end

  def +@
    self
  end

  def -@
    0 - self
  end

  def %(other)
    self - other * self.div(other)
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

  alias conjugate conj

  def denominator
    to_r.denominator
  end

  def div(other)
    raise ZeroDivisionError, "divided by o" if other == 0

    (self / other).floor
  end

  def divmod(other)
    [div(other), self % other]
  end

  def fdiv(other)
    self.to_f / other
  end

  def floor
    to_f.floor
  end

  def i
    Complex(0, self)
  end

  def imag
    0
  end

  alias imaginary imag

  def integer?
    false
  end

  alias magnitude abs

  alias modulo %

  def nonzero?
    zero? ? nil : self
  end

  def numerator
    to_r.numerator
  end

  alias phase arg

  def polar
    return abs, arg
  end

  def quo(other)
    Opal.coerce_to!(self, Rational, :to_r) / other
  end

  def real
    self
  end

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

  def positive?
    self > 0
  end

  def negative?
    self < 0
  end

  def dup
    raise TypeError, "can't dup #{self.class}"
  end

  def clone
    raise TypeError, "can't clone #{self.class}"
  end
end
