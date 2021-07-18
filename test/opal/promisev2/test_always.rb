require 'test/unit'
require 'promise/v2'

class TestPromiseAlways < Test::Unit::TestCase
  def test_calls_the_block_when_it_was_resolved
    x = 42
    PromiseV2.value(23)
      .then { |v| x = v }
      .always { |v| x = 2 }
      .then { assert_equal(x, 2) }
  end

  def test_calls_the_block_when_it_was_rejected
    x = 42
    PromiseV2.error(23)
      .rescue { |v| x = v }
      .always { |v| x = 2 }
      .always { assert_equal(x, 2) }
  end

  def test_acts_as_resolved
    x = 42
    PromiseV2.error(23)
      .rescue { |v| x = v }
      .always { x = 2 }
      .then { x = 3 }
      .always { assert_equal(x, 3) }
  end

  def test_can_be_called_multiple_times_on_resolved_promises
    p = PromiseV2.value(2)
    x = 1
    ps = []
    ps << p.then { x += 1 }
    ps << p.fail { x += 2 }
    ps << p.always { x += 3 }

    PromiseV2.when(ps).always do
      assert_equal(x, 5)
    end
  end

  def test_can_be_called_multiple_times_on_rejected_promises
    p = PromiseV2.error(2)
    x = 1
    ps = []
    ps << p.then { x += 1 }.fail{}
    ps << p.fail { x += 2 }
    ps << p.always { x += 3 }.fail{}

    PromiseV2.when(ps).then do
      assert_equal(x, 6)
    end
  end

  def test_raises_with_alwaysB_if_a_promise_has_already_been_chained
    p = PromiseV2.new

    p.then! {}

    assert_raise(ArgumentError) { p.always! {} }
  end
end
