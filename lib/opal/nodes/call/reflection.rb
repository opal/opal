# frozen_string_literal: true

require 'opal/nodes/base'
require 'opal/nodes/call'

module Opal
  module Nodes
    class CallNode
      add_special :__callee__ do
        if scope.def?
          push fragment scope.mid.to_s.inspect
        else
          push fragment 'nil'
        end
      end

      add_special :__method__ do
        if scope.def?
          push fragment scope.mid.to_s.inspect
        else
          push fragment 'nil'
        end
      end

      add_special :__dir__ do
        push File.dirname(Opal::Compiler.module_name(compiler.file)).inspect
      end

      add_special :__OPAL_COMPILER_CONFIG__ do
        push fragment "(new Map([['arity_check', #{compiler.arity_check?}]]))"
      end

      add_special :nesting do |compile_default|
        push_nesting = push_nesting?
        push "(Opal.Module.$$nesting = #{scope.nesting}, " if push_nesting
        compile_default.call
        push ')' if push_nesting
      end

      add_special :constants do |compile_default|
        push_nesting = push_nesting?
        push "(Opal.Module.$$nesting = #{scope.nesting}, " if push_nesting
        compile_default.call
        push ')' if push_nesting
      end

      add_special :local_variables do |compile_default|
        next compile_default.call unless [s(:self), nil].include?(recvr)

        scope_variables = scope.scope_locals.map(&:to_s).inspect
        push scope_variables
      end
    end
  end
end
