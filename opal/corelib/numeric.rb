require 'corelib/comparable'

class ::Numeric
  include ::Comparable

  def coerce(other)
    if other.instance_of? self.class
      return [other, self]
    end

    [::Kernel.Float(other), ::Kernel.Float(self)]
  end

  def __coerced__(method, other)
    if other.respond_to?(:coerce)
      a, b = other.coerce(self)
      a.__send__ method, b
    else
      case method
      when :+, :-, :*, :/, :%, :&, :|, :^, :**
        ::Kernel.raise ::TypeError, "#{other.class} can't be coerced into Numeric"
      when :>, :>=, :<, :<=, :<=>
        ::Kernel.raise ::ArgumentError, "comparison of #{self.class} with #{other.class} failed"
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
    self < 0 ? ::Math::PI : 0
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
    ::Kernel.raise ::ZeroDivisionError, 'divided by o' if other == 0

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
    ::Kernel.Complex(0, self)
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
    ::Opal.coerce_to!(self, ::Rational, :to_r) / other
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
        #{::Kernel.raise ::ArgumentError, 'to is given twice'}
      }

      if (step !== undefined && by !== undefined) {
        #{::Kernel.raise ::ArgumentError, 'step is given twice'}
      }

      if (to !== undefined) {
        limit = to;
      }

      if (by !== undefined) {
        step = by;
      }

      if (limit === undefined) {
        limit = nil;
      }

      function validateParameters() {
        if (step === nil) {
          #{::Kernel.raise ::TypeError, 'step must be numeric'}
        }

        if (step != null && #{step == 0}) {
          #{::Kernel.raise ::ArgumentError, "step can't be 0"}
        }

        if (step === nil || step == null) {
          step = 1;
        }

        var sign = #{step <=> 0};

        if (sign === nil) {
          #{::Kernel.raise ::ArgumentError, "0 can't be coerced into #{step.class}"}
        }

        if (limit === nil || limit == null) {
          limit = sign > 0 ? #{::Float::INFINITY} : #{-::Float::INFINITY};
        }

        #{::Opal.compare(self, limit)}
      }

      function stepFloatSize() {
        if ((step > 0 && self > limit) || (step < 0 && self < limit)) {
          return 0;
        } else if (step === Infinity || step === -Infinity) {
          return 1;
        } else {
          var abs = Math.abs, floor = Math.floor,
              err = (abs(self) + abs(limit) + abs(limit - self)) / abs(step) * #{::Float::EPSILON};

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

    return enum_for(:step, limit, step, &`stepSize`) unless block_given?

    %x{
      validateParameters();

      var isDesc = #{step.negative?},
          isInf = #{step == 0} ||
                  (limit === Infinity && !isDesc) ||
                  (limit === -Infinity && isDesc);

      if (self.$$is_number && step.$$is_number && limit.$$is_number) {
        if (self % 1 === 0 && (isInf || limit % 1 === 0) && step % 1 === 0) {
          var value = self;

          if (isInf) {
            for (;; value += step) {
              block(value);
            }
          } else if (isDesc) {
            for (; value >= limit; value += step) {
              block(value);
            }
          } else {
            for (; value <= limit; value += step) {
              block(value);
            }
          }

          return self;
        } else {
          var begin = #{to_f}.valueOf();
          step = #{step.to_f}.valueOf();
          limit = #{limit.to_f}.valueOf();

          var n = stepFloatSize();

          if (!isFinite(step)) {
            if (n !== 0) block(begin);
          } else if (step === 0) {
            while (true) {
              block(begin);
            }
          } else {
            for (var i = 0; i < n; i++) {
              var d = i * step + self;
              if (step >= 0 ? limit < d : limit > d) {
                d = limit;
              }
              block(d);
            }
          }

          return self;
        }
      }
    }

    counter = self

    while `isDesc ? #{counter >= limit} : #{counter <= limit}`
      yield counter
      counter += step
    end
  end

  def to_c
    ::Kernel.Complex(self, 0)
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
