require 'test/unit'
require 'promise'

class TestPromiseRescue < Test::Unit::TestCase
  def test_calls_the_block_when_the_promise_has_already_been_rejected
    x = 42
    Promise.error(23)
      .rescue { |v| x = v }
      .always { assert_equal(x, 23) }
  end

  def test_calls_the_block_when_the_promise_is_rejected
    a = Promise.new
    x = 42

    pr = a.rescue { |v| x = v }
    a.reject(23)

    pr.always { assert_equal(x, 23) }
  end

  def test_does_not_call_then_blocks_when_the_promise_is_rejected
    x = 42
    y = 23

    Promise.error(23).then { y = 42 }.rescue { |v| x = v }.always do
      assert_equal(x, 23)
      assert_equal(y, 23)
    end
  end

  def test_does_not_call_subsequent_rescue_blocks
    x = 42
    Promise.error(23).rescue { |v| x = v }.rescue { x = 42 }.always do
      assert_equal(x, 23)
    end
  end

  def test_can_be_called_multiple_times_on_the_same_promise
    p = Promise.error(2)
    x = 1

    ps = []

    ps << p.then { x += 1 }.rescue{}
    ps << p.rescue { x += 3 }
    ps << p.rescue { x += 3 }

    Promise.when(ps).always { assert_equal(x, 7) }
  end

  def test_raises_with_rescueB_if_a_promise_has_already_been_chained
    p = Promise.new

    p.then! {}

    assert_raise(ArgumentError) { p.rescue! {} }
  end
end
