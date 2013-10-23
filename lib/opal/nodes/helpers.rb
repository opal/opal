module Opal
  module Nodes
    module Helpers

      # Reserved javascript keywords - we cannot create variables with the
      # same name
      RESERVED = %w[
        break case catch continue debugger default delete do else finally for
        function if in instanceof new return switch this throw try typeof var let
        void while with class enum export extends import super true false native
        const static
      ]

      def property(name)
        reserved?(name) ? "['#{name}']" : ".#{name}"
      end

      def reserved?(name)
        RESERVED.include? name
      end

      def variable(name)
        reserved?(name.to_s) ? "#{name}$" : name
      end

      # Converts a ruby lvar/arg name to a js identifier. Not all ruby names
      # are valid in javascript. A $ suffix is added to non-valid names.
      # varibales
      def lvar_to_js(var)
        var = "#{var}$" if RESERVED.include? var.to_s
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
          [fragment("(#{tmp} = "), expr(sexp), fragment(") !== false && #{tmp} !== nil")]
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
          [fragment("(#{tmp} = "), expr(sexp), fragment(") === false || #{tmp} === nil")]
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
