module OSpec
  class EqualMatcher < Matcher
    def match(expected)
      unless expected.equal? @actual
        failure "expected #{@actual.inspect} to be the same as #{expected.inspect}."
      end
    end

    def not_match(expected)
      if expected.equal? @actual
        failure "expected #{@actual.inspect} not to be equal to #{expected.inspect}."
      end
    end
  end
end

class Object
  def equal(expected)
    OSpec::EqualMatcher.new expected
  end
end
