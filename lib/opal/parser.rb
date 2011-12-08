require 'ruby_parser'

require 'opal/parser/processor'
require 'opal/parser/scope'

module Opal

  class OpalParseError < Exception
    attr_accessor :opal_file, :opal_line
  end

  class Parser

    RUNTIME_HELPERS = {
      "nil"     => "nil",  # nil literal
      "$super"  => "S",     # function to call super
      "$breaker"=> "B",     # break value literal
      "$noproc" => "P",     # proc to yield when no block (throws error)
      "$class"  => "k",     # define classes, modules, shiftclasses.
      "$defn"   => "m",     # define normal method
      "$defs"   => "M",     # singleton define method
      "$const"  => "cg",    # const_get
      "$range"  => "G",     # new range instance
      "$hash"   => "H",     # new hash instance
      "$slice"  => "as"     # exposes Array.prototype.slice (for splats)
    }

    def parse(source, file = "(file)")
      @file    = "__OPAL_LIB_FILE_STRING"

      begin
        parser = RubyParser.new
        reset
        code = top parser.parse(source, @file)
      rescue => e
        line = parser.lexer.lineno
        msg = "#{e.message} in `#{file}' on line #{line}"
        exc = OpalParseError.new msg
        exc.opal_file = file
        exc.opal_line = line
        raise exc
      end

      code
    end

    ##
    # Wrap with runtime helpers etc as well

    def wrap_with_runtime_helpers js
      code = "(function(VM) { var "
      code += RUNTIME_HELPERS.to_a.map { |a| a.join ' = VM.' }.join ', '
      code += ";\n#{js};\n})(opal.runtime)"
    end

    ##
    # Special wrap for core

    def wrap_core_with_runtime_helpers js
      code = "function(top, FILE) { var "
      code += RUNTIME_HELPERS.to_a.map { |a| a.join ' = VM.' }.join ', '
      code += ";\nvar code = #{js};\nreturn code(top, FILE);}"
    end

    ##
    # Reset the parser for a new file.

    def reset file = nil
      @file     = file

      @indent   = ''
      @unique   = 0
      @symbols  = {}
      @sym_id   = 0
    end
  end
end
