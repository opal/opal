module Opal
  class Sexp

    attr_accessor :line
    attr_accessor :end_line
    attr_reader :array

    def initialize(args)
      @array = args
    end

    def method_missing(sym, *args, &block)
      @array.send sym, *args, &block
    end

    def <<(other)
      @array << other
      self
    end

    def push(*parts)
      @array.push(*parts)
      self
    end

    def to_ary
      @array
    end

    def dup
      Sexp.new(@array.dup)
    end

    def ==(other)
      if other.is_a? Sexp
        @array == other.array
      else
        @array == other
      end
    end

    alias eql? ==

    def inspect
      "s(#{@array.map { |e| e.inspect }.join ', '})"
    end

    alias to_s inspect
  end
end

