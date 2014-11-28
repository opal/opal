module Opal
  # [Opal::Sexp] is used to build up the syntax tree inside [Opal::Parser]. The
  # compiler then steps through the sexp trees to generate the javascript code.
  #
  # For example, an array of integers `[1, 2]` might be represented by:
  #
  #     s(:array, s(:int, 1), s(:int, 2))
  #
  class Sexp

    attr_reader :array

    attr_accessor :source

    def initialize(args)
      @array = args
    end

    def type
      @array[0]
    end

    def type=(type)
      @array[0] = type
    end

    def children
      @array[1..-1]
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

    def line
      @source && @source[0]
    end

    def column
      @source && @source[1]
    end

    def inspect
      "(#{@array.map { |e| e.inspect }.join ', '})"
    end

    def pretty_inspect
      "(#{line ? "#{line} " : ''}#{@array.map { |e| e.inspect }.join ', '})"
    end

    alias to_s inspect
  end
end
