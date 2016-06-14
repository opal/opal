require 'opal/nodes/base'

module Opal
  module Nodes
    class DefinedNode < Base
      handle :defined?

      children :value

      def compile
        type = value.type

        case type
        when :self, :nil, :false, :true
          push type.to_s.inspect
        when :lvasgn, :ivasgn, :gvasgn, :cvasgn, :casgn, :op_asgn, :or_asgn, :and_asgn
          push "'assignment'"
        when :lvar
          push "'local-variable'"
        when :back_ref
          compile_gvar
        when :begin
          if value.children.size == 1 && value.children[0].type == :masgn
            push "'assignment'"
          else
            push "'expression'"
          end
        else
          if respond_to? "compile_#{type}"
            __send__ "compile_#{type}"
          else
            push "'expression'"
          end
        end
      end

      def compile_send
        mid = mid_to_jsid value.children[1].to_s
        recv = value.children[0] ? expr(value.children[0]) : 'self'

        with_temp do |tmp|
          push "(((#{tmp} = ", recv, "#{mid}) && !#{tmp}.$$stub) || ", recv
          push "['$respond_to_missing?']('#{value.children[1].to_s}') ? 'method' : nil)"
        end
      end

      def compile_ivar
        # FIXME: this check should be positive for ivars initialized as nil too.
        # Since currently all known ivars are inialized to nil in the constructor
        # we can't tell if it was the user that put nil and made the ivar #defined?
        # or not.
        with_temp do |tmp|
          name = value.children[0].to_s[1..-1]

          push "((#{tmp} = self['#{name}'], #{tmp} != null && #{tmp} !== nil) ? "
          push "'instance-variable' : nil)"
        end
      end

      # FIXME: something is broken here.
      def compile_zsuper
        push expr(s(:defined_super, value))
      end
      alias compile_super compile_zsuper

      def compile_yield
        push compiler.handle_block_given_call(@sexp)
        wrap '((',  ') != null ? "yield" : nil)'
      end

      def compile_xstr
        push expr(value)
        wrap '(typeof(', ') !== "undefined")'
      end

      def compile_const
        if value.children[0] && value.children[0].type == :cbase
          # top-level const
          push "(Opal.Object.$$scope.#{value.children[1]} == null ? nil : 'constant')"
        else
          # local const
          # TODO: avoid try/catch, probably a #process_colon2 alternative that
          # does not raise errors is needed
          push "(function(){"
          push "  try {"
          push "    return ((", expr(value), ") != null ? 'constant' : nil);"
          push "  } catch (err) {"
          push "    if (err.$$class === Opal.NameError) {"
          push "      return nil;"
          push "    } else {"
          push "      throw(err);"
          push "    }"
          push "  } finally { Opal.pop_exception() };"
          push" })()"
        end
      end

      def compile_top_level_const
      end

      def compile_cvar
        push "(#{class_variable_owner}.$$cvars['#{value.children[0]}'] != null ? 'class variable' : nil)"
      end

      def compile_gvar
        name = value.children[0].to_s[1..-1]

        if %w[~ !].include? name
          push "'global-variable'"
        elsif %w[` ' + &].include? name
          with_temp do |tmp|
            push "((#{tmp} = $gvars['~'], #{tmp} != null && #{tmp} !== nil) ? "
            push "'global-variable' : nil)"
          end
        else
          push "($gvars[#{name.inspect}] != null ? 'global-variable' : nil)"
        end
      end

      def compile_nth_ref
        with_temp do |tmp|
          push "((#{tmp} = $gvars['~'], #{tmp} != null && #{tmp} != nil) ? "
          push "'global-variable' : nil)"
        end
      end
    end
  end
end
