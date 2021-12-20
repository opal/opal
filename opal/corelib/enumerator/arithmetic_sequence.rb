class ::Enumerator
  class self::ArithmeticSequence < self
    `Opal.prop(self.$$prototype, '$$is_arithmetic_seq', true)`

    `var inf = Infinity`

    # @private
    def initialize(range, step = undefined, creation_method = :step)
      @creation_method = creation_method
      if range.is_a? ::Array
        @step_arg1, @step_arg2, @topfx, @bypfx = *range
        @receiver_num = step
        @step = 1

        @range = if @step_arg2
                   @step = @step_arg2
                   (@receiver_num..@step_arg1)
                 elsif @step_arg1
                   (@receiver_num..@step_arg1)
                 else
                   (@receiver_num..nil)
                 end
      else
        @skipped_arg = true unless step
        @range, @step = range, step || 1
      end

      @object = self

      ::Kernel.raise ArgumentError, "step can't be 0" if @step == 0
      unless @step.respond_to? :to_int
        ::Kernel.raise ArgumentError, "no implicit conversion of #{@step.class} " \
                                      'into Integer'
      end
    end

    attr_reader :step

    def begin
      @range.begin
    end

    def end
      @range.end
    end

    def exclude_end?
      @range.exclude_end?
    end

    # @private
    def _lesser_than_end?(val)
      end_ = self.end || `inf`
      if step > 0
        exclude_end? ? val < end_ : val <= end_
      else
        exclude_end? ? val > end_ : val >= end_
      end
    end

    # @private
    def _greater_than_begin?(val)
      begin_ = self.begin || -`inf`
      if step > 0
        val > begin_
      else
        val < begin_
      end
    end

    def first(count = undefined)
      iter = self.begin || -`inf`

      return _lesser_than_end?(iter) ? iter : nil unless count

      out = []

      while _lesser_than_end?(iter) && count > 0
        out << iter
        iter += step
        count -= 1
      end

      out
    end

    def each(&block)
      return self unless block_given?

      case self.begin
      when nil
        ::Kernel.raise TypeError, "nil can't be coerced into Integer"
      end

      iter = self.begin || -`inf`

      while _lesser_than_end?(iter)
        yield iter
        iter += step
      end
      self
    end

    def last(count = undefined)
      case self.end
      when `inf`, -`inf`
        ::Kernel.raise ::FloatDomainError, self.end
      when nil
        ::Kernel.raise ::RangeError, 'cannot get the last element of endless arithmetic sequence'
      end

      iter = self.end - ((self.end - self.begin) % step)
      iter -= step unless _lesser_than_end?(iter)

      return _greater_than_begin?(iter) ? iter : nil unless count

      out = []

      while _greater_than_begin?(iter) && count > 0
        out << iter
        iter -= step
        count -= 1
      end

      out.reverse
    end

    def size
      step_sign = step > 0 ? 1 : -1

      if !_lesser_than_end?(self.begin)
        0
      elsif [-`inf`, `inf`].include?(step)
        1
      elsif [-`inf` * step_sign, nil].include?(self.begin) ||
            [`inf` * step_sign, nil].include?(self.end)
        `inf`
      else
        iter = self.end - ((self.end - self.begin) % step)
        iter -= step unless _lesser_than_end?(iter)
        ((iter - self.begin) / step).abs.to_i + 1
      end
    end

    def ==(other)
      self.class == other.class &&
        self.begin == other.begin &&
        self.end == other.end &&
        step == other.step &&
        exclude_end? == other.exclude_end?
    end

    def hash
      [self.begin, self.end, step, exclude_end?].hash
    end

    def inspect
      if @receiver_num
        args = if @step_arg2
                 "(#{@topfx}#{@step_arg1.inspect}, #{@bypfx}#{@step_arg2.inspect})"
               elsif @step_arg1
                 "(#{@topfx}#{@step_arg1.inspect})"
               end

        "(#{@receiver_num.inspect}.#{@creation_method}#{args})"
      else
        args = unless @skipped_arg
                 "(#{@step})"
               end
        "((#{@range.inspect}).#{@creation_method}#{args})"
      end
    end

    alias === ==
    alias eql? ==
  end
end
