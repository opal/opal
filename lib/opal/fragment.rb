module Opal
  # A fragment holds a string of generated javascript that will be written
  # to the destination. It also keeps hold of the original sexp from which
  # it was generated. Using this sexp, when writing fragments in order, a
  # mapping can be created of the original location => target location,
  # aka, source-maps!
  class Fragment
    # String of javascript this fragment holds
    attr_reader :code

    def initialize(code, sexp = nil)
      @code = code.to_s
      @sexp = sexp
    end

    # In debug mode we may wish to include the original line as a comment
    def to_code
      if @sexp
        "/*:#{@sexp.line}:#{@sexp.column}*/#{@code}"
      else
        @code
      end
    end

    # debug:
    # alias code to_code

    # inspect the contents of this fragment, f("fooo")
    def inspect
      "f(#{@code.inspect})"
    end

    def line
      @sexp.line if @sexp
    end
  end
end
