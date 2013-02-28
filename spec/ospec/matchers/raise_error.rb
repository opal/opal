module OSpec
  class RaiseErrorMatcher < Matcher
    def match(block)
      should_raise = false
      begin
        block.call
        should_raise = true
      rescue => e
      end

      if should_raise
        failure "expected #{@actual} to be raised, but nothing was."
      end
    end

    def not_match(block)
      should_raise = false
      begin
        block.call
      rescue => e
        should_raise = true
      end

      if should_raise
        failure "did not expect #{@actual} to be raised."
      end
    end
  end
end

class Object
  def raise_error(expected = Exception, msg = nil)
    OSpec::RaiseErrorMatcher.new expected
  end
end
