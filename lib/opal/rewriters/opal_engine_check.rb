# frozen_string_literal: true

require 'opal/rewriters/base'

module Opal
  module Rewriters
    class OpalEngineCheck < Base
      def on_if(node)
        test, true_body, false_body = *node.children

        if skip_check_present?(test)
          process(true_body || s(:nil))
        elsif skip_check_present_not?(test)
          process(false_body || s(:nil))
        else
          super
        end
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
