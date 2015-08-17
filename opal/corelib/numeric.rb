require 'corelib/comparable'

class Numeric < `Number`
  include Comparable

  def coerce(other)
    %x{
      if (!#{other.is_a? Numeric}) {
        #{raise TypeError, "can't convert #{other.class} into Number"};
      }

      if (other.$$is_number) {
        return [self, other];
      }
      else if (#{self.respond_to?(:to_f)} && #{other.respond_to?(:to_f)}) {
        return [self.$to_f(), other.$to_f()];
      }
      else {
        #{raise TypeError, "can't convert #{other.class} into Number"};
      }
    }
  end

  def send_coerced(method, other)
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

  alias conjugate conj

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
