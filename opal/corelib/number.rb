require 'corelib/numeric'

class Number < Numeric
  Opal.bridge(self, `Number`)
  `Number.prototype.$$is_number = true`
  `self.$$is_number_class = true`

  class << self
    def allocate
      raise TypeError, "allocator undefined for #{self.name}"
    end

    undef :new
  end

  def coerce(other)
    %x{
      if (other === nil) {
        #{raise TypeError, "can't convert #{other.class} into Float"};
      }
      else if (other.$$is_string) {
        return [#{Float(other)}, self];
      }
      else if (#{other.respond_to?(:to_f)}) {
        return [#{Opal.coerce_to!(other, Float, :to_f)}, self];
      }
      else if (other.$$is_number) {
        return [other, self];
      }
      else {
        #{raise TypeError, "can't convert #{other.class} into Float"};
      }
    }
  end

  def __id__
    `(self * 2) + 1`
  end

  alias object_id __id__

  def +(other)
    %x{
      if (other.$$is_number) {
        return self + other;
      }
      else {
        return #{__coerced__ :+, other};
      }
    }
  end

  def -(other)
    %x{
      if (other.$$is_number) {
        return self - other;
      }
      else {
        return #{__coerced__ :-, other};
      }
    }
  end

  def *(other)
    %x{
      if (other.$$is_number) {
        return self * other;
      }
      else {
        return #{__coerced__ :*, other};
      }
    }
  end

  def /(other)
    %x{
      if (other.$$is_number) {
        return self / other;
      }
      else {
        return #{__coerced__ :/, other};
      }
    }
  end

  alias fdiv /

  def %(other)
    %x{
      if (other.$$is_number) {
        if (other == -Infinity) {
          return other;
        }
        else if (other == 0) {
          #{raise ZeroDivisionError, "divided by 0"};
        }
        else if (other < 0 || self < 0) {
          return (self % other + other) % other;
        }
        else {
          return self % other;
        }
      }
      else {
        return #{__coerced__ :%, other};
      }
    }
  end

  def &(other)
    %x{
      if (other.$$is_number) {
        return self & other;
      }
      else {
        return #{__coerced__ :&, other};
      }
    }
  end

  def |(other)
    %x{
      if (other.$$is_number) {
        return self | other;
      }
      else {
        return #{__coerced__ :|, other};
      }
    }
  end

  def ^(other)
    %x{
      if (other.$$is_number) {
        return self ^ other;
      }
      else {
        return #{__coerced__ :^, other};
      }
    }
  end

  def <(other)
    %x{
      if (other.$$is_number) {
        return self < other;
      }
      else {
        return #{__coerced__ :<, other};
      }
    }
  end

  def <=(other)
    %x{
      if (other.$$is_number) {
        return self <= other;
      }
      else {
        return #{__coerced__ :<=, other};
      }
    }
  end

  def >(other)
    %x{
      if (other.$$is_number) {
        return self > other;
      }
      else {
        return #{__coerced__ :>, other};
      }
    }
  end

  def >=(other)
    %x{
      if (other.$$is_number) {
        return self >= other;
      }
      else {
        return #{__coerced__ :>=, other};
      }
    }
  end

  # Compute the result of the spaceship operator inside its own function so it
  # can be optimized despite a try/finally construct.
  %x{
    var spaceship_operator = function(self, other) {
      if (other.$$is_number) {
        if (isNaN(self) || isNaN(other)) {
          return nil;
        }

        if (self > other) {
          return 1;
        } else if (self < other) {
          return -1;
        } else {
          return 0;
        }
      }
      else {
        return #{__coerced__ :<=>, `other`};
      }
    }
  }

  def <=>(other)
    %x{
      return spaceship_operator(self, other);
    }
  rescue ArgumentError
    nil
  end

  def <<(count)
    count = Opal.coerce_to! count, Integer, :to_int

    `#{count} > 0 ? self << #{count} : self >> -#{count}`
  end

  def >>(count)
    count = Opal.coerce_to! count, Integer, :to_int

    `#{count} > 0 ? self >> #{count} : self << -#{count}`
  end

  def [](bit)
    bit = Opal.coerce_to! bit, Integer, :to_int

    %x{
      if (#{bit} < 0) {
        return 0;
      }
      if (#{bit} >= 32) {
        return #{ self } < 0 ? 1 : 0;
      }
      return (self >> #{bit}) & 1;
    }
  end

  def +@
    `+self`
  end

  def -@
    `-self`
  end

  def ~
    `~self`
  end

  def **(other)
    if Integer === other
      if !(Integer === self) || other > 0
        `Math.pow(self, other)`
      else
        Rational.new(self, 1) ** other
      end
    elsif self < 0 && (Float === other || Rational === other)
      Complex.new(self, 0) ** other.to_f
    elsif `other.$$is_number != null`
      `Math.pow(self, other)`
    else
      __coerced__ :**, other
    end
  end

  def ===(other)
    %x{
      if (other.$$is_number) {
        return self.valueOf() === other.valueOf();
      }
      else if (#{other.respond_to? :==}) {
        return #{other == self};
      }
      else {
        return false;
      }
    }
  end

  def ==(other)
    %x{
      if (other.$$is_number) {
        return self.valueOf() === other.valueOf();
      }
      else if (#{other.respond_to? :==}) {
        return #{other == self};
      }
      else {
        return false;
      }
    }
  end

  def abs
    `Math.abs(self)`
  end

  def abs2
    `Math.abs(self * self)`
  end

  def allbits?(mask)
    mask = Opal.coerce_to! mask, Integer, :to_int
    `(self & mask) == mask`
  end

  def anybits?(mask)
    mask = Opal.coerce_to! mask, Integer, :to_int
    `(self & mask) !== 0`
  end

  def angle
    return self if nan?

    %x{
      if (self == 0) {
        if (1 / self > 0) {
          return 0;
        }
        else {
          return Math.PI;
        }
      }
      else if (self < 0) {
        return Math.PI;
      }
      else {
        return 0;
      }
    }
  end

  alias arg angle
  alias phase angle

  def bit_length
    unless Integer === self
      raise NoMethodError.new("undefined method `bit_length` for #{self}:Float", 'bit_length')
    end

    %x{
      if (self === 0 || self === -1) {
        return 0;
      }

      var result = 0,
          value  = self < 0 ? ~self : self;

      while (value != 0) {
        result   += 1;
        value  >>>= 1;
      }

      return result;
    }
  end

  def ceil(ndigits = 0)
    %x{
      var f = #{to_f};

      if (f % 1 === 0 && ndigits >= 0) {
        return f;
      }

      var factor = Math.pow(10, ndigits),
          result = Math.ceil(f * factor) / factor;

      if (f % 1 === 0) {
        result = Math.round(result);
      }

      return result;
    }
  end

  def chr(encoding = undefined)
    `String.fromCharCode(self)`
  end

  def denominator
    if nan? || infinite?
      1
    else
      super
    end
  end

  def downto(stop, &block)
    return enum_for(:downto, stop){
      raise ArgumentError, "comparison of #{self.class} with #{stop.class} failed" unless Numeric === stop
      stop > self ? 0 : self - stop + 1
    } unless block_given?

    %x{
      if (!stop.$$is_number) {
        #{raise ArgumentError, "comparison of #{self.class} with #{stop.class} failed"}
      }
      for (var i = self; i >= stop; i--) {
        block(i);
      }
    }

    self
  end

  alias eql? ==

  def equal?(other)
    self == other || `isNaN(self) && isNaN(other)`
  end

  def even?
    `self % 2 === 0`
  end

  def floor(ndigits = 0)
    %x{
      var f = #{to_f};

      if (f % 1 === 0 && ndigits >= 0) {
        return f;
      }

      var factor = Math.pow(10, ndigits),
          result = Math.floor(f * factor) / factor;

      if (f % 1 === 0) {
        result = Math.round(result);
      }

      return result;
    }
  end

  def gcd(other)
    unless Integer === other
      raise TypeError, 'not an integer'
    end

    %x{
      var min = Math.abs(self),
          max = Math.abs(other);

      while (min > 0) {
        var tmp = min;

        min = max % min;
        max = tmp;
      }

      return max;
    }
  end

  def gcdlcm(other)
    [gcd, lcm]
  end

  def integer?
    `self % 1 === 0`
  end

  def is_a?(klass)
    return true if klass == Fixnum && Integer === self
    return true if klass == Integer && Integer === self
    return true if klass == Float && Float === self

    super
  end

  alias kind_of? is_a?

  def instance_of?(klass)
    return true if klass == Fixnum && Integer === self
    return true if klass == Integer && Integer === self
    return true if klass == Float && Float === self

    super
  end

  def lcm(other)
    unless Integer === other
      raise TypeError, 'not an integer'
    end

    %x{
      if (self == 0 || other == 0) {
        return 0;
      }
      else {
        return Math.abs(self * other / #{gcd(other)});
      }
    }
  end

  alias magnitude abs

  alias modulo %

  def next
    `self + 1`
  end

  def nobits?(mask)
    mask = Opal.coerce_to! mask, Integer, :to_int
    `(self & mask) == 0`
  end

  def nonzero?
    `self == 0 ? nil : self`
  end

  def numerator
    if nan? || infinite?
      self
    else
      super
    end
  end

  def odd?
    `self % 2 !== 0`
  end

  def ord
    self
  end

  def pred
    `self - 1`
  end

  def quo(other)
    if Integer === self
      super
    else
      self / other
    end
  end

  def rationalize(eps = undefined)
    %x{
      if (arguments.length > 1) {
        #{raise ArgumentError, "wrong number of arguments (#{`arguments.length`} for 0..1)"};
      }
    }

    if Integer === self
      Rational.new(self, 1)
    elsif infinite?
      raise FloatDomainError, "Infinity"
    elsif nan?
      raise FloatDomainError, "NaN"
    elsif `eps == null`
      f, n  = Math.frexp self
      f     = Math.ldexp(f, Float::MANT_DIG).to_i
      n    -= Float::MANT_DIG

      Rational.new(2 * f, 1 << (1 - n)).rationalize(Rational.new(1, 1 << (1 - n)))
    else
      to_r.rationalize(eps)
    end
  end

  def round(ndigits = undefined)
    if Integer === self
      if `ndigits == null`
        return self
      end

      if Float === ndigits && ndigits.infinite?
        raise RangeError, "Infinity"
      end

      ndigits = Opal.coerce_to!(ndigits, Integer, :to_int)

      if ndigits < Integer::MIN
        raise RangeError, "out of bounds"
      end

      if `ndigits >= 0`
        return self
      end

      ndigits = -ndigits;

      %x{
        if (0.415241 * ndigits - 0.125 > #{size}) {
          return 0;
        }

        var f = Math.pow(10, ndigits),
            x = Math.floor((Math.abs(x) + f / 2) / f) * f;

        return self < 0 ? -x : x;
      }
    else
      if nan? && `ndigits == null`
        raise FloatDomainError, "NaN"
      end

      ndigits = Opal.coerce_to!(`ndigits || 0`, Integer, :to_int)

      if ndigits <= 0
        if nan?
          raise RangeError, "NaN"
        elsif infinite?
          raise FloatDomainError, "Infinity"
        end
      elsif ndigits == 0
        return `Math.round(self)`
      elsif nan? || infinite?
        return self
      end

      _, exp = Math.frexp(self)

      if ndigits >= (Float::DIG + 2) - (exp > 0 ? exp / 4 : exp / 3 - 1)
        return self
      end

      if ndigits < -(exp > 0 ? exp / 3 + 1 : exp / 4)
        return 0
      end

      `Math.round(self * Math.pow(10, ndigits)) / Math.pow(10, ndigits)`
    end
  end

  def step(limit = undefined, step = undefined, to: undefined, by: undefined, &block)
    %x{
      if (limit !== undefined && to !== undefined) {
        #{raise ArgumentError, "to is given twice"}
      }

      if (step !== undefined && by !== undefined) {
        #{raise ArgumentError, "step is given twice"}
      }

      function validateParameters() {
        if (to !== undefined) {
          limit = to;
        }

        if (limit === undefined) {
          limit = nil;
        }

        if (step === nil) {
          #{raise TypeError, "step must be numeric"}
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

        if (!#{keyword_args.empty?}) {
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

  alias succ next

  def times(&block)
    return enum_for(:times) { self } unless block

    %x{
      for (var i = 0; i < self; i++) {
        block(i);
      }
    }

    self
  end

  def to_f
    self
  end

  def to_i
    `parseInt(self, 10)`
  end

  alias to_int to_i

  def to_r
    if Integer === self
      Rational.new(self, 1)
    else
      f, e  = Math.frexp(self)
      f     = Math.ldexp(f, Float::MANT_DIG).to_i
      e    -= Float::MANT_DIG

      (f * (Float::RADIX ** e)).to_r
    end
  end

  def to_s(base = 10)
    base = Opal.coerce_to! base, Integer, :to_int

    if base < 2 || base > 36
      raise ArgumentError, "invalid radix #{base}"
    end

    `self.toString(base)`
  end

  def truncate(ndigits = 0)
    %x{
      var f = #{to_f};

      if (f % 1 === 0 && ndigits >= 0) {
        return f;
      }

      var factor = Math.pow(10, ndigits),
          result = parseInt(f * factor, 10) / factor;

      if (f % 1 === 0) {
        result = Math.round(result);
      }

      return result;
    }
  end

  alias inspect to_s

  def digits(base = 10)
    if self < 0
      raise Math::DomainError, 'out of domain'
    end

    base = Opal.coerce_to! base, Integer, :to_int

    if base < 2
      raise ArgumentError, "invalid radix #{base}"
    end

    %x{
      var value = self, result = [];

      while (value !== 0) {
        result.push(value % base);
        value = parseInt(value / base);
      }

      return result;
    }
  end

  def divmod(other)
    if nan? || other.nan?
      raise FloatDomainError, "NaN"
    elsif infinite?
      raise FloatDomainError, "Infinity"
    else
      super
    end
  end

  def upto(stop, &block)
    return enum_for(:upto, stop){
      raise ArgumentError, "comparison of #{self.class} with #{stop.class} failed" unless Numeric === stop
      stop < self ? 0 : stop - self + 1
    } unless block_given?

    %x{
      if (!stop.$$is_number) {
        #{raise ArgumentError, "comparison of #{self.class} with #{stop.class} failed"}
      }
      for (var i = self; i <= stop; i++) {
        block(i);
      }
    }

    self
  end

  def zero?
    `self == 0`
  end

  # Since bitwise operations are 32 bit, declare it to be so.
  def size
    4
  end

  def nan?
    `isNaN(self)`
  end

  def finite?
    `self != Infinity && self != -Infinity && !isNaN(self)`
  end

  def infinite?
    %x{
      if (self == Infinity) {
        return +1;
      }
      else if (self == -Infinity) {
        return -1;
      }
      else {
        return nil;
      }
    }
  end

  def positive?
    `self != 0 && (self == Infinity || 1 / self > 0)`
  end

  def negative?
    `self == -Infinity || 1 / self < 0`
  end
end

Fixnum = Number

class Integer < Numeric
  `self.$$is_number_class = true`

  class << self
    def allocate
      raise TypeError, "allocator undefined for #{self.name}"
    end

    undef :new

    def ===(other)
      %x{
        if (!other.$$is_number) {
          return false;
        }

        return (other % 1) === 0;
      }
    end
  end

  MAX = `Math.pow(2, 30) - 1`
  MIN = `-Math.pow(2, 30)`
end

class Float < Numeric
  `self.$$is_number_class = true`

  class << self
    def allocate
      raise TypeError, "allocator undefined for #{self.name}"
    end

    undef :new

    def ===(other)
      `!!other.$$is_number`
    end
  end

  INFINITY = `Infinity`
  MAX      = `Number.MAX_VALUE`
  MIN      = `Number.MIN_VALUE`
  NAN      = `NaN`

  DIG      = 15
  MANT_DIG = 53
  RADIX    = 2

  EPSILON = `Number.EPSILON || 2.2204460492503130808472633361816E-16`
end
