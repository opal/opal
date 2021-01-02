require 'corelib/enumerable'

class Range
  include Enumerable

  `self.$$prototype.$$is_range = true`

  attr_reader :begin, :end

  def initialize(first, last, exclude = false)
    raise NameError, "'initialize' called twice" if @begin
    raise ArgumentError, 'bad value for range' unless first <=> last

    @begin = first
    @end   = last
    @excl  = exclude
  end

  def ===(value)
    include? value
  end

  def cover?(value)
    beg_cmp = (@begin.nil? && -1) || (@begin <=> value) || false
    end_cmp = (@end.nil? && -1) || (value <=> @end) || false
    if @excl
      end_cmp && end_cmp < 0
    else
      end_cmp && end_cmp <= 0
    end && beg_cmp && beg_cmp <= 0
  end

  def each(&block)
    return enum_for(:each) { size } unless block_given?

    %x{
      var i, limit;

      if (#{@begin}.$$is_number && #{@end}.$$is_number) {
        if (#{@begin} % 1 !== 0 || #{@end} % 1 !== 0) {
          #{raise TypeError, "can't iterate from Float"}
        }

        for (i = #{@begin}, limit = #{@end} + #{@excl ? 0 : 1}; i < limit; i++) {
          block(i);
        }

        return self;
      }

      if (#{@begin}.$$is_string && #{@end}.$$is_string) {
        #{@begin.upto(@end, @excl, &block)}
        return self;
      }
    }

    current = @begin
    last    = @end

    unless current.respond_to?(:succ)
      raise TypeError, "can't iterate from #{current.class}"
    end

    while @end.nil? || (current <=> last) < 0
      yield current

      current = current.succ
    end

    yield current if !@excl && current == last

    self
  end

  def eql?(other)
    return false unless Range === other

    @excl === other.exclude_end? &&
      @begin.eql?(other.begin) &&
      @end.eql?(other.end)
  end

  alias == eql?

  def exclude_end?
    @excl
  end

  def first(n = undefined)
    raise RangeError, 'cannot get the minimum of beginless range' if @begin.nil?
    return @begin if `n == null`
    super
  end

  alias include? cover?

  def last(n = undefined)
    raise RangeError, 'cannot get the maximum of endless range' if @end.nil?
    return @end if `n == null`
    to_a.last(n)
  end

  # FIXME: currently hardcoded to assume range holds numerics
  def max
    if @end.nil?
      raise RangeError, 'cannot get the maximum of endless range'
    elsif block_given?
      super
    elsif !@begin.nil? && (@begin > @end ||
                           @excl && @begin == @end)
      nil
    else
      `#{@excl} ? #{@end} - 1 : #{@end}`
    end
  end

  alias member? cover?

  def min
    if @begin.nil?
      raise RangeError, 'cannot get the minimum of beginless range'
    elsif block_given?
      super
    elsif !@end.nil? && (@begin > @end ||
                         @excl && @begin == @end)
      nil
    else
      @begin
    end
  end

  def size
    infinity = Float::INFINITY

    range_begin = @begin
    range_begin = -infinity if range_begin.nil?
    range_end   = @end
    range_end   = infinity if range_end.nil?
    range_end  -= 1 if @excl

    return nil unless Numeric === range_begin && Numeric === range_end
    return infinity if [-range_begin, range_end].include?(infinity)
    return 0 if range_end < range_begin

    `Math.abs(range_end - range_begin) + 1`.to_i
  end

  def step(n = 1)
    %x{
      function coerceStepSize() {
        if (!n.$$is_number) {
          n = #{Opal.coerce_to!(n, Integer, :to_int)}
        }

        if (n < 0) {
          #{raise ArgumentError, "step can't be negative"}
        } else if (n === 0) {
          #{raise ArgumentError, "step can't be 0"}
        }
      }

      function enumeratorSize() {
        if (!#{@begin.respond_to?(:succ)}) {
          return nil;
        }

        if (#{@begin}.$$is_string && #{@end}.$$is_string) {
          return nil;
        }

        if (n % 1 === 0) {
          return #{(size / n).ceil};
        } else {
          // n is a float
          var begin = self.begin, end = self.end,
              abs = Math.abs, floor = Math.floor,
              err = (abs(begin) + abs(end) + abs(end - begin)) / abs(n) * #{Float::EPSILON},
              size;

          if (err > 0.5) {
            err = 0.5;
          }

          if (self.excl) {
            size = floor((end - begin) / n - err);
            if (size * n + begin < end) {
              size++;
            }
          } else {
            size = floor((end - begin) / n + err) + 1
          }

          return size;
        }
      }
    }

    unless block_given?
      return enum_for(:step, n) do
        %x{
          coerceStepSize();
          return enumeratorSize();
        }
      end
    end

    `coerceStepSize()`

    if `self.begin.$$is_number && self.end.$$is_number`
      i = 0
      loop do
        current = @begin + i * n
        if @excl
          break if current >= @end
        elsif current > @end
          break
        end
        yield(current)
        i += 1
      end
    else
      %x{
        if (#{@begin}.$$is_string && #{@end}.$$is_string && n % 1 !== 0) {
          #{raise TypeError, 'no implicit conversion to float from string'}
        }
      }
      each_with_index do |value, idx|
        yield(value) if idx % n == 0
      end
    end
    self
  end

  def bsearch(&block)
    return enum_for(:bsearch) unless block_given?

    unless `self.begin.$$is_number && self.end.$$is_number`
      raise TypeError, "can't do binary search for #{@begin.class}"
    end

    to_a.bsearch(&block)
  end

  def to_s
    "#{@begin}#{@excl ? '...' : '..'}#{@end.nil? ? '' : @end}"
  end

  def inspect
    "#{@begin.inspect}#{@excl ? '...' : '..'}#{@end.nil? ? '' : @end.inspect}"
  end

  def marshal_load(args)
    @begin = args[:begin]
    @end = args[:end]
    @excl = args[:excl]
  end

  def hash
    [@begin, @end, @excl].hash
  end
end
