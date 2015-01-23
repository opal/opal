# test/unit compatibility layer using minitest.

require 'minitest/autorun'
module Test
  module Unit
    class TestCase < Minitest::Test
      alias assert_raise assert_raises
    end
  end
end
