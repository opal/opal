require 'opal/nodes/base'

module Opal
  module Nodes
    # This base class is used just to child the find_super_dispatcher method
    # body. This is then used by actual super calls, or a defined?(super) style
    # call.
    class BaseSuperNode < CallNode
      children :arglist, :raw_iter

      def compile
        if scope.def?
          scope.uses_block!
        end

        default_compile
      end

      private

      # always on self
      def recvr
        s(:self)
      end

      def iter
        # Need to support passing block up even if it's not referenced in this method at all
        @iter ||= begin
          if raw_iter
            raw_iter
          elsif arglist # TODO: Better understand this elsif vs. the else code path
            s(:js_tmp, 'null')
          else
            scope.uses_block!
            s(:js_tmp, '$iter')
          end
        end
      end

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

      def allow_super_from_block?
        scope.contains_defined_call? || scope.inside_anon_class? || scope.inside_define_method_call?
      end

      def containing_def_scope
        return scope if scope.def?
        return nil if allow_super_from_block?

        # using super in a block inside a method is allowed, e.g.
        # def a
        #  { super }
        # end
        scope.find_parent_def
      end

      def super_method_invocation
        def_scope = containing_def_scope
        method_jsid = def_scope.mid.to_s
        current_func = def_scope.identify!

        if def_scope.defs
          class_name = def_scope.parent.name ? "$#{def_scope.parent.name}" : 'self.$$class.$$proto'
          "Opal.find_super_dispatcher(self, '#{method_jsid}', #{current_func}, #{class_name})"
        else
          "Opal.find_super_dispatcher(self, '#{method_jsid}', #{current_func})"
        end
      end

      def super_block_invocation
        if @implicit_args
          staged_runtime_error 'implicit argument passing of super from method defined by define_method() is not supported. Specify all arguments explicitly'
        else
          chain, cur_defn, mid = scope.get_super_chain
          trys = chain.map { |c| "#{c}.$$def" }.join(' || ')

          "Opal.find_iter_super_dispatcher(self, #{mid}, (#{trys} || #{cur_defn}))"
        end
      end

      def staged_runtime_error(text)
        "self.$raise('#{text}')"
      end

      def add_method(temporary_receiver)
        super_call = if containing_def_scope
          super_method_invocation
        elsif scope.iter? && allow_super_from_block?
          super_block_invocation
        else
          staged_runtime_error 'super called outside of method'
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

      def compile
        if arglist == nil
          @implicit_args = true
          if containing_def_scope
            containing_def_scope.uses_zuper = true
            @arguments_without_block = [s(:js_tmp, '$zuper')]
            # If the method we're in has a block and we're using a default super call with no args, we need to grab the block
            # If an iter (block via braces) is provided, that takes precedence
            if (block_arg = formal_block_parameter) && !iter
              expr = s(:block_pass, s(:lvar, block_arg[1]))
              @arguments_without_block << expr
            end
          else
            # will end up in a "can't call super from block" situation, but don't want compiler errors
            @arguments_without_block = []
          end
        end
        super
      end

      private

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
