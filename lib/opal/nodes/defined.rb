require 'opal/nodes/base'

module Opal
  module Nodes
    class DefinedNode < Base
      handle :defined?

      children :value

      def compile
        case value.type
        when :self, :nil, :false, :true
          push value.type.to_s.inspect
        when :lvasgn, :ivasgn, :gvasgn, :cvasgn, :casgn, :op_asgn, :or_asgn, :and_asgn
          push "'assignment'"
        when :lvar
          push "'local-variable'"
        when :begin
          if value.children.size == 1 && value.children[0].type == :masgn
            push "'assignment'"
          else
            push "'expression'"
          end
        when :send
          compile_defined_send(value)
          wrap "(", " ? 'method' : nil)"
        when :ivar
          compile_defined_ivar(value)
          wrap "(", " ? 'instance-variable' : nil)"
        when :zsuper, :super
          compile_defined_super(value)
        when :yield
          compile_defined_yield(value)
          wrap "(", " ? 'yield' : nil)"
        when :xstr
          compile_defined_xstr(value)
        when :const
          compile_defined_const(value)
          wrap "(", " ? 'constant' : nil)"
        when :cvar
          compile_defined_cvar(value)
          wrap "(", " ? 'class variable' : nil)"
        when :gvar
          compile_defined_gvar(value)
          wrap "(", " ? 'global-variable' : nil)"
        when :back_ref
          compile_defined_back_ref(value)
          wrap "(", " ? 'global-variable' : nil)"
        when :nth_ref
          compile_defined_nth_ref(value)
          wrap "(", " ? 'global-variable' : nil)"
        when :array
          compile_defined_array(value)
          wrap "(", " ? 'expression' : nil)"
        else
          push "'expression'"
        end
      end

      def compile_defined(node)
        type = node.type

        if respond_to? "compile_defined_#{type}"
          __send__("compile_defined_#{type}", node)
        else
          node_tmp = scope.new_temp
          push "(#{node_tmp} = ", expr(node), ")"
          node_tmp
        end
      end

      def wrap_with_try_catch(code)
        returning_tmp = scope.new_temp

        push "(#{returning_tmp} = (function() { try {"
        push "  return #{code};"
        push "} catch ($err) {"
        push "  if (Opal.rescue($err, [Opal.Exception])) {"
        push "    try {"
        push "      return false;"
        push "    } finally { Opal.pop_exception() }"
        push "  } else { throw $err; }"
        push "}})())"

        returning_tmp
      end

      def compile_send_recv_doesnt_raise(recv_code)
        wrap_with_try_catch(recv_code)
      end

      def compile_defined_send(node)
        recv, method_name, *args = *node
        mid = mid_to_jsid(method_name.to_s)

        if recv
          recv_code = compile_defined(recv)
          push " && "

          if recv.type == :send
            recv_code = compile_send_recv_doesnt_raise(recv_code)
            push " && "
          end

          recv_tmp = scope.new_temp
          push "(#{recv_tmp} = ", recv_code, ", #{recv_tmp}) && "
        else
          recv_tmp = "self"
        end

        recv_value_tmp = scope.new_temp
        push "(#{recv_value_tmp} = #{recv_tmp}) && "

        meth_tmp = scope.new_temp
        push "(((#{meth_tmp} = #{recv_value_tmp}#{mid}) && !#{meth_tmp}.$$stub)"

        push " || #{recv_value_tmp}['$respond_to_missing?']('#{method_name}'))"

        args.each do |arg|
          case arg.type
          when :block_pass
            # ignoring
          else
            push " && "
            compile_defined(arg)
          end
        end

        wrap '(', ')'
        "#{meth_tmp}()"
      end

      def compile_defined_ivar(node)
        name = node.children[0].to_s[1..-1]
        # FIXME: this check should be positive for ivars initialized as nil too.
        # Since currently all known ivars are inialized to nil in the constructor
        # we can't tell if it was the user that put nil and made the ivar #defined?
        # or not.
        tmp = scope.new_temp
        push "(#{tmp} = self['#{name}'], #{tmp} != null && #{tmp} !== nil)"

        tmp
      end

      def compile_defined_super(node)
        push expr s(:defined_super)
      end

      def compile_defined_yield(node)
        scope.uses_block!
        block_name = scope.block_name || (parent = scope.find_parent_def && parent.block_name)
        push "(#{block_name} != null && #{block_name} !== nil)"
        block_name
      end

      def compile_defined_xstr(node)
        push '(typeof(', expr(node), ') !== "undefined")'
      end

      def compile_defined_const(node)
        const_scope, const_name = *node

        const_tmp = scope.new_temp

        if const_scope.nil?
          push "(#{const_tmp} = Opal.const_get_relative($nesting, '#{const_name}', 'skip_raise'))"
        elsif const_scope == s(:cbase)
          push "(#{const_tmp} = Opal.const_get_qualified('::', '#{const_name}', 'skip_raise'))"
        else
          const_scope_tmp = compile_defined(const_scope)
          push " && (#{const_tmp} = Opal.const_get_qualified(#{const_scope_tmp}, '#{const_name}', 'skip_raise'))"
        end
        const_tmp
      end


      def compile_defined_cvar(node)
        cvar_name, _ = *node
        cvar_tmp = scope.new_temp
        push "(#{cvar_tmp} = #{class_variable_owner}.$$cvars['#{cvar_name}'], #{cvar_tmp} != null)"
        cvar_tmp
      end

      def compile_defined_gvar(node)
        helper :gvars

        name = node.children[0].to_s[1..-1]
        gvar_temp = scope.new_temp

        if %w[~ !].include? name
          push "(#{gvar_temp} = ", expr(node), " || true)"
        else
          push "(#{gvar_temp} = $gvars[#{name.inspect}], #{gvar_temp} != null)"
        end

        gvar_temp
      end

      def compile_defined_back_ref(node)
        helper :gvars
        back_ref_temp = scope.new_temp
        push "(#{back_ref_temp} = $gvars['~'], #{back_ref_temp} != null && #{back_ref_temp} !== nil)"
        back_ref_temp
      end

      def compile_defined_nth_ref(node)
        helper :gvars

        nth_ref_tmp = scope.new_temp
        push "(#{nth_ref_tmp} = $gvars['~'], #{nth_ref_tmp} != null && #{nth_ref_tmp} != nil)"
        nth_ref_tmp
      end

      def compile_defined_array(node)
        node.children.each_with_index do |child, idx|
          push " && " unless idx == 0
          compile_defined(child)
        end
      end
    end
  end
end
