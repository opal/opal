class Range
  include Enumerable

  %x{
    Range._proto._isRange = true;

    Opal.range = function(first, last, exc) {
      var range         = new Range._alloc;
          range.begin   = first;
          range.end     = last;
          range.exclude = exc;

      return range;
    };
  }

  attr_reader :begin
  attr_reader :end

  def initialize(first, last, exclude = false)
    @begin   = first
    @end     = last
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
    include?(obj)
  end

  def cover?(value)
    `#{self}.begin` <= value && (`#{self}.exclude` ? value < `#{self}.end` : value <= `#{self}.end`)
  end

  def last
    self.end
  end

  def each(&block)
    return enum_for :each unless block_given?

    current = `#{self}.begin`

    last = `#{self}.end`
    while current < last
      yield current

      current = current.succ
    end

    yield current unless `#{self}.exclude`

    self
  end

  def eql?(other)
    return false unless Range === other

    `#{self}.exclude === other.exclude` && `#{self}.begin`.eql?(other.begin) && `#{self}.end`.eql?(other.end)
  end

  def exclude_end?
    `#{self}.exclude`
  end

  # FIXME: currently hardcoded to assume range holds numerics
  def include?(obj)
    cover?(obj)
  end

  # FIXME: currently hardcoded to assume range holds numerics
  def max
    if block_given?
      super
    else
      `#{self}.exclude ? #{self}.end - 1 : #{self}.end`
    end
  end

  def min
    if block_given?
      super
    else
      `#{self}.begin`
    end
  end

  alias member? include?

  def step(n = 1)
    raise NotImplementedError
  end

  def to_s
    `#{self.begin.inspect} + (#{self}.exclude ? '...' : '..') + #{self.end.inspect}`
  end

  alias inspect to_s
end
