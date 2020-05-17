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
    if other.respond_to?(:coerce)
      a, b = other.coerce(self)
      a.__send__ method, b
    else
      case method
      when :+, :-, :*, :/, :%, :&, :|, :^, :**
        raise TypeError, "#{other.class} can't be coerced into Numeric"
      when :>, :>=, :<, :<=, :<=>
        raise ArgumentError, "comparison of #{self.class} with #{other.class} failed"
      end
    end
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
    self - other * div(other)
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

  def ceil(ndigits = 0)
    to_f.ceil(ndigits)
  end

  def conj
    self
  end

  alias conjugate conj

  def denominator
    to_r.denominator
  end

  def div(other)
    raise ZeroDivisionError, 'divided by o' if other == 0

    (self / other).floor
  end

  def divmod(other)
    [div(other), self % other]
  end

  def fdiv(other)
    to_f / other
  end

  def floor(ndigits = 0)
    to_f.floor(ndigits)
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
    [abs, arg]
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

  def step(limit = undefined, step = undefined, to: undefined, by: undefined, &block)
    %x{
      if (limit !== undefined && to !== undefined) {
        #{raise ArgumentError, 'to is given twice'}
      }

      if (step !== undefined && by !== undefined) {
        #{raise ArgumentError, 'step is given twice'}
      }

      function validateParameters() {
        if (to !== undefined) {
          limit = to;
        }

        if (limit === undefined) {
          limit = nil;
        }

        if (step === nil) {
          #{raise TypeError, 'step must be numeric'}
        }

        if (step === 0) {
          #{raise ArgumentError, "step can't be 0"}
        }

        if (by !== undefined) {
          step = by;
        }

        if (step === nil || step == null) {
          step = 1;
        }

        var sign = #{step <=> 0};

        if (sign === nil) {
          #{raise ArgumentError, "0 can't be coerced into #{step.class}"}
        }

        if (limit === nil || limit == null) {
          limit = sign > 0 ? #{Float::INFINITY} : #{-Float::INFINITY};
        }

        #{Opal.compare(self, limit)}
      }

      function stepFloatSize() {
        if ((step > 0 && self > limit) || (step < 0 && self < limit)) {
          return 0;
        } else if (step === Infinity || step === -Infinity) {
          return 1;
        } else {
          var abs = Math.abs, floor = Math.floor,
              err = (abs(self) + abs(limit) + abs(limit - self)) / abs(step) * #{Float::EPSILON};

          if (err === Infinity || err === -Infinity) {
            return 0;
          } else {
            if (err > 0.5) {
              err = 0.5;
            }

            return floor((limit - self) / step + err) + 1
          }
        }
      }

      function stepSize() {
        validateParameters();

        if (step === 0) {
          return Infinity;
        }

        if (step % 1 !== 0) {
          return stepFloatSize();
        } else if ((step > 0 && self > limit) || (step < 0 && self < limit)) {
          return 0;
        } else {
          var ceil = Math.ceil, abs = Math.abs,
              lhs = abs(self - limit) + 1,
              rhs = abs(step);

          return ceil(lhs / rhs);
        }
      }
    }

    unless block_given?
      positional_args = []
      keyword_args = {}

      %x{
        if (limit !== undefined) {
          positional_args.push(limit);
        }

        if (step !== undefined) {
          positional_args.push(step);
        }

        if (to !== undefined) {
          Opal.hash_put(keyword_args, "to", to);
        }

        if (by !== undefined) {
          Opal.hash_put(keyword_args, "by", by);
        }

        if (#{keyword_args.any?}) {
          positional_args.push(keyword_args);
        }
      }

      return enum_for(:step, *positional_args) { `stepSize()` }
    end

    %x{
      validateParameters();

      if (step === 0) {
        while (true) {
          block(self);
        }
      }

      if (self % 1 !== 0 || limit % 1 !== 0 || step % 1 !== 0) {
        var n = stepFloatSize();

        if (n > 0) {
          if (step === Infinity || step === -Infinity) {
            block(self);
          } else {
            var i = 0, d;

            if (step > 0) {
              while (i < n) {
                d = i * step + self;
                if (limit < d) {
                  d = limit;
                }
                block(d);
                i += 1;
              }
            } else {
              while (i < n) {
                d = i * step + self;
                if (limit > d) {
                  d = limit;
                }
                block(d);
                i += 1
              }
            }
          }
        }
      } else {
        var value = self;

        if (step > 0) {
          while (value <= limit) {
            block(value);
            value += step;
          }
        } else {
          while (value >= limit) {
            block(value);
            value += step
          }
        }
      }

      return self;
    }
  end

  def to_c
    Complex(self, 0)
  end

  def to_int
    to_i
  end

  def truncate(ndigits = 0)
    to_f.truncate(ndigits)
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
    self
  end

  def clone(freeze: true)
    self
  end

  def finite?
    true
  end

  def infinite?
    nil
  end
end
