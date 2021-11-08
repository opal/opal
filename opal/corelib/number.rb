require 'corelib/numeric'

class Number < Numeric
  ::Opal.bridge(`Number`, self)
  `Opal.prop(self.$$prototype, '$$is_number', true)`
  `self.$$is_number_class = true`

  class << self
    def allocate
      ::Kernel.raise ::TypeError, "allocator undefined for #{name}"
    end

    undef :new
  end

  def coerce(other)
    %x{
      if (other === nil) {
        #{::Kernel.raise ::TypeError, "can't convert #{other.class} into Float"};
      }
      else if (other.$$is_string) {
        return [#{::Kernel.Float(other)}, self];
      }
      else if (#{other.respond_to?(:to_f)}) {
        return [#{::Opal.coerce_to!(other, ::Float, :to_f)}, self];
      }
      else if (other.$$is_number) {
        return [other, self];
      }
      else {
        #{::Kernel.raise ::TypeError, "can't convert #{other.class} into Float"};
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
          #{::Kernel.raise ::ZeroDivisionError, 'divided by 0'};
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
    `spaceship_operator(self, other)`
  rescue ::ArgumentError
    nil
  end

  def <<(count)
    count = ::Opal.coerce_to! count, ::Integer, :to_int

    `#{count} > 0 ? self << #{count} : self >> -#{count}`
  end

  def >>(count)
    count = ::Opal.coerce_to! count, ::Integer, :to_int

    `#{count} > 0 ? self >> #{count} : self << -#{count}`
  end

  def [](bit)
    bit = ::Opal.coerce_to! bit, ::Integer, :to_int

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
    if ::Integer === other
      if !(::Integer === self) || other > 0
        `Math.pow(self, other)`
      else
        ::Rational.new(self, 1)**other
      end
    elsif self < 0 && (::Float === other || ::Rational === other)
      ::Complex.new(self, 0)**other.to_f
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
    mask = ::Opal.coerce_to! mask, ::Integer, :to_int
    `(self & mask) == mask`
  end

  def anybits?(mask)
    mask = ::Opal.coerce_to! mask, ::Integer, :to_int
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
    unless ::Integer === self
      ::Kernel.raise ::NoMethodError.new("undefined method `bit_length` for #{self}:Float", 'bit_length')
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
    `Opal.enc(String.fromCharCode(self), encoding || "BINARY")`
  end

  def denominator
    if nan? || infinite?
      1
    else
      super
    end
  end

  def downto(stop, &block)
    unless block_given?
      return enum_for(:downto, stop) do
        ::Kernel.raise ::ArgumentError, "comparison of #{self.class} with #{stop.class} failed" unless Numeric === stop
        stop > self ? 0 : self - stop + 1
      end
    end

    %x{
      if (!stop.$$is_number) {
        #{::Kernel.raise ::ArgumentError, "comparison of #{self.class} with #{stop.class} failed"}
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
    unless ::Integer === other
      ::Kernel.raise ::TypeError, 'not an integer'
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
    [gcd(other), lcm(other)]
  end

  def integer?
    `self % 1 === 0`
  end

  def is_a?(klass)
    return true if klass == ::Integer && ::Integer === self
    return true if klass == ::Integer && ::Integer === self
    return true if klass == ::Float && ::Float === self

    super
  end

  alias kind_of? is_a?

  def instance_of?(klass)
    return true if klass == ::Integer && ::Integer === self
    return true if klass == ::Integer && ::Integer === self
    return true if klass == ::Float && ::Float === self

    super
  end

  def lcm(other)
    unless ::Integer === other
      ::Kernel.raise ::TypeError, 'not an integer'
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
    mask = ::Opal.coerce_to! mask, ::Integer, :to_int
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

  def pow(b, m = undefined)
    %x{
      if (self == 0) {
        #{::Kernel.raise ::ZeroDivisionError, 'divided by 0'}
      }

      if (m === undefined) {
        return #{self**b};
      } else {
        if (!(#{::Integer === b})) {
          #{::Kernel.raise ::TypeError, 'Integer#pow() 2nd argument not allowed unless a 1st argument is integer'}
        }

        if (b < 0) {
          #{::Kernel.raise ::TypeError, 'Integer#pow() 1st argument cannot be negative when 2nd argument specified'}
        }

        if (!(#{::Integer === m})) {
          #{::Kernel.raise ::TypeError, 'Integer#pow() 2nd argument not allowed unless all arguments are integers'}
        }

        if (m === 0) {
          #{::Kernel.raise ::ZeroDivisionError, 'divided by 0'}
        }

        return #{(self**b) % m}
      }
    }
  end

  def pred
    `self - 1`
  end

  def quo(other)
    if ::Integer === self
      super
    else
      self / other
    end
  end

  def rationalize(eps = undefined)
    %x{
      if (arguments.length > 1) {
        #{::Kernel.raise ::ArgumentError, "wrong number of arguments (#{`arguments.length`} for 0..1)"};
      }
    }

    if ::Integer === self
      ::Rational.new(self, 1)
    elsif infinite?
      ::Kernel.raise ::FloatDomainError, 'Infinity'
    elsif nan?
      ::Kernel.raise ::FloatDomainError, 'NaN'
    elsif `eps == null`
      f, n  = ::Math.frexp self
      f     = ::Math.ldexp(f, Float::MANT_DIG).to_i
      n    -= ::Float::MANT_DIG

      ::Rational.new(2 * f, 1 << (1 - n)).rationalize(::Rational.new(1, 1 << (1 - n)))
    else
      to_r.rationalize(eps)
    end
  end

  def remainder(y)
    self - y * (self / y).truncate
  end

  def round(ndigits = undefined)
    if ::Integer === self
      if `ndigits == null`
        return self
      end

      if ::Float === ndigits && ndigits.infinite?
        ::Kernel.raise ::RangeError, 'Infinity'
      end

      ndigits = ::Opal.coerce_to!(ndigits, ::Integer, :to_int)

      if ndigits < ::Integer::MIN
        ::Kernel.raise ::RangeError, 'out of bounds'
      end

      if `ndigits >= 0`
        return self
      end

      ndigits = -ndigits

      %x{
        if (0.415241 * ndigits - 0.125 > #{size}) {
          return 0;
        }

        var f = Math.pow(10, ndigits),
            x = Math.floor((Math.abs(self) + f / 2) / f) * f;

        return self < 0 ? -x : x;
      }
    else
      if nan? && `ndigits == null`
        ::Kernel.raise ::FloatDomainError, 'NaN'
      end

      ndigits = ::Opal.coerce_to!(`ndigits || 0`, ::Integer, :to_int)

      if ndigits <= 0
        if nan?
          ::Kernel.raise ::RangeError, 'NaN'
        elsif infinite?
          ::Kernel.raise ::FloatDomainError, 'Infinity'
        end
      elsif ndigits == 0
        return `Math.round(self)`
      elsif nan? || infinite?
        return self
      end

      _, exp = ::Math.frexp(self)

      if ndigits >= (::Float::DIG + 2) - (exp > 0 ? exp / 4 : exp / 3 - 1)
        return self
      end

      if ndigits < -(exp > 0 ? exp / 3 + 1 : exp / 4)
        return 0
      end

      `Math.round(self * Math.pow(10, ndigits)) / Math.pow(10, ndigits)`
    end
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
    `self < 0 ? Math.ceil(self) : Math.floor(self)`
  end

  alias to_int to_i

  def to_r
    if ::Integer === self
      ::Rational.new(self, 1)
    else
      f, e  = ::Math.frexp(self)
      f     = ::Math.ldexp(f, ::Float::MANT_DIG).to_i
      e    -= ::Float::MANT_DIG

      (f * (::Float::RADIX**e)).to_r
    end
  end

  def to_s(base = 10)
    base = ::Opal.coerce_to! base, ::Integer, :to_int

    if base < 2 || base > 36
      ::Kernel.raise ::ArgumentError, "invalid radix #{base}"
    end

    # Don't lose the negative zero
    if self == 0 && `1/self === -Infinity`
      return '-0.0'
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
      ::Kernel.raise ::Math::DomainError, 'out of domain'
    end

    base = ::Opal.coerce_to! base, ::Integer, :to_int

    if base < 2
      ::Kernel.raise ::ArgumentError, "invalid radix #{base}"
    end

    %x{
      if (self != parseInt(self)) #{::Kernel.raise ::NoMethodError, "undefined method `digits' for #{inspect}"}

      var value = self, result = [];

      if (self == 0) {
        return [0];
      }

      while (value != 0) {
        result.push(value % base);
        value = parseInt(value / base, 10);
      }

      return result;
    }
  end

  def divmod(other)
    if nan? || other.nan?
      ::Kernel.raise ::FloatDomainError, 'NaN'
    elsif infinite?
      ::Kernel.raise ::FloatDomainError, 'Infinity'
    else
      super
    end
  end

  def upto(stop, &block)
    unless block_given?
      return enum_for(:upto, stop) do
        ::Kernel.raise ::ArgumentError, "comparison of #{self.class} with #{stop.class} failed" unless Numeric === stop
        stop < self ? 0 : stop - self + 1
      end
    end

    %x{
      if (!stop.$$is_number) {
        #{::Kernel.raise ::ArgumentError, "comparison of #{self.class} with #{stop.class} failed"}
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
  `self.$$is_integer_class = true`

  class << self
    def allocate
      ::Kernel.raise ::TypeError, "allocator undefined for #{name}"
    end

    undef :new

    def sqrt(n)
      n = ::Opal.coerce_to!(n, ::Integer, :to_int)
      %x{
        if (n < 0) {
          #{::Kernel.raise ::Math::DomainError, 'Numerical argument is out of domain - "isqrt"'}
        }

        return parseInt(Math.sqrt(n), 10);
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
      ::Kernel.raise ::TypeError, "allocator undefined for #{name}"
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
