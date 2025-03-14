# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class OpalEngineCheck < Base
      def on_if(node)
        test, true_body, false_body = *node.children

        if (values = engine_check?(test))
          if positive_engine_check?(*values)
            process(true_body || s(:nil))
          else
            process(false_body || s(:nil))
          end
        else
          super
        end
      end

      def engine_check?(test)
        # Engine check must look like this: s(:send, recvr, method, arg)
        return false unless test.type == :send && test.children.length == 3

        recvr, method, arg = *test.children

        # Ensure that the recvr is present
        return false unless recvr

        # Enhance the check to: s(:send, s(:const, X, Y), :==/:!=, s(:str, Z))
        return false unless recvr.type == :const
        return false unless arg.type == :str
        return false unless %i[== !=].include? method

        # Ensure that checked const is either RUBY_ENGINE or RUBY_PLATFORM
        const_name = recvr.children[1]
        return false unless %i[RUBY_ENGINE RUBY_PLATFORM].include? const_name

        # Return a truthy value
        [method, arg.children.first]
      end

      def positive_engine_check?(method, const_value)
        (method == :==) ^ (const_value != 'opal')
      end
    end
  end
end
