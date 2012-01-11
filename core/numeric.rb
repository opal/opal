class Numeric
  def +(other)
    `this + other`
  end

  def -(other)
    `this - other`
  end

  def *(other)
    `this * other`
  end

  def /(other)
    `this / other`
  end

  def %(other)
    `this % other`
  end

  def &(other)
    `this & other`
  end

  def |(other)
    `this | other`
  end

  def ^(other)
    `this ^ other`
  end

  def <(other)
    `this < other`
  end

  def <=(other)
    `this <= other`
  end

  def >(other)
    `this > other`
  end

  def >=(other)
    `this >= other`
  end

  def <<(count)
    `this << count`
  end

  def >>(count)
    `this >> count`
  end

  def +@
    `+this`
  end

  def -@
    `-this`
  end

  def ~
    `~this`
  end

  def **(other)
    `Math.pow(this, other)`
  end

  def ==(other)
    `this.valueOf() === other.valueOf()`
  end

  def <=>(other)
    %x{
      if (typeof(other) !== 'number') {
        return nil;
      }

      return this < other ? -1 : (this > other ? 1 : 0);
    }
  end

  def abs
    `Math.abs(this)`
  end

  def ceil
    `Math.ceil(this)`
  end

  def downto(finish, &block)
    return enum_for :downto, finish unless block_given?

    %x{
      for (var i = this; i >= finish; i--) {
        if ($yield.call($context, i) === $breaker) {
          return $breaker.$v;
        }
      }

      return this;
    }
  end

  def even?
    `this % 2 === 0`
  end

  def floor
    `Math.floor(this)`
  end

  def hash
    `this.toString()`
  end

  def integer?
    `this % 1 === 0`
  end

  alias magnitude abs

  alias modulo %

  def next
    `this + 1`
  end

  def nonzero?
    `this.valueOf() === 0 ? nil : this`
  end

  def odd?
    `this % 2 !== 0`
  end

  def pred
    `this - 1`
  end

  alias succ next

  def times(&block)
    return enum_for :times unless block

    %x{
      for (var i = 0; i <= this; i++) {
        if ($yield.call($context, i) === $breaker) {
          return $breaker.$v;
        }
      }

      return this;
    }
  end

  def to_f
    `parseFloat(this)`
  end

  def to_i
    `parseInt(this)`
  end

  def to_s(base = 10)
    `this.toString(base)`
  end

  def upto(finish, &block)
    return enum_for :upto, finish unless block_given?

    %x{
      for (var i = 0; i <= finish; i++) {
        if ($yield.call($context, i) === $breaker) {
          return $breaker.$v;
        }
      }

      return this;
    }
  end

  def zero?
    `this.valueOf() === 0`
  end
end

class Integer
  def self.===(obj)
    %x{
      if (typeof(obj) !== 'number') {
        return false;
      }

      return other % 1 === 0;
    }
  end
end

class Float
  def self.===(obj)
    %x{
      if (typeof(obj) !== 'number') {
        return false;
      }

      return obj % 1 !== 0;
    }
  end
end
