require 'test/unit'
require 'promise/v2'

class TestPromiseError < Test::Unit::TestCase
  def test_rejects_the_promise_with_the_given_error
    assert_equal(PromiseV2.error(23).error, 23)
  end

  def test_marks_the_promise_as_realized
    assert_equal(PromiseV2.error(23).realized?, true)
  end

  def test_marks_the_promise_as_rejected
    assert_equal(PromiseV2.error(23).rejected?, true)
  end
end
