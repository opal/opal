class Numeric
  include Comparable

  `def._isNumber = true`

  def +(other)
    `#{self} + other`
  end

  def -(other)
    `#{self} - other`
  end

  def *(other)
    `#{self} * other`
  end

  def /(other)
    `#{self} / other`
  end

  def %(other)
    if other < 0 || self < 0
      `(#{self} % other + other) % other`
    else
      `#{self} % other`
    end
  end

  def &(other)
    `#{self} & other`
  end

  def |(other)
    `#{self} | other`
  end

  def ^(other)
    `#{self} ^ other`
  end

  def <(other)
    `#{self} < other`
  end

  def <=(other)
    `#{self} <= other`
  end

  def >(other)
    `#{self} > other`
  end

  def >=(other)
    `#{self} >= other`
  end

  def <<(count)
    `#{self} << count`
  end

  def >>(count)
    `#{self} >> count`
  end

  def +@
    `+#{self}`
  end

  def -@
    `-#{self}`
  end

  def ~
    `~#{self}`
  end

  def **(other)
    `Math.pow(#{self}, other)`
  end

  def ==(other)
    `!!(other._isNumber) && #{self} == Number(other)`
  end

  def <=>(other)
    %x{
      if (typeof(other) !== 'number') {
        return nil;
      }

      return #{self} < other ? -1 : (#{self} > other ? 1 : 0);
    }
  end

  def abs
    `Math.abs(#{self})`
  end

  def ceil
    `Math.ceil(#{self})`
  end

  def chr
    `String.fromCharCode(#{self})`
  end

  def conj
    self
  end

  alias conjugate conj

  def downto(finish, &block)
    %x{
      for (var i = #{self}; i >= finish; i--) {
        if (block(i) === $breaker) {
          return $breaker.$v;
        }
      }

      return #{self};
    }
  end

  alias eql? ==

  def even?
    `#{self} % 2 === 0`
  end

  def floor
    `Math.floor(#{self})`
  end

  def hash
    `#{self}.toString()`
  end

  def integer?
    `#{self} % 1 === 0`
  end

  alias magnitude abs

  alias modulo %

  def next
    `#{self} + 1`
  end

  def nonzero?
    `#{self} === 0 ? nil : #{self}`
  end

  def odd?
    `#{self} % 2 !== 0`
  end

  def ord
    self
  end

  def pred
    `#{self} - 1`
  end

  def step(limit, step = 1, &block)
    %x{
      var working = #{self};

      if (step > 0) {
        while (working <= limit) {
          block(working);
          working += step;
        }
      }
      else {
        while (working >= limit) {
          block(working);
          working += step;
        }
      }

      return #{self};
    }
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

    return `#{self}.toString(#{base})`
  end

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
end

Fixnum = Numeric

class Integer < Numeric
  def self.===(other)
    other.is_a?(Numeric) && `(other % 1) == 0`
  end
end

class Float < Numeric
  def self.===(other)
    other.is_a?(Numeric) && `(other % 1) != 0`
  end
end
