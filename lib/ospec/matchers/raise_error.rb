module Spec

  module Matchers

    class RaiseError

      def initialize(expected_error_or_message = Exception, expected_message = nil, &block)
        @block = block
        @actual_error = nil
        @expected_exception = Exception
      end

      def matches?(given_proc)
        @raised_expected_exception = false
        @with_expected_message = false

        begin
          given_proc.call
        rescue => e
          @raised_expected_exception = true
        end

        @raised_expected_exception
      end

      def failure_message_for_should
        "expected #{@expected_exception}, but nothing was raised"
      end
    end # RaiseError

    def raise_error(error = Exception, message = nil, &block)
      Spec::Matchers::RaiseError.new error, message, &block
    end

    alias_method :raise_exception, :raise_error
  end
end

