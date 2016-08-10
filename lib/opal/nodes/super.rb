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

        if last_child && [:iter, :block_pass].include?(last_child.type)
          @iter = last_child
          args = rest
        else
          @iter = s(:js_tmp, 'null')
        end

        @arglist = s(:arglist, *args)
        @recvr = s(:self)
      end

      def compile
        if scope.def?
          scope.uses_block!
        end

        default_compile
      end

      private

      def method_jsid
        raise 'Not implemented, see #add_method'
      end

      # Need a way to pass self into the method invocation
      def redefine_this?(temporary_receiver)
        true
      end

      def arguments_array?
        # zuper is an implicit super argument array
        super || @implicit_args
      end

      def containing_def_scope
        return scope if scope.def?

        # using super in a block inside a method is allowed, e.g.
        # def a
        #  { super }
        # end
        scope.find_parent_def
      end

      def defined_check_param
        'false'
      end

      def implicit_arguments_param
        @implicit_args ? 'true' : 'false'
      end

      def super_method_invocation
        def_scope = containing_def_scope
        method_jsid = def_scope.mid.to_s
        current_func = def_scope.identify!(def_scope.mid)

        if def_scope.defs
          class_name = def_scope.parent.name ? "$#{def_scope.parent.name}" : 'self.$$class.$$proto'
          "Opal.find_super_dispatcher(self, '#{method_jsid}', #{current_func}, #{defined_check_param}, #{class_name})"
        else
          "Opal.find_super_dispatcher(self, '#{method_jsid}', #{current_func}, #{defined_check_param})"
        end
      end

      def super_block_invocation
        chain, cur_defn, mid = scope.get_super_chain
        trys = chain.map { |c| "#{c}.$$def" }.join(' || ')
        implicit = @implicit_args.to_s
        "Opal.find_iter_super_dispatcher(self, #{mid}, (#{trys} || #{cur_defn}), #{defined_check_param}, #{implicit_arguments_param})"
      end

      def add_method(temporary_receiver)
        super_call = if scope.def?
          super_method_invocation
        elsif scope.iter?
          super_block_invocation
        else
          raise 'unexpected compilation error'
        end

        if temporary_receiver
          push "(#{temporary_receiver} = ", receiver_fragment, ", ", super_call, ")"
        else
          push super_call
        end
      end
    end

    class DefinedSuperNode < BaseSuperNode
      handle :defined_super

      def defined_check_param
        'true'
      end

      def compile
        add_method(nil)
        # will never come back null with method missing on
        if compiler.method_missing?
          wrap '(!(', '.$$stub) ? "super" : nil)'
        else
          # TODO: With method_missing support off, something breaks in runtime.js's chain
          wrap '((', ') != null ? "super" : nil)'
        end
      end
    end

    class SuperNode < BaseSuperNode
      handle :super
    end

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
        @implicit_args = true
        if containing_def_scope
          containing_def_scope.uses_zuper = true
          implicit_args = [s(:js_tmp, '$zuper')]
          # If the method we're in has a block and we're using a default super call with no args, we need to grab the block
          # If an iter (block via braces) is provided, that takes precedence
          if (block_arg = formal_block_parameter) && !iter
            block_pass = s(:block_pass, s(:lvar, block_arg[1]))
            implicit_args << block_pass
          end

          @arglist = s(:arglist, *implicit_args)
        end
        super
      end

      def formal_block_parameter
        case containing_def_scope
          when Opal::Nodes::IterNode
            containing_def_scope.extract_block_arg
          when Opal::Nodes::DefNode
            containing_def_scope.block_arg
          else
            raise "Don't know what to do with scope #{containing_def_scope}"
        end
      end
    end
  end
end
