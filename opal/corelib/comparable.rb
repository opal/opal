# helpers: falsy

module Comparable
  %x{
    function normalize(what) {
      if (Opal.is_a(what, Opal.Integer)) { return what; }

      if (#{`what` > 0}) { return 1; }
      if (#{`what` < 0}) { return -1; }
      return 0;
    }

    function fail_comparison(lhs, rhs) {
      var class_name;
      #{
        case `rhs`
        when nil, true, false, Integer, Float
          `class_name = rhs.$inspect()`
        else
          `class_name = rhs.$$class`
        end
      }
      #{raise ArgumentError, "comparison of #{`lhs`.class} with #{`class_name`} failed"}
    }

    function cmp_or_fail(lhs, rhs) {
      var cmp = #{`lhs` <=> `rhs`};
      if ($falsy(cmp)) fail_comparison(lhs, rhs);
      return normalize(cmp);
    }
  }

  def ==(other)
    return true if equal?(other)

    %x{
      if (self["$<=>"] == Opal.Kernel["$<=>"]) {
        return false;
      }

      // check for infinite recursion
      if (self.$$comparable) {
        delete self.$$comparable;
        return false;
      }
    }

    return false unless cmp = (self <=> other)

    `normalize(cmp) == 0`
  end

  def >(other)
    `cmp_or_fail(self, other) > 0`
  end

  def >=(other)
    `cmp_or_fail(self, other) >= 0`
  end

  def <(other)
    `cmp_or_fail(self, other) < 0`
  end

  def <=(other)
    `cmp_or_fail(self, other) <= 0`
  end

  def between?(min, max)
    return false if self < min
    return false if self > max
    true
  end

  def clamp(min, max = nil)
    %x{
      var c, excl;

      if (max === nil) {
        // We are dealing with a new Ruby 2.7 behaviour that we are able to
        // provide a single Range argument instead of 2 Comparables.

        if (!Opal.is_a(min, Opal.Range)) {
          #{raise TypeError, "wrong argument type #{min.class} (expected Range)"}
        }

        excl = min.excl;
        max = min.end;
        min = min.begin;

        if (max !== nil && excl) {
          #{raise ArgumentError, 'cannot clamp with an exclusive range'}
        }
      }

      if (min !== nil && max !== nil && cmp_or_fail(min, max) > 0) {
        #{raise ArgumentError, 'min argument must be smaller than max argument'}
      }

      if (min !== nil) {
        c = cmp_or_fail(self, min);

        if (c == 0) return self;
        if (c < 0) return min;
      }

      if (max !== nil) {
        c = cmp_or_fail(self, max);

        if (c > 0) return max;
      }

      return self;
    }
  end
end
