module MatchHelpers
  class MatchMatcher
    def initialize(expected)
      fail "Expected #{expected} to be a Regexp!" unless expected.is_a?(Regexp)
      @expected = expected
    end

    def matches?(actual)
      @actual = actual
      @expected.match(@actual)
    end

    def failure_message
      ["Expected #{@actual.inspect} (#{@actual.class})",
       "to match #{@expected}"]
    end

    def negative_failure_message
      ["Expected #{@actual.inspect} (#{@actual.class})",
       "not to match #{@expected}"]
    end
  end

  class EndWithHelper
    def initialize(expected)
      @expected = expected
    end

    def matches?(actual)
      @actual = actual
      @actual.end_with?(@expected)
    end

    def failure_message
      ["Expected #{@actual.inspect} (#{@actual.class})",
       "to end with #{@expected}"]
    end

    def negative_failure_message
      ["Expected #{@actual.inspect} (#{@actual.class})",
       "not to end with #{@expected}"]
    end
  end
end

if !defined? RSpec
  class Object
    def match(expected)
      MatchHelpers::MatchMatcher.new(expected)
    end

    def end_with(expected)
      MatchHelpers::EndWithHelper.new(expected)
    end
  end
end

