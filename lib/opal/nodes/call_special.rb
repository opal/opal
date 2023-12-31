# frozen_string_literal: true

require 'opal/nodes/base'
require 'opal/nodes/call'

module Opal
  module Nodes
    # recvr.JS[:prop]
    # => recvr.prop
    class JsAttrNode < Base
      handle :jsattr
      children :recvr, :property

      def compile
        push recv(recvr), '[', expr(property), ']'
      end
    end

    # recvr.JS[:prop] = value
    # => recvr.prop = value
    class JsAttrAsgnNode < Base
      handle :jsattrasgn

      children :recvr, :property, :value

      def compile
        push recv(recvr), '[', expr(property), '] = ', expr(value)
      end
    end

    class JsCallNode < CallNode
      handle :jscall

      def initialize(*)
        super

        # For .JS. call we pass a block
        # as a plain JS callback
        if @iter
          @arglist <<= @iter
        end
        @iter = nil
      end

      def compile
        default_compile
      end

      def method_jsid
        ".#{meth}"
      end

      def compile_using_send
        push recv(receiver_sexp), method_jsid, '.apply(null'
        compile_arguments
        if iter
          push '.concat(', expr(iter), ')'
        end
        push ')'
      end
    end

    # Handles match_with_lvasgn nodes which represent matching a regular expression
    # with a right-hand side value and assigning the match result to a left-hand side variable.
    class Match3Node < Base
      handle :match_with_lvasgn

      children :lhs, :rhs

      def compile
        sexp = s(:send, lhs, :=~, rhs)

        # Handle named matches like: /(?<abc>b)/ =~ 'b'
        if lhs.type == :regexp && lhs.children.first.type == :str
          names = extract_names(lhs)

          unless names.empty?
            names_def = generate_names_definition
            names_assignments = generate_names_assignments(names)

            sexp = if stmt?
                     handle_statement(sexp, names_def, names_assignments)
                   else
                     handle_non_statement(sexp, names_def, names_assignments)
                   end
          end
        end

        push process(sexp, @level)
      end

      private

      def extract_names(regexp_node)
        re = regexp_node.children.first.children.first
        re.scan(/\(\?<([^>]*)>/).flatten.map(&:to_sym)
      end

      def generate_names_definition
        # Generate names definition: $m3names = $~ ? $~.named_captures : {}
        s(:lvasgn, :$m3names,
          s(:if,
            s(:gvar, :$~),
            s(:send, s(:gvar, :$~), :named_captures),
            s(:hash)
          )
        )
      end

      def generate_names_assignments(names)
        # Generate names assignments: abc = $m3names[:abc]
        names.map do |name|
          s(:lvasgn, name,
            s(:send,
              s(:lvar, :$m3names),
              :[],
              s(:sym, name)
            )
          )
        end
      end

      def handle_statement(sexp, names_def, names_assignments)
        # We don't care about a return value of this one, so we
        # ignore it and just assign the local variables.
        #
        # (/(?<abc>b)/ =~ 'f')
        # $m3names = $~ ? $~.named_captures : {}
        # abc = $m3names[:abc]
        s(:begin, sexp, names_def, *names_assignments)
      end

      def handle_non_statement(sexp, names_def, names_assignments)
        # We actually do care about a return value, so we must
        # keep it saved.
        #
        # $m3tmp = (/(?<abc>b)/ =~ 'f')
        # $m3names = $~ ? $~.named_captures : {}
        # abc = $m3names[:abc]
        # $m3tmp
        s(:begin,
          s(:lvasgn, :$m3tmp, sexp),
          names_def,
          *names_assignments,
          s(:lvar, :$m3tmp)
        )
      end
    end
  end
end
