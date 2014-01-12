require 'corelib/numeric'

# FIXME: find a way to bridge with a different superclass
class Number # < Numeric
  # temporary until inheritance is fixed
  include Comparable

  def real?; true; end
  # ----------

  `def._isNumber = true`

  def coerce(other, type = :operation)
    %x{
      if (other._isNumber) {
        return [self, other];
      }
      else {
        return #{other.coerce(self)};
      }
    }
  rescue
    case type
    when :operation
      raise TypeError, "#{other.class} can't be coerce into Numeric"

    when :comparison
      raise ArgumentError, "comparison of #{self.class} with #{other.class} failed"
    end
  end

  def send_coerced(method, other)
    type = case method
      when :+, :-, :*, :/, :%, :&, :|, :^, :**
        :operation

      when :>, :>=, :<, :<=, :<=>
        :comparison
    end

    a, b = coerce(other, type)
    a.__send__ method, b
  end

  def +(other)
    %x{
      if (other._isNumber) {
        return self + other;
      }
      else {
        return #{send_coerced :+, other};
      }
    }
  end

  def -(other)
    %x{
      if (other._isNumber) {
        return self - other;
      }
      else {
        return #{send_coerced :-, other};
      }
    }
  end

  def *(other)
    %x{
      if (other._isNumber) {
        return self * other;
      }
      else {
        return #{send_coerced :*, other};
      }
    }
  end

  def /(other)
    %x{
      if (other._isNumber) {
        return self / other;
      }
      else {
        return #{send_coerced :/, other};
      }
    }
  end

  def %(other)
    %x{
      if (other._isNumber) {
        if (other < 0 || self < 0) {
          return (self % other + other) % other;
        }
        else {
          return self % other;
        }
      }
      else {
        return #{send_coerced :%, other};
      }
    }
  end

  def &(other)
    %x{
      if (other._isNumber) {
        return self & other;
      }
      else {
        return #{send_coerced :&, other};
      }
    }
  end

  def |(other)
    %x{
      if (other._isNumber) {
        return self | other;
      }
      else {
        return #{send_coerced :|, other};
      }
    }
  end

  def ^(other)
    %x{
      if (other._isNumber) {
        return self ^ other;
      }
      else {
        return #{send_coerced :^, other};
      }
    }
  end

  def <(other)
    %x{
      if (other._isNumber) {
        return self < other;
      }
      else {
        return #{send_coerced :<, other};
      }
    }
  end

  def <=(other)
    %x{
      if (other._isNumber) {
        return self <= other;
      }
      else {
        return #{send_coerced :<=, other};
      }
    }
  end

  def >(other)
    %x{
      if (other._isNumber) {
        return self > other;
      }
      else {
        return #{send_coerced :>, other};
      }
    }
  end

  def >=(other)
    %x{
      if (other._isNumber) {
        return self >= other;
      }
      else {
        return #{send_coerced :>=, other};
      }
    }
  end

  def <=>(other)
    %x{
      if (other._isNumber) {
        return self > other ? 1 : (self < other ? -1 : 0);
      }
      else {
        return #{send_coerced :<=>, other};
      }
    }
  rescue ArgumentError
    nil
  end

  def <<(count)
    `self << #{count.to_int}`
  end

  def >>(count)
    `self >> #{count.to_int}`
  end

  def [](bit)
    bit = Opal.coerce_to! bit, Integer, :to_int
    min = -(2**30)
    max =  (2**30) - 1

    `(#{bit} < #{min} || #{bit} > #{max}) ? 0 : (self >> #{bit}) % 2`
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
      if (other._isNumber) {
        return Math.pow(self, other);
      }
      else {
        return #{send_coerced :**, other};
      }
    }
  end

  def ==(other)
    %x{
      if (other._isNumber) {
        return self == Number(other);
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
    `self * self`
  end

  def angle
    `self < 0 ? Math.PI : 0`
  end

  alias arg angle

  def ceil
    `Math.ceil(self)`
  end

  def chr(encoding = undefined)
    `String.fromCharCode(self)`
  end

  def downto(finish, &block)
    return enum_for :downto, finish unless block

    %x{
      for (var i = self; i >= finish; i--) {
        if (block(i) === $breaker) {
          return $breaker.$v;
        }
      }
    }

    self
  end

  alias eql? ==
  alias equal? ==

  def even?
    `self % 2 === 0`
  end

  def floor
    `Math.floor(self)`
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

  def hash
    `self.toString()`
  end

  def integer?
    `self % 1 === 0`
  end

  def is_a?(klass)
    return true if klass == Numeric
    # ^ FIXME: temporary hack

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

  def nonzero?
    `self == 0 ? nil : self`
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

  def round(digits = undefined)
    %x{
      if (digits == undefined)  {
        return Math.round(self);
      }
      else {
        return Math.round(self * Math.pow(10, digits)) / Math.pow(10, digits)
      }
    }
  end

  def step(limit, step = 1, &block)
    return enum_for :step, limit, step unless block

    raise ArgumentError, 'step cannot be 0' if `step == 0`

    %x{
      var value = self;

      if (step > 0) {
        while (value <= limit) {
          block(value);
          value += step;
        }
      }
      else {
        while (value >= limit) {
          block(value);
          value += step;
        }
      }
    }

    self
  end

  alias succ next

  def times(&block)
    return enum_for :times unless block

    %x{
      for (var i = 0; i < self; i++) {
        if (block(i) === $breaker) {
          return $breaker.$v;
        }
      }
    }

    self
  end

  def to_f
    self
  end

  def to_i
    `parseInt(self)`
  end

  alias to_int to_i

  def to_s(base = 10)
    if base < 2 || base > 36
      raise ArgumentError, 'base must be between 2 and 36'
    end

    `self.toString(base)`
  end

  alias inspect to_s

  def divmod(rhs)
    q = (self / rhs).floor
    r = self % rhs

    [q, r]
  end

  def upto(finish, &block)
    return enum_for :upto, finish unless block

    %x{
      for (var i = self; i <= finish; i++) {
        if (block(i) === $breaker) {
          return $breaker.$v;
        }
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
    `1 / self > 0`
  end

  def negative?
    `1 / self < 0`
  end
end

Fixnum = Number

class Integer < Numeric
  def self.===(other)
    %x{
      if (!other._isNumber) {
        return false;
      }

      return (other % 1) === 0;
    }
  end
end

class Float < Numeric
  def self.===(other)
    `!!other._isNumber`
  end

  INFINITY = `Infinity`
  NAN      = `NaN`

  if defined?(`Number.EPSILON`)
    EPSILON = `Number.EPSILON`
  else
    EPSILON = `2.2204460492503130808472633361816E-16`
  end
end
