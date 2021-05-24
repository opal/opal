require 'test/unit'
require 'promise'

class TestPromiseValue < Test::Unit::TestCase
  def test_resolves_the_promise_with_the_given_value
    assert_equal(Promise.value(23).value, 23)
  end

  def test_marks_the_promise_as_realized
    assert_equal(Promise.value(23).realized?, true)
  end

  def test_marks_the_promise_as_resolved
    assert_equal(Promise.value(23).resolved?, true)
  end
end
