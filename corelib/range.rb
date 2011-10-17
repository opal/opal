class Range
  attr_reader :begin, :end

  alias_method :first, :begin
  alias_method :min, :begin

  alias_method :last, :end
  alias_method :max, :end

  def initialize (min, max, exclude = false)
    @begin   = min
    @end     = max
    @exclude = exclude
  end

  def exclude_end?
    @exclude
  end

  def to_s
    "#{min}#{exclude_end? ? '...' : '..'}#{max}"
  end

  def inspect
    "#{min.inspect}#{exclude_end? ? '...' : '..'}#{max.inspect}"
  end

  # FIXME: currently hardcoded to assume range holds numerics
  def ===(obj)
    `return obj >= #{@begin} && obj <= #{@end}`
  end
end

