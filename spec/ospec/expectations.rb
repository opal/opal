module OSpec
  class ExpectationNotMetError < StandardError; end

  module Expectations
    def should(matcher = nil)
      if matcher
        matcher.match self
      else
        PositiveOperatorMatcher.new self
      end
    end

    def should_not(matcher = nil)
      if matcher
        matcher.not_match self
      else
        NegativeOperatorMatcher.new self
      end
    end
  end
end

class Object
  include OSpec::Expectations
end
