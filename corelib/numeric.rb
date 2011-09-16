# Numeric objects represent numbers in opal. Unlike ruby, this class is
# used to represent both floats and integers, and there is currently no
# class representing bignums. Numeric values may only be made using
# their literal representations:
#
#     1       # => 1
#     2.0     # => 2
#     0.05    # => 0.05
#
# Implementation details
# ----------------------
#
# Opal numbers are toll-free bridged to native javascript numbers so
# that anywhere a ruby number is expected, a native javascript number
# may be used in its place. Javascript only has a single class/prototype
# to represent numbers, meaning that all integers and floats contain the
# same prototype. For this reason, Opal follows suit and implements all
# numbers as a direct instance of {Numeric}.
#
# Floats and Integers could be truley represented using wrappers, but
# this would **dramatically** increase performance overhead at the very
# core parts of the opal runtime. This overhead is too great, and the
# benefits would be too few.
#
# Ruby compatibility
# ------------------
#
# As discussed, {Numeric} is the only class used to represent numbers in
# opal. Most of the useful methods from `Fixnum`, `Integer` and `Float`
# are implemented on this class.
#
# It is also important to note that there is no distinguishment between
# floats and integers, so that, `1` and `1.0` are exactly equal.
#
# Custom subclasses of Numeric may be used so that a numeric literal is
# passed in. This differs from the ruby approach of number inheritance,
# but does allow for certain circumstances where a subclass of number
# might be useful. Opal does not try to implement `Integer` or `Float`
# for these purposes, but it is easily done. This approach will still
# not allow for literals to be used to make these subclass instances.
class Numeric

  def +(other)
    `return self + other;`
  end

  def -(other)
    `return self - other;`
  end

  def *(other)
    `return self * other;`
  end

  def /(other)
    `return self / other;`
  end

  def ==(other)
    `return self.valueOf() === other.valueOf();`
  end

  def <(other)
    `return self < other;`
  end

  def <=(other)
    `return self <= other;`
  end

  def >(other)
    `return self > other;`
  end

  def >=(other)
    `return self >= other;`
  end

  # Returns `self` modulo `other`. See `divmod` for more information.
  #
  # @param [Numeric] other number to use for module
  # @return [Numeric] result
  def %(other)
    `return self % other;`
  end

  def modulo(other)
    `return self % other;`
  end

  # Bitwise AND.
  #
  # @param [Numeric] other numeric to AND with
  # @return [Numeric]
  def &(num2)
    `return self & num2;`
  end

  # Raises `self` to the power of `other`.
  #
  # @param [Numeric] other number to raise to
  # @return [Numeric]
  def **(other)
    `return Math.pow(self, other);`
  end

  # Shift `self` left by `count` positions.
  #
  # @param [Numeric] count number to shift
  # @return [Numeric]
  def <<(count)
    `return self << count;`
  end

  # Shifts 'self' right by `count` positions.
  #
  # @param [Numeric] count number to shift
  # @return [Numeric]
  def >>(count)
    `return self >> count;`
  end

  # Comparison - Returns '-1', '0', '1' or nil depending on whether `self` is
  # less than, equal to or greater than `other`.
  #
  # @param [Numeric] other number to compare with
  # @return [Number, nil]
  def <=>(other)
    `if (typeof other != 'number') return nil;
    else if (self < other) return -1;
    else if (self > other) return 1;
    return 0;`
  end

  # Bitwise EXCLUSIVE OR.
  #
  # @param [Numeric] other number to XOR with
  # @return [Numeric]
  def ^(other)
    `return self ^ other;`
  end

  # Returns the absolute value of `self`.
  #
  # @example
  #
  #     -1234.abs
  #     # => 1234
  #     1234.abs
  #     # => 1234
  #
  # @return [Numeric]
  def abs
    `return Math.abs(self);`
  end

  def magnitude
    `return Math.abs(self);`
  end

  # Returns `true` if self is even, `false` otherwise.
  #
  # @return [true, false]
  def even?
    `return (self % 2 == 0);`
  end

  # Returns `true` if self is odd, `false` otherwise.
  #
  # @return [true, false]
  def odd?
    `return (self % 2 == 0) ? false : true;`
  end

  # Returns the number equal to `self` + 1.
  #
  # @example
  #
  #     1.next
  #     # => 2
  #     (-1).next
  #     # => 0
  #
  # @return [Numeric]
  def succ
    `return self + 1;`
  end

  def next
    `return self + 1;`
  end

  # Returns the number equal to `self` - 1
  #
  # @example
  #
  #     1.pred
  #     # => 0
  #     (-1).pred
  #     # => -2
  #
  # @return [Numeric]
  def pred
    `return self - 1;`
  end

  # Iterates the block, passing integer values from `self` upto and including
  # `finish`.
  #
  # @example
  #
  #     5.upto(10) { |i| puts i }
  #     # => 5
  #     # => 6
  #     # => 7
  #     # => 8
  #     # => 9
  #     # => 10
  #
  # @param [Numeric] finish where to stop iteration
  # @return [Numeric] returns the receiver
  def upto(finish)
    `for (var i = self; i <= finish; i++) {
      #{yield `i`};
    }

    return self;`
  end

  # Iterates the block, passing decreasing values from `self` downto and
  # including `finish`.
  #
  # @example
  #
  #     5.downto(1) { |x| puts x }
  #     # => 5
  #     # => 4
  #     # => 3
  #     # => 2
  #     # => 1
  #
  # @param [Numeric] finish where to stop iteration
  # @return [Numeric] returns the receiver
  def downto(finish)
    `for (var i = self; i >= finish; i--) {
      #{yield `i`};
    }

    return self;`
  end

  # Iterates the block `self` number of times, passing values in the range 0 to
  # `self` - 1.
  #
  # @example
  #
  #     5.times { |x| puts x }
  #     # => 0
  #     # => 1
  #     # => 2
  #     # => 3
  #     # => 4
  #
  # @return [Numeric] returns the receiver
  def times
    raise "no block given" unless block_given?
    `for (var i = 0; i < self; i++) {
      #{yield `i`};
    }

    return self;`
  end

  # Bitwise OR.
  #
  # @param [Numeric] other number to OR with
  # @return [Numeric]
  def |(other)
    `return self | other;`
  end

  # Returns `true` if `self` is zero, `false` otherwise.
  #
  # @return [true, false]
  def zero?
    `return self == 0;`
  end

  # Returns the receiver if it is not zero, `nil` otherwise
  #
  # @return [Numeric, nil]
  def nonzero?
    `return self == 0 ? nil : self;`
  end

  # One's complement: returns a number where each bit is flipped.
  #
  # @return [Numeric]
  def ~
    `return ~self;`
  end

  # Returns the smallest integer greater than or equal to `num`.
  #
  # @example
  #
  #     1.ceil        # => 1
  #     1.2.ceil      # => 2
  #     (-1.2).ceil   # => -1
  #     (-1.0).ceil   # => -1
  #
  # @return [Numeric]
  def ceil
    `return Math.ceil(self);`
  end

  # Returns the largest integer less than or equal to `self`.
  #
  # @example
  #
  #     1.floor       # => 1
  #     (-1).floor    # => -1
  #
  # @return [Numeric]
  def floor
    `return Math.floor(self);`
  end

  # Returns `true` if self is an ineteger, `false` otherwise.
  #
  # @return [true, false]
  def integer?
    `return self % 1 == 0;`
  end

  def inspect
    `return self.toString();`
  end

  def to_s
    `return self.toString();`
  end

  def to_i
    `return parseInt(self);`
  end

  def self.allocate
    raise RuntimeError, "cannot instantiate instance of Numeric class"
  end
end

