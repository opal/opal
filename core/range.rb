class Range
  include Enumerable

  %x{
    Range_prototype._isRange = true;

    Opal.range = function(beg, end, exc) {
      var range         = new Range;
          range.begin   = beg;
          range.end     = end;
          range.exclude = exc;

      return range;
    };
  }

  def initialize(min, max, exclude = false)
    @begin   = min
    @end     = max
    @exclude = exclude
  end

  def ==(other)
    return false unless Range === other

    exclude_end? == other.exclude_end? && `#{self}.begin` == other.begin && `#{self}.end` == other.end
  end

  # FIXME: currently hardcoded to assume range holds numerics
  def ===(obj)
    `return obj >= #{self}.begin && (#{self}.exclude ? obj < #{self}.end : obj <= #{self}.end)`
  end

  def begin
    `#{self}.begin`
  end

  def cover?(value)
    `#{self}.begin` <= value && value <= (exclude_end? ? `#{self}.end` - 1 : `#{self}.end`)
  end

  def each
    return enum_for :each unless block_given?

    current = min

    while current != max
      yield current

      current = current.succ
    end

    yield current unless exclude_end?

    self
  end

  def end
    `#{self}.end`
  end

  def eql?(other)
    return false unless Range === other

    exclude_end? == other.exclude_end? && `#{self}.begin`.eql?(other.begin) && `#{self}.end`.eql?(other.end)
  end

  def exclude_end?
    `#{self}.exclude`
  end

  # FIXME: currently hardcoded to assume range holds numerics
  def include?(val)
    `return obj >= #{self}.begin && obj <= #{self}.end`
  end

  alias max end

  alias min begin

  alias member? include?

  def step(n = 1)
    return enum_for :step, n unless block_given?

    raise NotImplementedError
  end

  def to_s
    `#{self}.begin + (#{self}.exclude ? '...' : '..') + #{self}.end`
  end

  def inspect
    `#{self}.begin + (#{self}.exclude ? '...' : '..') + #{self}.end`
  end
end