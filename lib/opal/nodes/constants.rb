# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    class ConstNode < Base
      handle :const

      children :const_scope, :name

      def compile
        if magical_data_const?
          push("$__END__")
        elsif const_scope
          push "Opal.const_get_qualified(", recv(const_scope), ", '#{name}')"
        elsif compiler.eval?
          push "Opal.const_get_relative($nesting, '#{name}')"
        else
          push "Opal.const_get_relative($nesting, '#{name}')"
        end
      end

      # Ruby has a magical const DATA
      # that should be processed in a different way:
      # 1. When current file contains __END__ in the end of the file
      #    DATA const should be resolved to the string located after __END__
      # 2. When current file doesn't have __END__ section
      #    DATA const should be resolved to a regular ::DATA constant
      def magical_data_const?
        const_scope.nil? && name == :DATA && compiler.eof_content
      end
    end

    # ::CONST
    # s(:const, s(:cbase), :CONST)
    class CbaseNode < Base
      handle :cbase

      def compile
        push "'::'"
      end
    end

    class ConstAssignNode < Base
      handle :casgn

      children :base, :name, :value

      def compile
        if base
          push "Opal.const_set(", expr(base), ", '#{name}', ", expr(value), ")"
        else
          push "Opal.const_set($nesting[0], '#{name}', ", expr(value), ")"
        end
      end
    end
  end
end
