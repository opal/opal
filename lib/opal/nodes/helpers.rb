# frozen_string_literal: true

require 'opal/regexp_anchors'

module Opal
  module Nodes
    module Helpers
      def property(name)
        valid_name?(name) ? ".#{name}" : "[#{name.inspect}]"
      end

      def valid_name?(name)
        Opal::Rewriters::JsReservedWords.valid_name?(name)
      end

      # Converts a ruby method name into its javascript equivalent for
      # a method/function call. All ruby method names get prefixed with
      # a '$', and if the name is a valid javascript identifier, it will
      # have a '.' prefix (for dot-calling), otherwise it will be
      # wrapped in brackets to use reference notation calling.
      def mid_to_jsid(mid)
        if %r{\=|\+|\-|\*|\/|\!|\?|<|\>|\&|\||\^|\%|\~|\[} =~ mid.to_s
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
        push fragment("\n#{current_indent}", loc: false)
        push(*strs)
      end

      def empty_line
        push fragment("\n", loc: false)
      end

      def js_truthy(sexp)
        if optimize = js_truthy_optimize(sexp)
          return optimize
        end

        helper :truthy
        [fragment('$truthy('), expr(sexp), fragment(')')]
      end

      def js_falsy(sexp)
        if sexp.type == :send
          mid = sexp.children[1]
          if mid == :block_given?
            scope.uses_block!
            return "#{scope.block_name} === nil"
          end
        end

        helper :falsy
        [fragment('$falsy('), expr(sexp), fragment(')')]
      end

      def js_truthy_optimize(sexp)
        if sexp.type == :send
          mid = sexp.children[1]
          receiver_handler_class = (receiver = sexp.children[0]) && compiler.handlers[receiver.type]

          # Only operator calls on the truthy_optimize? node classes should be optimized.
          # Monkey patch method calls might return 'self'/aka a bridged instance and need
          # the nil check - see discussion at https://github.com/opal/opal/pull/1097
          allow_optimization_on_type = Compiler::COMPARE.include?(mid.to_s) &&
                                       receiver_handler_class &&
                                       receiver_handler_class.truthy_optimize?

          if allow_optimization_on_type ||
             mid == :block_given? ||
             mid == :"=="
            expr(sexp)
          end
        end
      end

      # Usefule for safe-operator calls: foo&.bar / foo&.bar ||= baz / ...
      #
      # @param recvr [sexp_pushable] The receiver of the call that will be
      #        stored in a temporary variable
      # @yields receiver_temp [String] the name of the temporary variable
      #         holding the ref to the original receiver, inside the block
      #         an expr() should be pushed.
      #
      def conditional_send(recvr)
        # temporary variable that stores method receiver
        receiver_temp = scope.new_temp
        push "#{receiver_temp} = ", recvr

        # execute the sexp only if the receiver isn't nil
        push ", (#{receiver_temp} === nil || #{receiver_temp} == null) ? nil : "
        yield receiver_temp
        wrap '(', ')'
      end
    end
  end
end
