module Comparable
  def self.normalize(what)
    return what if Integer === what

    return  1 if what > 0
    return -1 if what < 0
    0
  end

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

    `#{Comparable.normalize(cmp)} == 0`
  rescue StandardError
    false
  end

  def >(other)
    unless cmp = (self <=> other)
      raise ArgumentError, "comparison of #{self.class} with #{other.class} failed"
    end

    `#{Comparable.normalize(cmp)} > 0`
  end

  def >=(other)
    unless cmp = (self <=> other)
      raise ArgumentError, "comparison of #{self.class} with #{other.class} failed"
    end

    `#{Comparable.normalize(cmp)} >= 0`
  end

  def <(other)
    unless cmp = (self <=> other)
      raise ArgumentError, "comparison of #{self.class} with #{other.class} failed"
    end

    `#{Comparable.normalize(cmp)} < 0`
  end

  def <=(other)
    unless cmp = (self <=> other)
      raise ArgumentError, "comparison of #{self.class} with #{other.class} failed"
    end

    `#{Comparable.normalize(cmp)} <= 0`
  end

  def between?(min, max)
    return false if self < min
    return false if self > max
    true
  end

  def clamp(min, max)
    cmp = min <=> max

    unless cmp
      raise ArgumentError, "comparison of #{min.class} with #{max.class} failed"
    end

    if Comparable.normalize(cmp) > 0
      raise ArgumentError, 'min argument must be smaller than max argument'
    end

    return min if Comparable.normalize(self <=> min) < 0
    return max if Comparable.normalize(self <=> max) > 0
    self
  end
end
