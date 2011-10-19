class Numeric
  def self.allocate
    raise RuntimeError, 'cannot instantiate instance of Numeric class'
  end

  def + (other)
    `self + other`
  end

  def +@
    `+self`
  end

  def - (other)
    `self - other`
  end

  def -@
    `-self`
  end

  def * (other)
    `self * other`
  end

  def / (other)
    `self / other`
  end

  def ** (other)
    `Math.pow(self, other)`
  end

  def == (other)
    `self.valueOf() === other.valueOf()`
  end

  def < (other)
    `self < other`
  end

  def <= (other)
    `self <= other`
  end

  def > (other)
    `self > other`
  end

  def >= (other)
    `self >= other`
  end

  def % (other)
    `self % other`
  end

  alias_method :modulo, :%

  def & (other)
    `self & other`
  end

  def | (other)
    `self | other`
  end

  def ~
    `~self`
  end

  def ^ (other)
    `self ^ other`
  end

  def << (count)
    `self << count`
  end

  def >> (count)
    `self >> count`
  end

  def <=> (other)
    `
      if (typeof other != 'number') {
        return nil;
      }
      else if (self < other) {
        return -1;
      }
      else if (self > other) {
        return 1;
      }
      else {
        return 0;
      }
    `
  end

  def abs
    `Math.abs(self)`
  end

  def magnitude
    `Math.abs(self)`
  end

  def even?
    `self % 2 == 0`
  end

  def odd?
    `self % 2 != 0`
  end

  def succ
    `self + 1`
  end

  alias_method :next, :succ

  def pred
    `self - 1`
  end

  def upto (finish)
    return enum_for :upto, finish unless block_given?

    `
      for (var i = self; i <= finish; i++) {
        #{yield `i`};
      }
    `

    self
  end

  def downto (finish)
    return enum_for :downto, finish unless block_given?

    `
      for (var i = self; i >= finish; i--) {
        #{yield `i`};
      }
    `

    self
  end

  def times
    return enum_for :times unless block_given?

    `
      for (var i = 0; i < self; i++) {
        #{yield `i`};
      }
    `

    self
  end

  def zero?
    `self == 0;`
  end

  def nonzero?
    `self == 0 ? nil : self`
  end

  def ceil
    `Math.ceil(self);`
  end

  def floor
    `Math.floor(self)`
  end

  def integer?
    `self % 1 == 0`
  end

  def to_s
    `self.toString()`
  end

  def to_i
    Integer.from_native(`parseInt(self)`)
  end

  def to_f
    Float.from_native(`parseFloat(self)`)
  end
end

class Integer < Numeric
  def self.=== (other)
    raise ArgumentError, 'the passed value is not a number' unless Class.typeof(other) == 'number'

    other.integer?
  end
end

class Float < Numeric
  def self.=== (other)
    raise ArgumentError, 'the passed value is not a number' unless Class.typeof(other) == 'number'

    !other.integer?
  end
end
