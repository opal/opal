module OSpec
  class BeKindOfMatcher < Matcher
    def match(expected)
      unless expected.kind_of? @actual
        failure "expected #{expected.inspect} to be a kind of #{@actual.name}, not #{expected.class.name}."
      end
    end
  end
end

class Object
  def be_kind_of(expected)
    OSpec::BeKindOfMatcher.new expected
  end

  def be_an_instance_of(expected)
    be_kind_of expected
  end
end
