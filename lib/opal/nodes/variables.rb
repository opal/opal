require 'opal/nodes/base'

module Opal
  class Parser
    class LvarNode < Node
      def using_irb?
        @parser.instance_variable_get(:@irb_vars) and scope.top?
      end

      def var_name
        @sexp[1].to_s
      end

      def compile
        return push(variable(var_name)) unless using_irb?

        with_temp do |tmp|
          push property(var_name)
          wrap "((#{tmp} = $opal.irb_vars", ") == null ? nil : #{tmp})"
        end
      end
    end

    class LasgnNode < Node
      def using_irb?
        @parser.instance_variable_get(:@irb_vars) and scope.top?
      end

      def var_name
        @sexp[1].to_s
      end

      def compile
        if using_irb?
          push "$opal.irb_vars#{property var_name} = "
          push expr(@sexp[2])
        else
          add_local variable(var_name)

          push "#{variable(var_name)} = "
          push expr(@sexp[2])
        end

        wrap '(', ')' if @level == :recv
      end
    end

    class IvarNode < Node
      def var_name
        @sexp[1].to_s[1..-1]
      end

      def compile
        name = property var_name
        add_ivar name
        push "self#{name}"
      end
    end

    class IasgnNode < Node
      def var_name
        @sexp[1].to_s[1..-1]
      end

      def compile
        name = property var_name
        push "self#{name} = "
        push expr(@sexp[2])
      end
    end

    class GvarNode < Node
      def var_name
        @sexp[1].to_s[1..-1]
      end

      def compile
        helper :gvars
        push "$gvars[#{var_name.inspect}]"
      end
    end

    class GasgnNode < Node
      def var_name
        @sexp[1].to_s[1..-1]
      end

      def compile
        helper :gvars
        push "$gvars[#{var_name.inspect}] = "
        push expr(@sexp[2])
      end
    end

    class NthRefNode < Node
      def compile
        push "nil"
      end
    end

    class CvarNode < Node
      def compile
        with_temp do |tmp|
          push "((#{tmp} = $opal.cvars['#{@sexp[1]}']) == null ? nil : #{tmp})"
        end
      end
    end

    class CvasgnNode < Node
      def compile
        push "($opal.cvars['#{@sexp[1]}'] = "
        push expr(@sexp[2])
        push ")"
      end
    end

    class CvdeclNode < Node
      def compile
        push "($opal.cvars['#{@sexp[1]}'] = "
        push expr(@sexp[2])
        push ")"
      end
    end
  end
end
