# backtick_javascript: true
# special_symbols: prototype, is_range, is_number, is_string

require 'corelib/enumerable'

class ::Range
  include ::Enumerable

  `self[$$prototype][$$is_range] = true`

  attr_reader :begin, :end

  def initialize(first, last, exclude = false)
    ::Kernel.raise ::NameError, "'initialize' called twice" if @begin
    ::Kernel.raise ::ArgumentError, 'bad value for range' unless first <=> last || first.nil? || last.nil?

    @begin = first
    @end   = last
    @excl  = exclude
  end

  def ===(value)
    include? value
  end

  %x{
    function is_infinite(self) {
      if (self.begin === nil || self.end === nil ||
          self.begin === -Infinity || self.end === Infinity ||
          self.begin === Infinity || self.end === -Infinity) return true;
      return false;
    }
  }

  def count(&block)
    if !block_given? && `is_infinite(self)`
      return ::Float::INFINITY
    end
    super
  end

  def to_a
    ::Kernel.raise ::TypeError, 'cannot convert endless range to an array' if `is_infinite(self)`
    super
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

      if (#{@begin}[$$is_number] && #{@end}[$$is_number]) {
        if (#{@begin} % 1 !== 0 || #{@end} % 1 !== 0) {
          #{::Kernel.raise ::TypeError, "can't iterate from Float"}
        }

        for (i = #{@begin}, limit = #{@end} + #{@excl ? 0 : 1}; i < limit; i++) {
          block(i);
        }

        return self;
      }

      if (#{@begin}[$$is_string] && #{@end}[$$is_string]) {
        #{@begin.upto(@end, @excl, &block)}
        return self;
      }
    }

    current = @begin
    last    = @end

    unless current.respond_to?(:succ)
      ::Kernel.raise ::TypeError, "can't iterate from #{current.class}"
    end

    while @end.nil? || (current <=> last) < 0
      yield current

      current = current.succ
    end

    yield current if !@excl && current == last

    self
  end

  def eql?(other)
    return false unless ::Range === other

    @excl === other.exclude_end? &&
      @begin.eql?(other.begin) &&
      @end.eql?(other.end)
  end

  def exclude_end?
    @excl
  end

  def first(n = undefined)
    ::Kernel.raise ::RangeError, 'cannot get the minimum of beginless range' if @begin.nil?
    return @begin if `n == null`
    super
  end

  def last(n = undefined)
    ::Kernel.raise ::RangeError, 'cannot get the maximum of endless range' if @end.nil?
    return @end if `n == null`
    to_a.last(n)
  end

  # FIXME: currently hardcoded to assume range holds numerics
  def max
    if @end.nil?
      ::Kernel.raise ::RangeError, 'cannot get the maximum of endless range'
    elsif block_given?
      super
    elsif !@begin.nil? && (@begin > @end ||
                           @excl && @begin == @end)
      nil
    else
      `#{@excl} ? #{@end} - 1 : #{@end}`
    end
  end

  def min
    if @begin.nil?
      ::Kernel.raise ::RangeError, 'cannot get the minimum of beginless range'
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
    %x{
      var b = this.begin, e = this.end;

      // If begin is Numeric
      if (#{::Numeric === `b`}) {
        // If end is Numeric
        if (#{::Numeric === `e`}) {
          // Calculating size based on whether range is exclusive or inclusive
          var size = #{`e` - `b`};
          if (size < 0) {
            return 0;
          }
          if (!this.excl) {
            size += 1;
          }
          return (#{::Float === `b`} || #{::Float === `e`}) ? Math.floor(size) : size;
        }
        // If end is nil
        else if (e === nil) {
          return Infinity;
        }
      }
      // If begin is nil
      else if (b === nil) {
        // If end is Numeric
        if (#{::Numeric === `e`}) {
          return Infinity;
        }
      }

      // If neither begin nor end is Numeric
      return nil;
    }
  end

  def step(n = undefined)
    %x{
      function coerceStepSize() {
        if (n == null) {
          n = 1;
        }
        else if (!n[$$is_number]) {
          n = #{::Opal.coerce_to!(n, ::Integer, :to_int)}
        }

        if (n < 0) {
          #{::Kernel.raise ::ArgumentError, "step can't be negative"}
        } else if (n === 0) {
          #{::Kernel.raise ::ArgumentError, "step can't be 0"}
        }
      }

      function enumeratorSize() {
        if (!#{@begin.respond_to?(:succ)}) {
          return nil;
        }

        if (#{@begin}[$$is_string] && #{@end}[$$is_string]) {
          return nil;
        }

        if (n % 1 === 0) {
          return #{(size / n).ceil};
        } else {
          // n is a float
          var begin = self.begin, end = self.end,
              abs = Math.abs, floor = Math.floor,
              err = (abs(begin) + abs(end) + abs(end - begin)) / abs(n) * #{::Float::EPSILON},
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
      if (@begin.is_a?(Numeric) || @begin.nil?) &&
         (@end.is_a?(Numeric) || @end.nil?) &&
         !(@begin.nil? && @end.nil?)

        return ::Enumerator::ArithmeticSequence.new(self, n, :step)
      else
        return enum_for(:step, n) do
          %x{
            coerceStepSize();
            return enumeratorSize();
          }
        end
      end
    end

    `coerceStepSize()`

    if `self.begin[$$is_number] && self.end[$$is_number]`
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
        if (#{@begin}[$$is_string] && #{@end}[$$is_string] && n % 1 !== 0) {
          #{::Kernel.raise ::TypeError, 'no implicit conversion to float from string'}
        }
      }
      each_with_index do |value, idx|
        yield(value) if idx % n == 0
      end
    end
    self
  end

  def %(n)
    if @begin.is_a?(Numeric) && @end.is_a?(Numeric)
      ::Enumerator::ArithmeticSequence.new(self, n, :%)
    else
      step(n)
    end
  end

  def bsearch(&block)
    return enum_for(:bsearch) unless block_given?

    if `is_infinite(self) && (self.begin[$$is_number] || self.end[$$is_number])`
      ::Kernel.raise ::NotImplementedError, "Can't #bsearch an infinite range"
    end

    unless `self.begin[$$is_number] && self.end[$$is_number]`
      ::Kernel.raise ::TypeError, "can't do binary search for #{@begin.class}"
    end

    to_a.bsearch(&block)
  end

  def to_s
    "#{@begin || ''}#{@excl ? '...' : '..'}#{@end || ''}"
  end

  def inspect
    "#{@begin && @begin.inspect}#{@excl ? '...' : '..'}#{@end && @end.inspect}"
  end

  def marshal_load(args)
    @begin = args[:begin]
    @end = args[:end]
    @excl = args[:excl]
  end

  def hash
    [::Range, @begin, @end, @excl].hash
  end

  alias == eql?
  alias include? cover?
  alias member? cover?
end
