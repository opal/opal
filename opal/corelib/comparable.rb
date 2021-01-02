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
    unless cmp = (self <=> other)
      `fail_comparison(self, other)`
    end

    `normalize(cmp) > 0`
  end

  def >=(other)
    unless cmp = (self <=> other)
      `fail_comparison(self, other)`
    end

    `normalize(cmp) >= 0`
  end

  def <(other)
    unless cmp = (self <=> other)
      `fail_comparison(self, other)`
    end

    `normalize(cmp) < 0`
  end

  def <=(other)
    unless cmp = (self <=> other)
      `fail_comparison(self, other)`
    end

    `normalize(cmp) <= 0`
  end

  def between?(min, max)
    return false if self < min
    return false if self > max
    true
  end

  def clamp(min, max=nil)
    if Range === min && max.nil?
      max = min.end
      max = Float::INFINITY if max.nil?
      min = min.begin
      min = -Float::INFINITY if min.nil?
    end

    cmp = min <=> max

    unless cmp
      `fail_comparison(min, max)`
    end

    if `normalize(cmp) > 0`
      raise ArgumentError, 'min argument must be smaller than max argument'
    end

    return min if `normalize(#{self <=> min}) < 0`
    return max if `normalize(#{self <=> max}) > 0`
    self
  end
end
