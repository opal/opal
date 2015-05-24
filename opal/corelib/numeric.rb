require 'corelib/comparable'
require 'corelib/string'

module Opal

  # Sets the maxium and minum value that is stored in an Integer.
  # Values below or above are converted to Bignums
  MIN_INTEGER = -9007199254740991
  MAX_INTEGER = 9007199254740991 
end

class Numeric
  include Comparable

  `def.$$is_number = true`

  def __id__
    `(self * 2) + 1`
  end
  alias object_id __id__

  def coerce(other, type = :operation)
    %x{
      if (other.$$is_number) {
        return [self, other];
      }
      else {
        return #{other.coerce(self)};
      }
    }
  rescue => e
    case type
    when :operation
      raise TypeError, "#{other.class} can't be coerced into Numeric"

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
      if (other.$$is_number) {
        return self + other;
      }
      else {
        return #{send_coerced :+, other};
      }
    }
  end

  def -(other)
    %x{
      if (other.$$is_number) {
        return self - other;
      }
      else {
        return #{send_coerced :-, other};
      }
    }
  end

  def *(other)
    %x{
      if (other.$$is_number) {
        return self * other;
      }
      else {
        return #{send_coerced :*, other};
      }
    }
  end

  def /(other)
    %x{
      if (other.$$is_number) {
        return self / other;
      }
      else {
        return #{send_coerced :/, other};
      }
    }
  end

  def %(other)
    %x{
      if (other.$$is_number) {
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
      if (other.$$is_number) {
        return self & other;
      }
      else {
        return #{send_coerced :&, other};
      }
    }
  end

  def |(other)
    %x{
      if (other.$$is_number) {
        return self | other;
      }
      else {
        return #{send_coerced :|, other};
      }
    }
  end

  def ^(other)
    %x{
      if (other.$$is_number) {
        return self ^ other;
      }
      else {
        return #{send_coerced :^, other};
      }
    }
  end

  def <(other)
    %x{
      if (other.$$is_number) {
        return self < other;
      }
      else {
        return #{send_coerced :<, other};
      }
    }
  end

  def <=(other)
    %x{
      if (other.$$is_number) {
        return self <= other;
      }
      else {
        return #{send_coerced :<=, other};
      }
    }
  end

  def >(other)
    %x{
      if (other.$$is_number) {
        return self > other;
      }
      else {
        return #{send_coerced :>, other};
      }
    }
  end

  def >=(other)
    %x{
      if (other.$$is_number) {
        return self >= other;
      }
      else {
        return #{send_coerced :>=, other};
      }
    }
  end

  def <=>(other)
    %x{
      if (other.$$is_number) {
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
    count = Opal.coerce_to! count, Integer, :to_int

    `#{count} > 0 ? self << #{count} : self >> -#{count}`
  end

  def >>(count)
    count = Opal.coerce_to! count, Integer, :to_int

    `#{count} > 0 ? self >> #{count} : self << -#{count}`
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
      if (other.$$is_number) {
        var result =  Math.pow(self, other);
        if(result > #{Opal::MAX_INTEGER} || result < #{Opal::MIN_INTEGER}) {
          var bignum = #{Bignum.new}
          bignum.value = new forge.jsbn.BigInteger(this.toString(), 10);
          return #{`bignum` ** `other`};
        }
        return result;
      }
      else {
        return #{send_coerced :**, other};
      }
    }
  end

  def ==(other)
    %x{
      if (other.$$is_number) {
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

  def ceil
    `Math.ceil(self)`
  end

  def chr(encoding=undefined)
    `String.fromCharCode(self)`
  end

  def conj
    self
  end

  alias conjugate conj

  def downto(finish, &block)
    return enum_for :downto, finish unless block

    %x{
      if (!finish.$$is_number) {
        #{raise ArgumentError, "comparison of #{self.class} with #{finish.class} failed"}
      }
      for (var i = self; i >= finish; i--) {
        if (block(i) === $breaker) {
          return $breaker.$v;
        }
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
    `'Numeric:'+self.toString()`
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

  def round(ndigits=0)
    %x{
      var scale = Math.pow(10, ndigits);
      return Math.round(self * scale) / scale;
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
      if (!finish.$$is_number) {
        #{raise ArgumentError, "comparison of #{self.class} with #{finish.class} failed"}
      }
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

Fixnum = Numeric

class Integer < Numeric
  def self.===(other)
    return true if other.instance_of? Bignum
    %x{
      if (!other.$$is_number) {
        return false;
      }

      return (other % 1) === 0;
    }
  end
end

class Float < Numeric
  def self.===(other)
    `!!other.$$is_number`
  end

  INFINITY = `Infinity`
  NAN      = `NaN`

  if defined?(`Number.EPSILON`)
    EPSILON = `Number.EPSILON`
  else
    EPSILON = `2.2204460492503130808472633361816E-16`
  end
end

