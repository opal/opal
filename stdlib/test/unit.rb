# test/unit compatibility layer using minitest.

require 'minitest/autorun'
module Test
  module Unit
    class TestCase < Minitest::Test
    end
  end
end
