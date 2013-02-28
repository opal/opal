module OSpec
  class Matcher
    def initialize(actual)
      @actual = actual
    end

    def failure(message)
      raise OSpec::ExpectationNotMetError, message
    end
  end
end
