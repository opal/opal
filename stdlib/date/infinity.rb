class Date
  class Infinity < Numeric
    include Comparable

    def initialize(d = 1)
      @d = d <=> 0
    end

    attr_reader :d

    def zero?
      false
    end

    def finite?
      false
    end

    def infinite?
      d.nonzero?
    end

    def nan?
      d.zero?
    end

    def abs
      self.class.new
    end

    def -@
      self.class.new(-d)
    end

    def +@
      self.class.new(+d)
    end

    def <=>(other)
      case other
      when Infinity
        d <=> other.d
      when Numeric
        d
      else
        begin
          l, r = other.coerce(self)
          l <=> r
        rescue NoMethodError
          nil
        end
      end
    end

    def coerce(other)
      case other
      when Numeric
        [-d, d]
      else
        super
      end
    end

    def to_f
      return 0 if @d == 0
      if @d > 0
        Float::INFINITY
      else
        -Float::INFINITY
      end
    end
  end
end