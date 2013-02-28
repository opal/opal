module OSpec
  class BeNilMatcher < Matcher
    def match(expected)
      unless expected.nil?
        failure "expected #{expected.inspect} to be nil."
      end
    end
  end

  class BeTrueMatcher < Matcher
    def match(expected)
      unless expected == true
        failure "expected #{expected.inspect} to be true."
      end
    end
  end

  class BeFalseMatcher < Matcher
    def match(expected)
      unless expected == false
        failure "expected #{expected.inspect} to be false."
      end
    end
  end
end

class Object
  def be_nil
    OSpec::BeNilMatcher.new nil
  end

  def be_true
    OSpec::BeTrueMatcher.new true
  end

  def be_false
    OSpec::BeFalseMatcher.new false
  end
end
