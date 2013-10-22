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
        if js_truthy_optimize(sexp)
          return
        end

        with_temp do |tmp|
          push "(#{tmp} = ", expr(sexp), ") !== false && #{tmp} !== nil"
        end
      end

      def js_falsy(sexp)
        if sexp.type == :call
          mid = sexp[2]
          if mid == :block_given?
            push(*@parser.handle_block_given(sexp, true))
            return
          end
        end

        with_temp do |tmp|
          push "(#{tmp} = ", expr(sexp), ") === false || #{tmp} === nil"
        end
      end

      def js_truthy_optimize(sexp)
        if sexp.type == :call
          mid = sexp[2]

          if mid == :block_given?
            push expr(sexp)
            true
          elsif Parser::COMPARE.include? mid.to_s
            push expr(sexp)
            true
          elsif mid == :"=="
            push expr(sexp)
            true
          end
        elsif [:lvar, :self].include? sexp.type
          push expr(sexp.dup), " !== false && ", expr(sexp.dup), " !== nil"
          true
        end
      end
    end
  end
end
