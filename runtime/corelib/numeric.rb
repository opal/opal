class Numeric
  def +(other)
    `self + other`
  end

  def -(other)
    `self - other`
  end

  def *(other)
    `self * other`
  end

  def /(other)
    `self / other`
  end

  def %(other)
    `self % other`
  end

  def &(other)
    `self & other`
  end

  def |(other)
    `self | other`
  end

  def ^(other)
    `self ^ other`
  end

  def <(other)
    `self < other`
  end

  def <=(other)
    `self <= other`
  end

  def >(other)
    `self > other`
  end

  def >=(other)
    `self >= other`
  end

  def <<(count)
    `self << count`
  end

  def >>(count)
    `self >> count`
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
    `Math.pow(self, other)`
  end

  def ==(other)
    `self.valueOf() === other.valueOf()`
  end

  def <=>(other)
    `
      if (typeof other !== 'number') {
        return nil;
      }

      return self < other ? -1 : (self > other ? 1 : 0);
    `
  end

  def abs
    `Math.abs(self)`
  end

  def ceil
    `Math.ceil(self)`
  end

  def downto(finish, &block)
    return enum_for :downto, finish unless block_given?

    `
      for (var i = self; i >= finish; i--) {
        if ($yielder.call($context, null, i) === $breaker) {
          return $breaker.$v;
        }
      }

      return self;
    `
  end

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

  alias_method :magnitude, :abs

  alias_method :modulo, :%

  def next
    `self + 1`
  end

  def nonzero?
    `self.valueOf() === 0 ? nil : self`
  end

  def odd?
    `self % 2 !== 0`
  end

  def pred
    `self - 1`
  end

  alias_method :succ, :next

  def times(&block)
    return enum_for :times unless block

    `
      for (var i = 0; i <= self; i++) {
        if ($yielder.call($context, null, i) === $breaker) {
          return $breaker.$v;
        }
      }

      return self;
    `
  end

  def to_f
    `parseFloat(self)`
  end

  def to_i
    `parseInt(self)`
  end

  def to_s
    `self.toString()`
  end

  def upto(finish, &block)
    return enum_for :upto, finish unless block_given?
    `
      for (var i = 0; i <= finish; i++) {
        if ($yielder.call($context, null, i) === $breaker) {
          return $breaker.$v;
        }
      }

      return self;
    `
  end

  def zero?
    `self.valueOf() === 0`
  end
end

class Integer
  def self.===(obj)
    `
      if (typeof obj !== 'number') {
        return false;
      }

      return other % 1 === 0;
    `
  end
end

class Float
  def self.===(obj)
    `
      if (typeof obj !== 'number') {
        return false;
      }

      return obj % 1 !== 0;
    `
  end
end
