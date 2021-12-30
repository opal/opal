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

      def defined_check_param
        'false'
      end

      def implicit_arguments_param
        'false'
      end

      def method_id
        def_scope.mid.to_s
      end

      def def_scope_identity
        def_scope.identify!(def_scope.mid)
      end

      def allow_stubs
        'true'
      end

      def super_method_invocation
        helper :find_super
        "$find_super(#{scope.self}, '#{method_id}', #{def_scope_identity}, #{defined_check_param}, #{allow_stubs})"
      end

      def super_block_invocation
        helper :find_block_super
        chain, cur_defn, mid = scope.super_chain
        trys = chain.map { |c| "#{c}.$$def" }.join(' || ')
        "$find_block_super(#{scope.self}, #{mid}, (#{trys} || #{cur_defn}), #{defined_check_param}, #{implicit_arguments_param})"
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
        'false'
      end

      def defined_check_param
        'true'
      end

      def compile
        compile_receiver
        compile_method_body

        wrap '((', ') != null ? "super" : nil)'
      end
    end

    # super with explicit args
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

    # super with implicit args
    class ZsuperNode < SuperNode
      handle :zsuper

      def implicit_arguments_param
        'true'
      end

      def initialize(*)
        super

        # preserve a block if we have one already but otherwise, assume a block is coming from higher
        # up the chain
        unless iter.type == :iter
          # Need to support passing block up even if it's not referenced in this method at all
          scope.uses_block!
          @iter = s(:js_tmp, scope.block_name || '$yield')
        end
      end

      def compile
        if def_scope
          implicit_args = implicit_arglist
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

      def implicit_arglist
        args = []
        kwargs = []
        same_arg_counter = Hash.new(0)

        def_scope.original_args.children.each do |sexp|
          lvar_name = sexp.children[0]

          case sexp.type
          when :arg, :optarg
            arg_node = s(:lvar, lvar_name)
            #   def m(_, _)
            # is compiled to
            #   function $$m(_, __$2)
            # See Opal::Node::ArgsNode
            if lvar_name[0] == '_'
              same_arg_counter[lvar_name] += 1
              arg_node = s(:js_tmp, "#{lvar_name}_$#{same_arg_counter[lvar_name]}") if same_arg_counter[lvar_name] > 1
            end
            args << arg_node
          when :restarg
            arg_node = lvar_name ? s(:lvar, lvar_name) : s(:js_tmp, '$rest_arg')
            args << s(:splat, arg_node)
          when :kwarg, :kwoptarg
            key_name = sexp.meta[:arg_name]
            kwargs << s(:pair, s(:sym, key_name), s(:lvar, lvar_name))
          when :kwrestarg
            arg_node = lvar_name ? s(:lvar, lvar_name) : s(:js_tmp, '$kw_rest_arg')
            kwargs << s(:kwsplat, arg_node)
          end
        end

        args << s(:hash, *kwargs) unless kwargs.empty?
        args
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
