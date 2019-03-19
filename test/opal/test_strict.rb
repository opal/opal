# frozen_string_literal: false
require "test/unit"

class TestStrict < Test::Unit::TestCase
  def test_strict_mode
    assert_equal(0, 0.times.size)
  end
end
