module OSpec
  class BeEmptyMatcher < Matcher
    def match(actual)
      unless actual.empty?
        failure "Expected #{actual.inspect} to be empty"
      end
    end
  end
end

class Object
  def be_empty
    OSpec::BeEmptyMatcher.new
  end
end
