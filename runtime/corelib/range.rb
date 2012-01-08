class Range
  def begin
    `this.begin`
  end

  def end
    `this.end`
  end

  alias_method :first, :begin
  alias_method :min, :begin

  alias_method :last, :end
  alias_method :max, :end

  def initialize(min, max, exclude = false)
    @begin   = min
    @end     = max
    @exclude = exclude
  end

  # FIXME: currently hardcoded to assume range holds numerics
  def ===(obj)
    `return obj >= this.begin && obj <= this.end`
  end

  def exclude_end?
    `this.exclude`
  end

  def to_s
    `this.begin + (this.exclude ? '...' : '..') + this.end`
  end

  def inspect
    `this.begin + (this.exclude ? '...' : '..') + this.end`
  end
end
