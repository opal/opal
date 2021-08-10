require 'test/unit'
require 'promise/v2'

class TestPromiseTrace < Test::Unit::TestCase
  def test_calls_the_block_with_all_the_previous_results
    x = 42

    PromiseV2.value(1)
      .then { 2 }
      .then { 3 }
      .trace {|a, b, c| x = a + b + c }
      .always { assert_equal(x, 6) }
  end

  def test_calls_the_then_after_the_trace
    x = 42

    PromiseV2.value(1)
      .then { 2 }
      .then { 3 }
      .trace { |a, b, c| a + b + c }
      .then { |v| x = v }
      .always { assert_equal(x, 6) }
  end

  def test_includes_the_first_value
    x = 42

    PromiseV2.value(1)
      .trace { |a| x = a }
      .always { assert_equal(x, 1) }
  end

  def test_works_after_a_when
    x = 42

    PromiseV2.value(1).then {
      PromiseV2.when PromiseV2.value(2), PromiseV2.value(3)
    }.trace {|a, b|
      #x = a + b[0] + b[1]
      x = "#{a},#{b}"
    }.always { assert_equal(x, "1,native") } # 6
  end

  def test_raises_with_traceB_if_a_promise_has_already_been_chained
    p = PromiseV2.new

    p.then! {}

    assert_raise(ArgumentError) { p.trace! {} }
  end
end
