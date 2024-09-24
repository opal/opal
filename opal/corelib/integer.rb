# helpers: truthy
# backtick_javascript: true
# use_strict: true

require 'corelib/numeric'

class Integer < ::Numeric
  ::Opal.bridge(`BigInt`, self)
  `Opal.prop(self.$$prototype, '$$is_number', true)`
  `Opal.prop(self.$$prototype, '$$is_integer', true)`
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

    def try_convert(object)
      Opal.coerce_to?(object, self, :to_int)
    end
  end

  def __id__
    # Binary-safe integers
    `(self * 2n) + 1n`
  end

  alias hash __id__

  def +(other)
    %x{
      if (other.$$is_integer)
        return self + other;
      else if (other.$$is_float)
        return self + BigInt(other);
      else
        return #{__coerced__ :+, other};
    }
  end

  def -(other)
    %x{
      if (other.$$is_integer)
        return self - other;
      else
        return #{__coerced__ :-, other};
    }
  end

  def *(other)
    %x{
      if (other.$$is_integer)
        return self * other;
      else
        return #{__coerced__ :*, other};
    }
  end

  def /(other)
    %x{
      if (other.$$is_integer) {
        if (other === 0n)
          #{::Kernel.raise ::ZeroDivisionError, 'divided by 0'};

        if (self < 0 !== other < 0) // different signs
          return BigInt(Math.floor(Number(self) / Number(other)))
        else if (other.$$is_float)
          return Number(self) / other
        else
          return self / other;
      } else if (other === 0) {
        #{::Kernel.raise ::ZeroDivisionError, 'divided by 0'};
      } else {
        return #{__coerced__ :/, other};
      }
    }
  end

  def %(other)
    %x{
      if (other.$$is_integer) {
        if (other == -Infinity)
          return other;
        else if (other == 0)
          #{::Kernel.raise ::ZeroDivisionError, 'divided by 0'};
        else if (other < 0 || self < 0)
          return (self % other + other) % other;
        else
          return self % other;
      }
      else
        return #{__coerced__ :%, other};
    }
  end

  def &(other)
    %x{
      if (other.$$is_integer)
        return self & other;
      else
        return #{__coerced__ :&, other};
    }
  end

  def |(other)
    %x{
      if (other.$$is_integer)
        return self | other;
      else
        return #{__coerced__ :|, other};
    }
  end

  def ^(other)
    %x{
      if (other.$$is_integer)
        return self ^ other;
      else
        return #{__coerced__ :^, other};
    }
  end

  def <(other)
    %x{
      if (other.$$is_integer)
        return self < other;
      else
        return #{__coerced__ :<, other};
    }
  end

  def <=(other)
    %x{
      if (other.$$is_integer) {
        return self <= other;
      }
      else {
        return #{__coerced__ :<=, other};
      }
    }
  end

  def >(other)
    %x{
      if (other.$$is_integer) {
        return self > other;
      }
      else {
        return #{__coerced__ :>, other};
      }
    }
  end

  def >=(other)
    %x{
      if (other.$$is_integer) {
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
      if (other.$$is_integer) {
        if (isNaN(Number(self)) || isNaN(Number(other))) {
          return nil;
        }

        if (self > other) {
          return 1n;
        } else if (self < other) {
          return -1n;
        } else {
          return 0n;
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
      if (#{bit} < 0n) {
        return 0n;
      }
      if (#{bit} >= 32n) {
        return #{ self } < 0n ? 1n : 0n;
      }
      return (self >> #{bit}) & 1n;
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
    %x{
      if (other === 0n) return 1n;
      if (other === 1n) return self;

      if (Number.isInteger(Number(other))) {
        if (other > 0) {
          if (other > Number.MAX_SAFE_INTEGER) {
            #{::Kernel.warn("in a**b, b may be too big")}
          }
          return self ** other
        } else {
          return #{::Rational.new(self, 1) ** other}
        }
      } else if (self < 0 && $truthy(#{::Float === other || ::Rational === other})) {
        return #{ ::Complex.new(self.to_f, 0) ** other.to_f}
      } else if (other.$$is_float) {
        return self ** BigInt(other);
      } else {
        return #{__coerced__ :**, other}
      }
    }
  end

  def ==(other)
    %x{
      if (other.$$is_integer)
        return self.valueOf() === other.valueOf();
      else if (other.$$is_float)
        return Number(self) === other.valueOf();
      else if (#{other.respond_to? :==})
        return #{other == self};
      else
        return false;
    }
  end

  alias === ==

  def abs
    `Math.abs(Number(self))`
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
    `(self & mask) !== 0n`
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

  def bit_length
    %x{
      if (self === 0n || self === -1n) {
        return 0n;
      }

      var result = 0n,
          value  = self < 0n ? ~self : self;

      while (value != 0n) {
        result += 1n;
        value >>= 1n;
      }

      return result;
    }
  end

  def ceil(ndigits = 0)
    %x{
      if (ndigits >= 0)
        return self

      if (ndigits < 0) ndigits = -ndigits

      let factor = 10n ** ndigits

      if (self > 0)
        return (self + factor - 1n) / factor * factor
      else
        return self / factor * factor
    }
  end

  def chr(encoding = undefined)
    `Opal.enc(String.fromCharCode(Number(self)), encoding || "BINARY")`
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
        ::Kernel.raise ::ArgumentError, "comparison of #{self.class} with #{stop.class} failed" unless ::Numeric === stop
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

  def equal?(other)
    self == other || `isNaN(self) && isNaN(other)`
  end

  def even?
    `self % 2 === 0`
  end

  def floor(ndigits = 0)
    %x{
      var f = Number(self);
      if (ndigits >= 0) return self

      var factor = Math.pow(10, Number(ndigits)),
          result = Math.floor(f * factor) / factor;

      return BigInt(Math.round(result));
    }
  end

  def gcd(other)
    unless ::Integer === other
      ::Kernel.raise ::TypeError, 'not an integer'
    end

    %x{
      var min = #{abs},
          max = Math.abs(Number(other));

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

  def next
    `self + 1n`
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
      f     = ::Math.ldexp(f, ::Float::MANT_DIG).to_i
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
    %x{
      if (ndigits == null) return self;

      if (ndigits.$$is_float && $truthy(#{ndigits.infinite?}))
        #{::Kernel.raise ::RangeError, "Infinity"}

      if (!ndigits.$$is_integer)
        ndigits = #{::Opal.coerce_to!(ndigits, ::Integer, :to_int)}

      // Check if the number is beyond a signed int (32 bits)
      if (ndigits >= -(1 << 31) || ndigits <= (1 << 31) - 1)
        #{::Kernel.raise ::RangeError, "bignum too big to convert into 'long'"}

      if (ndigits >= 0) return self

      ndigits = -Number(ndigits)


      if (0.415241 * ndigits - 0.125 > #{size}) {
        return 0;
      }

      var f = Math.pow(10, ndigits),
          x = BigInt(Math.floor((#{abs} + f / 2) / f) * f);

      return self < 0 ? -x : x;
    }
  end

  def times(&block)
    return enum_for(:times) { self } unless block

    %x{
      for (var i = 0n; i < self; i++)
        block(i)
    }

    self
  end

  def to_f
    `Number(self)`
  end

  def to_i
    self
  end

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
    ::Kernel.raise ::ArgumentError, "invalid radix #{base}" if base < 2 || base > 36
    `self.toString(Number(base))`
  end

  def truncate(ndigits = 0)
    %x{
      ndigits = Number(ndigits);

      var f = #{to_f};

      if (f % 1 === 0 && ndigits >= 0) {
        return f;
      }

      var factor = Math.pow(10, ndigits),
          result = parseInt(f * factor, 10) / factor;

      if (f % 1 === 0) {
        result = Math.round(result);
      }

      return BigInt(result);
    }
  end

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
        ::Kernel.raise ::ArgumentError, "comparison of #{self.class} with #{stop.class} failed" unless ::Numeric === stop
        stop < self ? 0 : stop - self + 1
      end
    end

    %x{
      if (!stop.$$is_number)
        #{::Kernel.raise ::ArgumentError, "comparison of #{self.class} with #{stop.class} failed"}

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
    false
  end

  def finite?
    `self != Infinity && self != -Infinity`
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

  %x{
    function numberToUint8Array(num) {
      var uint8array = new Uint8Array(8);
      new DataView(uint8array.buffer).setFloat64(0, num, true);
      return uint8array;
    }

    function uint8ArrayToNumber(arr) {
      return new DataView(arr.buffer).getFloat64(0, true);
    }

    function incrementNumberBit(num) {
      var arr = numberToUint8Array(num);
      for (var i = 0; i < arr.length; i++) {
        if (arr[i] === 0xff) {
          arr[i] = 0;
        } else {
          arr[i]++;
          break;
        }
      }
      return uint8ArrayToNumber(arr);
    }

    function decrementNumberBit(num) {
      var arr = numberToUint8Array(num);
      for (var i = 0; i < arr.length; i++) {
        if (arr[i] === 0) {
          arr[i] = 0xff;
        } else {
          arr[i]--;
          break;
        }
      }
      return uint8ArrayToNumber(arr);
    }
  }

  def next_float
    return ::Float::INFINITY if self == ::Float::INFINITY
    return ::Float::NAN if nan?

    if self >= 0
      # Math.abs() is needed to handle -0.0
      `incrementNumberBit(Math.abs(self))`
    else
      `decrementNumberBit(self)`
    end
  end

  def prev_float
    return -::Float::INFINITY if self == -::Float::INFINITY
    return ::Float::NAN if nan?

    if self > 0
      `decrementNumberBit(self)`
    else
      `-incrementNumberBit(Math.abs(self))`
    end
  end

  alias arg angle
  alias eql? ==
  alias fdiv / #
  alias div / #
  alias inspect to_s
  alias kind_of? is_a?
  alias magnitude abs
  alias modulo %
  alias object_id __id__
  alias phase angle
  alias succ next
  alias to_int to_i
end
