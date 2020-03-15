# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    # This base class is used just to child the find_super_dispatcher method
    # body. This is then used by actual super calls, or a defined?(super) style
    # call.
    class BaseSuperNode < CallNode
      def initialize(*)
        super
        args = *@sexp
        *rest, last_child = *args

        if last_child && %i[iter block_pass].include?(last_child.type)
          @iter = last_child
          args = rest
        else
          @iter = s(:js_tmp, 'null')
        end

        @arglist = s(:arglist, *args)
        @recvr = s(:self)
      end

      def compile_using_send
        helper :send2

        push '$send2('
        compile_receiver
        compile_method_body
        compile_method_name
        compile_arguments
        compile_block_pass
        push ')'
      end

      private

      # Using super in a block inside a method is allowed, e.g.
      # def a
      #  { super }
      # end
      #
      # This method finds returns a closest s(:def) (or s(:defs))
      def def_scope
        @def_scope ||= scope.def? ? scope : scope.find_parent_def
      end

      def raise_exception?
        @sexp.type == :defined_super
      end

      def defined_check_param
        raise_exception? ? 'true' : 'false'
      end

      def implicit_args?
        @sexp.type == :zsuper
      end

      def implicit_arguments_param
        implicit_args? ? 'true' : 'false'
      end

      def method_id
        def_scope.mid.to_s
      end

      def def_scope_identity
        def_scope.identify!(def_scope.mid)
      end

      def allow_stubs
        true
      end

      def super_method_invocation
        helper :super
        "$find_super(self, '#{method_id}', #{def_scope_identity}, #{defined_check_param}, #{allow_stubs})"
      end

      def super_block_invocation
        helper :block_super
        chain, cur_defn, mid = scope.super_chain
        trys = chain.map { |c| "#{c}.$$def" }.join(' || ')
        "$find_block_super(self, #{mid}, (#{trys} || #{cur_defn}), #{defined_check_param}, #{implicit_arguments_param})"
      end

      def compile_method_body
        push ', '
        if scope.def?
          push super_method_invocation
        elsif scope.iter?
          push super_block_invocation
        else
          raise 'super must be called from method body or block'
        end
      end

      def compile_method_name
        if scope.def?
          push ", '#{method_id}'"
        elsif scope.iter?
          _chain, _cur_defn, mid = scope.super_chain
          push ", #{mid}"
        end
      end
    end

    class DefinedSuperNode < BaseSuperNode
      handle :defined_super

      def allow_stubs
        false
      end

      def compile
        compile_receiver
        compile_method_body

        wrap '((', ') != null ? "super" : nil)'
      end
    end

    # super with implicit args
    class SuperNode < BaseSuperNode
      handle :super

      def initialize(*)
        super

        if scope.def?
          scope.uses_block!
        end
      end

      def compile
        compile_using_send
      end
    end

    # super with explicit args
    class ZsuperNode < SuperNode
      handle :zsuper

      def initialize(*)
        super

        # preserve a block if we have one already but otherwise, assume a block is coming from higher
        # up the chain
        unless iter.type == :iter
          # Need to support passing block up even if it's not referenced in this method at all
          scope.uses_block!
          @iter = s(:js_tmp, '$iter')
        end
      end

      def compile
        if def_scope
          def_scope.uses_zuper = true
          implicit_args = [s(:js_tmp, '$zuper')]
          # If the method we're in has a block and we're using a default super call with no args, we need to grab the block
          # If an iter (block via braces) is provided, that takes precedence
          if block_name && !iter
            block_pass = s(:block_pass, s(:lvar, block_name))
            implicit_args << block_pass
          end

          @arglist = s(:arglist, *implicit_args)
        end

        compile_using_send
      end

      def compile_arguments
        push ', '

        if arglist.children.empty?
          push '[]'
        else
          push expr(arglist)
        end
      end

      def block_name
        case def_scope
        when Opal::Nodes::IterNode
          def_scope.block_name
        when Opal::Nodes::DefNode
          def_scope.block_name
        else
          raise "Don't know what to do with super in the scope #{def_scope}"
        end
      end
    end
  end
end
