# test/unit compatibility layer using minitest.

require 'minitest/autorun'
module Test
  module Unit
    class TestCase < Minitest::Test
      alias assert_raise assert_raises

      def assert_nothing_raised(*)
        yield
      end

      def assert_raise_with_message(exception, err_message, msg = nil)
        err = assert_raises(exception, msg) { yield }
        if err_message.is_a?(Regexp)
          assert_matches err_message, err.message
        else
          assert_equal err_message, err.message
        end
      end
    end
  end
end
