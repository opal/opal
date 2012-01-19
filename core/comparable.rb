module Comparable
  def <(other)
    (self <=> other) == -1
  end

  def <=(other)
    (self <=> other) <= 0
  end

  def ==(other)
    (self <=> other) == 0
  end

  def >(other)
    (self <=> other) == 1
  end

  def >=(other)
    (self <=> other) >= 0
  end

  def between?(min, max)
    self > min && self < max
  end
end
