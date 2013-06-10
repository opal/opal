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
    `#{self} % other`
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
    `other != null && other._isNumber && #{self} == Number(other)`
  end

  def <=>(other)
    %x{
      if (typeof(other) !== 'number') {
        return null;
      }

      return #{self} < other ? -1 : (#{self} > other ? 1 : 0);
    }
  end

  def abs
    `Math.abs(#{self})`
  end

  def as_json
    self
  end

  def ceil
    `Math.ceil(#{self})`
  end

  def chr
    `String.fromCharCode(#{self})`
  end

  def downto(finish, &block)
    %x{
      for (var i = #{self}; i >= finish; i--) {
        if (block(i) === __breaker) {
          return __breaker.$v;
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
    `#{self} === 0 ? null : #{self}`
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

  alias succ next

  def times(&block)
    %x{
      for (var i = 0; i < #{self}; i++) {
        if (block(i) === __breaker) {
          return __breaker.$v;
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

  def to_json
    `#{self}.toString()`
  end

  def to_s(base = 10)
    `#{self}.toString()`
  end

  def to_n
    self
  end

  def upto(finish, &block)
    return enum_for :upto, finish unless block_given?

    %x{
      for (var i = #{self}; i <= finish; i++) {
        if (block(i) === __breaker) {
          return __breaker.$v;
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
