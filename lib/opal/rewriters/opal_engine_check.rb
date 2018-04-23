# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class OpalEngineCheck < Base
      def on_if(node)
        test, true_body, false_body = *node.children

        if skip_check_present?(test)
          false_body = s(:nil)
          return true_body
        end

        if skip_check_present_not?(test)
          true_body = s(:nil)
          return false_body
        end

        node.updated(nil, process_all([test, true_body, false_body]))
      end

      def skip_check_present?(test)
        test == RUBY_ENGINE_CHECK || test == RUBY_PLATFORM_CHECK
      end

      def skip_check_present_not?(test)
        test == RUBY_ENGINE_CHECK_NOT || test == RUBY_PLATFORM_CHECK_NOT
      end

      RUBY_ENGINE_CHECK = s(:send, s(:const, nil, :RUBY_ENGINE),
        :==, s(:str, 'opal')
      )

      RUBY_ENGINE_CHECK_NOT = s(:send, s(:const, nil, :RUBY_ENGINE),
        :!=, s(:str, 'opal')
      )

      RUBY_PLATFORM_CHECK = s(:send, s(:const, nil, :RUBY_PLATFORM),
        :==, s(:str, 'opal')
      )

      RUBY_PLATFORM_CHECK_NOT = s(:send, s(:const, nil, :RUBY_PLATFORM),
        :!=, s(:str, 'opal')
      )
    end
  end
end
