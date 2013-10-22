module Opal
  class Parser
    module NodeHelpers

      def property(name)
        reserved?(name) ? "['#{name}']" : ".#{name}"
      end

      def reserved?(name)
        Opal::Parser::RESERVED.include? name
      end

      def variable(name)
        reserved?(name) ? "#{name}$" : name
      end

      def indent(&block)
        @parser.indent(&block)
      end

      def current_indent
        @parser.parser_indent
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
          elsif Parser::COMPARE.include? mid.to_s
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
