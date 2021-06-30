require 'test/unit'
require 'promise/v2'

class TestPromiseWhen < Test::Unit::TestCase
  def test_calls_the_block_with_all_promises_results
    a = PromiseV2.new
    b = PromiseV2.new

    x = 42

    p = PromiseV2.when(a, b).then {|y, z|
      x = y + z
    }

    a.resolve(1)
    b.resolve(2)

    p.always { assert_equal(x, 3) }
  end

  def test_can_be_built_lazily
    a = PromiseV2.new
    b = PromiseV2.value(3)

    x = 42

    p = PromiseV2.when(a).and(b).then {|c, d|
      x = c + d
    }

    a.resolve(2)

    p.always { assert_equal(x, 5) }
  end
end
