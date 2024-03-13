# frozen_string_literal: true

require 'opal/nodes/base'
require 'opal/nodes/call'

module Opal
  module Nodes
    class CallNode
      # This can be refactored in terms of binding, but it would need 'corelib/binding'
      # to be required in existing code.
      add_special :eval do |compile_default|
        # Catch the return throw coming from eval
        thrower(:eval_return)

        next compile_default.call if arglist.children.length != 1 || ![s(:self), nil].include?(recvr)

        scope.nesting
        temp = scope.new_temp
        scope_variables = scope.scope_locals.map(&:to_s).inspect
        push "(#{temp} = ", expr(arglist)
        push ", typeof Opal.compile === 'function' ? eval(Opal.compile(#{temp}"
        push ', {scope_variables: ', scope_variables
        push ", arity_check: #{compiler.arity_check?}, file: '(eval)', eval: true})) : "
        push "#{scope.self}.$eval(#{temp}))"
      end

      add_special :binding do |compile_default|
        next compile_default.call unless recvr.nil?

        scope.nesting
        push "Opal.Binding.$new("
        push "  function($code) {"
        push "    return eval($code);"
        push "  },"
        push "  ", scope.scope_locals.map(&:to_s).inspect, ","
        push "  ", scope.self, ","
        push "  ", source_location
        push ")"
      end
    end
  end
end
