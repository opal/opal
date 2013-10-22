require 'opal/nodes/base'

module Opal
  class Parser
    class NextNode < Node
      children :value

      def compile
        return push "continue;" if in_while?

        push expr_or_nil(value)
        wrap "return ", ";"
      end
    end

    class BreakNode < Node
      children :value

      def compile
        if in_while?
          compile_while
        elsif scope.iter?
          compile_iter
        else
          error "void value expression: cannot use break outside of iter/while"
        end
      end

      def compile_while
        if while_loop[:closure]
          push "return ", expr_or_nil(value)
        else
          push "break;"
        end
      end

      def compile_iter
        error "break must be used as a statement" unless stmt?
        push expr_or_nil(value)
        wrap "return ($breaker.$v = ", ", $breaker)"
      end
    end

    class RedoNode < Node
      def compile
        if in_while?
          compile_while
        elsif scope.iter?
          compile_iter
        else
          push "REDO()"
        end
      end

      def compile_while
        while_loop[:use_redo] = true
        push "#{while_loop[:redo_var]} = true"
      end

      def compile_iter
        push "return #{scope.identity}.apply(null, $slice.call(arguments))"
      end
    end

    class NotNode < Node
      children :value

      def compile
        with_temp do |tmp|
          push expr(value)
          wrap "(#{tmp} = ", ", (#{tmp} === nil || #{tmp} === false))"
        end
      end
    end

    class SplatNode < Node
      children :value

      def empty_splat?
        value == [:nil] or value == [:paren, [:nil]]
      end

      def compile
        if empty_splat?
          push '[]'
        elsif value.type == :sym
          push '[', expr(value), ']'
        else
          push recv(value)
        end
      end
    end

    class OrNode < Node
      children :lhs, :rhs

      def compile
        with_temp do |tmp|
          push "(((#{tmp} = "
          push expr(lhs)
          push ") !== false && #{tmp} !== nil) ? #{tmp} : "
          push expr(rhs)
          push ")"
        end
      end
    end

    class AndNode < Node
      children :lhs, :rhs

      def compile
        truthy_opt = nil

        with_temp do |tmp|
          if truthy_opt = @parser.js_truthy_optimize(lhs)
            push "((#{tmp} = ", truthy_opt
            push ") ? "
            push expr(rhs)
            push " : #{tmp})"
          else
            push "(#{tmp} = "
            push expr(lhs)
            push ", #{tmp} !== false && #{tmp} !== nil ?"
            push expr(rhs)
            push " : #{tmp})"
          end
        end
      end
    end

    class ReturnNode < Node
      children :value

      def return_val
        expr_or_nil value
      end

      def return_in_iter?
        if scope.iter? and parent_def = scope.find_parent_def
          parent_def
        end
      end

      def return_expr_in_def?
        return scope if expr? and scope.def?
      end

      def scope_to_catch_return
        return_in_iter? or return_expr_in_def?
      end

      def compile
        if def_scope = scope_to_catch_return
          def_scope.catch_return = true
          push '$opal.$return(', return_val, ')'
        elsif stmt?
          push 'return ', return_val
        else
          raise SyntaxError, "void value expression: cannot return as an expression"
        end
      end
    end

    class DefinedNode < Node
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
        mid = @parser.mid_to_jsid value[2].to_s
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
        push @parser.process_super(value, @level, :skip_call)
        wrap '((', ') != null ? "super" : nil)'
      end

      def compile_yield
        push @parser.js_block_given(@sexp, @level)
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
