class Range
  def begin
    `self.begin`
  end

  def end
    `self.end`
  end

  alias_method :first, :begin
  alias_method :min, :begin

  alias_method :last, :end
  alias_method :max, :end

  def initialize(min, max, exclude = false)
    @begin   = `self.begin   = min`
    @end     = `self.end     = max`
    @exclude = `self.exclude = exclude`
  end

  # FIXME: currently hardcoded to assume range holds numerics
  def ===(obj)
    `return obj >= self.begin && obj <= self.end`
  end

  def exclude_end?
    `self.exclude`
  end

  def to_s
    `self.begin + (self.exclude ? '...' : '..') + self.end`
  end

  def inspect
    `self.begin + (self.exclude ? '...' : '..') + self.end`
  end
end
