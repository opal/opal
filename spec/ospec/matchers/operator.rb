module OSpec
  class PositiveOperatorMatcher < Matcher
    def ==(expected)
      if @actual == expected
        true
      else
        failure "expected: #{expected.inspect}, got: #{@actual.inspect} (using ==)."
      end
    end
  end

  class NegativeOperatorMatcher < Matcher
    def ==(expected)
      if @actual == expected
        failure "expected: #{expected.inspect} not to be #{@actual.inspect} (using ==)."
      end
    end
  end
end
