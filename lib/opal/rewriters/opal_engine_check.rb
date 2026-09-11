# frozen_string_literal: true

require 'opal/rewriters/base'
require 'opal/rewriters/local_variable_assigns'

module Opal
  module Rewriters
    class OpalEngineCheck < Base
      def on_if(node)
        test, true_body, false_body = *node.children

        if (values = engine_check?(test))
          kept, dropped = if positive_engine_check?(*values)
                            [true_body, false_body]
                          else
                            [false_body, true_body]
                          end

          keep_local_variables_of(dropped, process(kept || s(:nil)))
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

      private

      # The dropped branch never runs, but Ruby still exposes the local
      # variables it assigns to the rest of the scope, so declare them.
      def keep_local_variables_of(dropped, kept)
        return kept unless dropped

        declarations = LocalVariableAssigns.find(dropped).map { |name| s(:lvdeclare, name) }
        return kept if declarations.empty?

        prepend_to_body(kept, s(:begin, *declarations))
      end
    end
  end
end
