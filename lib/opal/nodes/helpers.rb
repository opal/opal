module Opal
  module Nodes
    module Helpers

      # Reserved javascript keywords - we cannot create variables with the
      # same name (ref: http://stackoverflow.com/a/9337272/601782)
      ES51_RESERVED_WORD = /^(?:do|if|in|for|let|new|try|var|case|else|enum|eval|false|null|this|true|void|with|break|catch|class|const|super|throw|while|yield|delete|export|import|public|return|static|switch|typeof|default|extends|finally|package|private|continue|debugger|function|arguments|interface|protected|implements|instanceof)$/

      # ES3 reserved words that aren’t ES5.1 reserved words
      ES3_RESERVED_WORD_EXCLUSIVE = /^(?:int|byte|char|goto|long|final|float|short|double|native|throws|boolean|abstract|volatile|transient|synchronized)$/

      # Immutable properties of the global object
      IMMUTABLE_PROPS = /^(?:NaN|Infinity|undefined)$/

      # Doesn't take in account utf8
      BASIC_IDENTIFIER_RULES = /^[$_a-z][$_a-z\d]*$/i


      def property(name)
        valid_name?(name) ? ".#{name}" : "[#{name.inspect}]"
      end

      def valid_name?(name)
        BASIC_IDENTIFIER_RULES =~ name and not(
          ES51_RESERVED_WORD          =~ name or
          ES3_RESERVED_WORD_EXCLUSIVE =~ name or
          IMMUTABLE_PROPS             =~ name
        )
      end

      def variable(name)
        valid_name?(name.to_s) ? name : "#{name}$"
      end

      # Converts a ruby lvar/arg name to a js identifier. Not all ruby names
      # are valid in javascript. A $ suffix is added to non-valid names.
      # varibales
      def lvar_to_js(var)
        var = "#{var}$" unless valid_name? var.to_s
        var.to_sym
      end

      # Converts a ruby method name into its javascript equivalent for
      # a method/function call. All ruby method names get prefixed with
      # a '$', and if the name is a valid javascript identifier, it will
      # have a '.' prefix (for dot-calling), otherwise it will be
      # wrapped in brackets to use reference notation calling.
      def mid_to_jsid(mid)
        if /\=|\+|\-|\*|\/|\!|\?|\<|\>|\&|\||\^|\%|\~|\[/ =~ mid.to_s
          "['$#{mid}']"
        else
          '.$' + mid
        end
      end

      def indent(&block)
        compiler.indent(&block)
      end

      def current_indent
        compiler.parser_indent
      end

      def line(*strs)
        push "\n#{current_indent}"
        push(*strs)
      end

      def empty_line
        push "\n"
      end

      def js_truthy(sexp)
        if optimize = js_truthy_optimize(sexp)
          return optimize
        end

        with_temp do |tmp|
          [fragment("((#{tmp} = "), expr(sexp), fragment(") !== nil && (!#{tmp}.$$is_boolean || #{tmp} == true))")]
        end
      end

      def js_falsy(sexp)
        if sexp.type == :call
          mid = sexp[2]
          if mid == :block_given?
            scope.uses_block!
            return "#{scope.block_name} === nil"
          end
        end

        with_temp do |tmp|
          [fragment("((#{tmp} = "), expr(sexp), fragment(") === nil || (#{tmp}.$$is_boolean && #{tmp} == false))")]
        end
      end

      def js_truthy_optimize(sexp)
        if sexp.type == :call
          mid = sexp[2]

          if mid == :block_given?
            expr(sexp)
          elsif Compiler::COMPARE.include? mid.to_s
            expr(sexp)
          elsif mid == :"=="
            expr(sexp)
          end
        elsif [:lvar, :self].include? sexp.type
          [expr(sexp.dup), fragment(" !== false && "), expr(sexp.dup), fragment(" !== nil")]
        end
      end
    end
  end
end
