module SourceMap
  # Public: Offset is an immutable structure representing a position in
  # a source file.
  class Offset
    include Comparable

    # Public: Construct Offset value.
    #
    # Returns Offset instance.
    def self.new(*args)
      case args.first
      when Offset
        args.first
      when Array
        super(*args.first)
      else
        super(*args)
      end
    end

    # Public: Initialize an Offset.
    #
    # line   - Integer line number
    # column - Integer column number
    def initialize(line, column)
      @line, @column = line, column
    end

    # Public: Gets Integer line of offset
    attr_reader :line

    # Public: Get Integer column of offset
    attr_reader :column

    # Public: Shift the offset by some value.
    #
    # other - An Offset to add by its line and column
    #         Or an Integer to add by line
    #
    # Returns a new Offset instance.
    def +(other)
      case other
      when Offset
        Offset.new(self.line + other.line, self.column + other.column)
      when Integer
        Offset.new(self.line + other, self.column)
      else
        raise ArgumentError, "can't convert #{other} into #{self.class}"
      end
    end

    # Public: Compare Offset to another.
    #
    # Useful for determining if a position in a few is between two offsets.
    #
    # other - Another Offset
    #
    # Returns a negative number when other is smaller and a positive number
    # when its greater. Implements the Comparable#<=> protocol.
    def <=>(other)
      case other
      when Offset
        diff = self.line - other.line
        diff.zero? ? self.column - other.column : diff
      else
        raise ArgumentError, "can't convert #{other.class} into #{self.class}"
      end
    end

    # Public: Get a simple string representation of the offset
    #
    # Returns a String.
    def to_s
      if column == 0
        "#{line}"
      else
        "#{line}:#{column}"
      end
    end

    # Public: Get a pretty inspect output for debugging purposes.
    #
    # Returns a String.
    def inspect
      "#<#{self.class} line=#{line}, column=#{column}>"
    end
  end
end
