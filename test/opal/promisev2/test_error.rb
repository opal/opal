require 'test/unit'
require 'promise/v2'

class TestPromiseError < Test::Unit::TestCase
  def test_rejects_the_promise_with_the_given_error
    prom = PromiseV2.error(23)
    assert_equal(prom.error, 23)
    prom.rescue{} # Needed, otherwise we have an uncaught exception
  end

  def test_marks_the_promise_as_realized
    prom = PromiseV2.error(23)
    assert_equal(prom.realized?, true)
    prom.rescue{} # Needed, otherwise we have an uncaught exception
  end

  def test_marks_the_promise_as_rejected
    prom = PromiseV2.error(23)
    assert_equal(prom.rejected?, true)
    prom.rescue{}
  end
end
