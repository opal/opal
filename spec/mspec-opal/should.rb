# use_strict: true

# This files is copied from mspec/expectations/should with the only difference being the
# use_strict above, to ensure, that JavaScript primitives do not get boxed.
# This is important for example for string primitives, to identify if they are frozen or not.
# Where primitive strings are always considered frozen, until they are boxed,
# then they become unfrozen and specs fail.

class Object
  NO_MATCHER_GIVEN = Object.new

  def should(matcher = NO_MATCHER_GIVEN, &block)
    MSpec.expectation
    state = MSpec.current.state
    raise "should outside example" unless state
    MSpec.actions :expectation, state

    if NO_MATCHER_GIVEN.equal?(matcher)
      SpecPositiveOperatorMatcher.new(self)
    else
      # The block was given to #should syntactically, but it was intended for a matcher like #raise_error
      matcher.block = block if block

      unless matcher.matches? self
        expected, actual = matcher.failure_message
        SpecExpectation.fail_with(expected, actual)
      end
    end
  end

  def should_not(matcher = NO_MATCHER_GIVEN, &block)
    MSpec.expectation
    state = MSpec.current.state
    raise "should_not outside example" unless state
    MSpec.actions :expectation, state

    if NO_MATCHER_GIVEN.equal?(matcher)
      SpecNegativeOperatorMatcher.new(self)
    else
      # The block was given to #should_not syntactically, but it was intended for the matcher
      matcher.block = block if block

      if matcher.matches? self
        expected, actual = matcher.negative_failure_message
        SpecExpectation.fail_with(expected, actual)
      end
    end
  end
end
