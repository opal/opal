module Opal
  class Sexp < Array
    attr_accessor :line, :end_line

    def initialize *parts
      push *parts
      @line = 0
      @end_line = 0
    end

    def inspect
      "s(#{map { |x| x.inspect }.join ', ' })"
    end

    alias_method :to_s, :inspect
  end
end
