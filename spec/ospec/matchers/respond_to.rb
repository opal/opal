module OSpec
  class RespondToMatcher
    def not_match(actual)
      if actual.respond_to?(@expected)
        failure "Expected #{actual.inspect} (#{actual.class}) not to respond to #{@expected}"
      end
    end
  end
end
