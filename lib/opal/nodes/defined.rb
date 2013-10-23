require 'opal/nodes/base'

module Opal
  module Nodes
    class DefinedNode < Base
      handle :defined

      children :value

      def compile
        type = value.type

        case type
        when :self, :nil, :false, :true
          push type.to_s.inspect
        when :lasgn, :iasgn, :gasgn, :cvdecl, :masgn, :op_asgn_or, :op_asgn_and
          push "'assignment'"
        when :paren, :not
          push expr(s(:defined, value[1]))
        when :lvar
          push "'local-variable'"
        else
          if respond_to? "compile_#{type}"
            __send__ "compile_#{type}"
          else
            push "'expression'"
          end
        end
      end

      def compile_call
        mid = mid_to_jsid value[2].to_s
        recv = value[1] ? expr(value[1]) : 'self'

        push '(', recv, "#{mid} || ", recv
        push "['$respond_to_missing?']('#{value[2].to_s}') ? 'method' : nil)"
      end

      def compile_ivar
        # FIXME: this check should be positive for ivars initialized as nil too.
        # Since currently all known ivars are inialized to nil in the constructor
        # we can't tell if it was the user that put nil and made the ivar #defined?
        # or not.
        with_temp do |tmp|
          name = value[1].to_s[1..-1]

          push "((#{tmp} = self['#{name}'], #{tmp} != null && #{tmp} !== nil) ? "
          push "'instance-variable' : nil)"
        end
      end

      def compile_super
        push expr(s(:defined_super, value))
      end

      def compile_yield
        push compiler.js_block_given(@sexp, @level)
        wrap '((',  ') != null ? "yield" : nil)'
      end

      def compile_xstr
        push expr(value)
        wrap '(typeof(', ') !== "undefined")'
      end
      alias compile_dxstr compile_xstr

      def compile_const
        push "($scope.#{value[1]} != null)"
      end

      def compile_colon2
        # TODO: avoid try/catch, probably a #process_colon2 alternative that
        # does not raise errors is needed
        push "(function(){ try { return (("
        push expr(value)
        push ") != null ? 'constant' : nil); } catch (err) { if (err._klass"
        push " === Opal.NameError) { return nil; } else { throw(err); }}; })()"
      end

      def compile_colon3
        push "($opal.Object._scope.#{value[1]} == null ? nil : 'constant')"
      end

      def compile_cvar
        push "($opal.cvars['#{value[1]}'] != null ? 'class variable' : nil)"
      end

      def compile_gvar
        name = value[1].to_s[1..-1]

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
