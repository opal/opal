class Range
  include Enumerable

  %x{
    Range.prototype._isRange = true;

    Opal.range = function(beg, end, exc) {
      var range         = new Range;
          range.begin   = beg;
          range.end     = end;
          range.exclude = exc;

      return range;
    };
  }

  attr_reader :begin
  attr_reader :end

  def initialize(min, max, exclude = false)
    @begin   = min
    @end     = max
    @exclude = exclude
  end

  def ==(other)
    %x{
      if (!other._isRange) {
        return false;
      }

      return #{self}.exclude === other.exclude && #{self}.begin == other.begin && #{self}.end == other.end;
    }
  end

  # FIXME: currently hardcoded to assume range holds numerics
  def ===(obj)
    `return obj >= #{self}.begin && (#{self}.exclude ? obj < #{self}.end : obj <= #{self}.end)`
  end

  def cover?(value)
    `#{self}.begin` <= value && value <= (exclude_end? ? `#{self}.end` - 1 : `#{self}.end`)
  end

  def each(&block)
    current = min

    while current != max
      yield current

      current = current.succ
    end

    yield current unless exclude_end?

    self
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
    raise NotImplementedError
  end

  def to_s
    `#{self}.begin + (#{self}.exclude ? '...' : '..') + #{self}.end`
  end

  alias inspect to_s
end