require 'opal/nodes/base'

module Opal
  module Nodes
    # This base class is used just to child the find_super_dispatcher method
    # body. This is then used by actual super calls, or a defined?(super) style
    # call.
    class BaseSuperNode < Base
      children :arglist, :iter

      def compile_dispatcher
        if arglist or iter
          iter = expr(iter_sexp)
        else
          scope.uses_block!
          iter = '$iter'
        end
        if scope.def?
          scope.uses_block!
          scope_name = scope.identify!
          class_name = scope.parent.name ? "$#{scope.parent.name}" : 'self.$$class.$$proto'

          if scope.defs
            push "Opal.find_super_dispatcher(self, '#{scope.mid.to_s}', #{scope_name}, "
            push iter
            push ", #{class_name})"
          else
            push "Opal.find_super_dispatcher(self, '#{scope.mid.to_s}', #{scope_name}, "
            push iter
            push ")"
          end
        elsif scope.iter?
          chain, cur_defn, mid = scope.get_super_chain
          trys = chain.map { |c| "#{c}.$$def" }.join(' || ')

          push "Opal.find_iter_super_dispatcher(self, #{mid}, (#{trys} || #{cur_defn}), null)"
        else
          raise "Cannot call super() from outside a method block"
        end
      end

      def args
        arglist || s(:arglist)
      end

      def iter_sexp
        iter || s(:js_tmp, 'null')
      end
    end

    class DefinedSuperNode < BaseSuperNode
      handle :defined_super

      def compile
        # insert method body to find super method
        self.compile_dispatcher

        wrap '((', ') != null ? "super" : nil)'
      end
    end

    class SuperNode < BaseSuperNode
      handle :super

      children :arglist, :iter

      def compile
        if arglist or iter
          splat = has_splat?
          args = expr(self.args)

          unless splat
            args = [fragment('['), args, fragment(']')]
          end
        else
          if scope.def?
            scope.uses_zuper = true
            args = fragment('$zuper')
          else
            args = fragment('$slice.call(arguments)')
          end
        end

        # compile our call to runtime to get super method
        self.compile_dispatcher

        push ".apply(self, "
        push(*args)
        push ")"
      end

      def has_splat?
        args.children.any? { |child| child.type == :splat }
      end
    end
  end
end
