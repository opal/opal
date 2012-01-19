# Helper function on runtime for creating range literals
%x{
  $opal.range = function(beg, end, exc) {
    var range         = new RubyRange.$allocator();
        range.begin   = beg;
        range.end     = end;
        range.exclude = exc;

    return range;
  };
}

class Range
  include Enumerable

  def initialize(min, max, exclude = false)
    @begin   = min
    @end     = max
    @exclude = exclude
  end

  def ==(other)
    return false unless Range === other

    exclude_end? == other.exclude_end? && `this.begin` == other.begin && `this.end` == other.end
  end

  # FIXME: currently hardcoded to assume range holds numerics
  def ===(obj)
    `return obj >= this.begin && obj <= this.end`
  end

  def begin
    `this.begin`
  end

  def cover?(value)
    `this.begin` <= value && value <= (exclude_end? ? `this.end` - 1 : `this.end`)
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
    `this.end`
  end

  def eql?(other)
    return false unless Range === other

    exclude_end? == other.exclude_end? && `this.begin`.eql?(other.begin) && `this.end`.eql?(other.end)
  end

  def exclude_end?
    `this.exclude`
  end

  # FIXME: currently hardcoded to assume range holds numerics
  def include?(val)
    `return obj >= this.begin && obj <= this.end`
  end

  def max
    if block_given?
      # I actually don't get what this should do
      raise NotImplementedError
    else
      `this.end`
    end
  end

  def min
    if block_given?
      # I actually don't get what this should do
      raise NotImplementedError
    else
      `this.begin`
    end
  end

  alias member? include?

  def step(n = 1)
    return enum_for :step, n unless block_given?

    raise NotImplementedError
  end

  def to_s
    `this.begin + (this.exclude ? '...' : '..') + this.end`
  end

  def inspect
    `this.begin + (this.exclude ? '...' : '..') + this.end`
  end
end
