class Numeric
  include Comparable

  `def._isNumber = true`

  class << self
    undef_method :new
  end

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

      when :>, :>=, :<, :<=, :<=>, :==
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
      else {
        return #{send_coerced :==, other};
      }
    }
  rescue ArgumentError
    false
  end

  def abs
    `Math.abs(self)`
  end

  def ceil
    `Math.ceil(self)`
  end

  def chr
    `String.fromCharCode(self)`
  end

  def conj
    self
  end

  alias conjugate conj

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

  def even?
    `self % 2 === 0`
  end

  def floor
    `Math.floor(self)`
  end

  def hash
    `self.toString()`
  end

  def integer?
    `self % 1 === 0`
  end

  def is_a?(klass)
    return true if klass == Float && Float === self
    return true if klass == Integer && Integer === self

    super
  end

  alias magnitude abs

  alias modulo %

  def next
    `self + 1`
  end

  def nonzero?
    `self === 0 ? nil : self`
  end

  def odd?
    `self % 2 !== 0`
  end

  def ord
    self
  end

  def pred
    `#{self} - 1`
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
    %x{
      for (var i = 0; i < #{self}; i++) {
        if (block(i) === $breaker) {
          return $breaker.$v;
        }
      }

      return #{self};
    }
  end

  def to_f
    `parseFloat(#{self})`
  end

  def to_i
    `parseInt(#{self})`
  end

  alias to_int to_i

  def to_s(base = 10)
    if base < 2 || base > 36
      raise ArgumentError.new('base must be between 2 and 36')
    end

    `#{self}.toString(#{base})`
  end

  alias :inspect :to_s

  def divmod(rhs)
    q = (self / rhs).floor
    r = self % rhs

    [q, r]
  end

  def to_n
    `#{self}.valueOf()`
  end

  def upto(finish, &block)
    return enum_for :upto, finish unless block_given?

    %x{
      for (var i = #{self}; i <= finish; i++) {
        if (block(i) === $breaker) {
          return $breaker.$v;
        }
      }

      return #{self};
    }
  end

  def zero?
    `#{self} == 0`
  end

  def size
    # Just a stub, JS is 32bit for bitwise ops though
    4
  end

  def nan?
    `isNaN(self)`
  end

  def finite?
    `self == Infinity || self == -Infinity`
  end

  def infinite?
    if `self == Infinity`
      `+1`
    elsif `self == -Infinity`
      `-1`
    end
  end
end

Fixnum = Numeric

class Integer < Numeric
  def self.===(other)
    `other._isNumber && (other % 1) == 0`
  end
end

class Float < Numeric
  def self.===(other)
    `other._isNumber && (other % 1) != 0`
  end
end
