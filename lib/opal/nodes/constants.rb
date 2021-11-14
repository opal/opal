# frozen_string_literal: true

require 'opal/nodes/base'

module Opal
  module Nodes
    class ConstNode < Base
      handle :const

      children :const_scope, :name

      def compile
        if magical_data_const?
          push('$__END__')
        elsif optimized_access?
          helper :"#{name}"
          push "$#{name}"
        elsif const_scope == s(:cbase)
          push "#{top_scope.absolute_const}('#{name}')"
        elsif const_scope
          push "#{top_scope.absolute_const}(", recv(const_scope), ", '#{name}')"
        elsif compiler.eval?
          push "#{top_scope.relative_const}($nesting, '#{name}')"
        else
          push "#{top_scope.relative_const}($nesting, '#{name}')"
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

      OPTIMIZED_ACCESS_CONSTS = %i[
        BasicObject Object Module Class Opal Kernel NilClass
      ].freeze

      # For a certain case of calls like `::Opal.coerce_to?` we can
      # optimize the calls. We can be sure they are defined from the
      # beginning.
      def optimized_access?
        const_scope == s(:cbase) && OPTIMIZED_ACCESS_CONSTS.include?(name)
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
        helper :const_set

        if base
          push '$const_set(', expr(base), ", '#{name}', ", expr(value), ')'
        else
          push "$const_set($nesting[0], '#{name}', ", expr(value), ')'
        end
      end
    end
  end
end
