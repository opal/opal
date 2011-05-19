module Spec
  module Expectations

    class PositiveExpectationHandler

      def self.handle_matcher(actual, matcher, message, &block)
        Spec::Matchers.last_should = :should
        Spec::Matchers.last_matcher = matcher
        if matcher.nil?
          return Spec::Matchers::PositiveOperatorMatcher.new actual
        else
          puts "matcher not nil"
          match = matcher.matches?(actual, &block)
          return match if match

          Spec::Expectations.fail_with matcher.failure_message_for_should
          nil
        end
      end
    end

    class NegativeExpectationHandler

      def self.handle_matcher(actual, matcher, message, &block)
        Spec::Matchers.last_should = :should_not
        Spec::Matchers.last_matcher = matcher
        if matcher.nil?
          return Spec::Matchers::NegativeOperatorMatcher.new actual
        end
      end
    end
  end
end

