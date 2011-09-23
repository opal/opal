require 'test/unit'

class TestIf < Test::Unit::TestCase

  def test_body_evaluation
    a = []
    if true
      a << 123
    end
    assert_equal [123], a

    b = []
    if false
      b << 123
    end
    assert_equal [], b

    c = []
    if ()
      c << 123
    end
    assert_equal [], c

    d = []
    if true
      d << 123
    else
      d << 456
    end
    assert_equal [123], d

    e = []
    if false
      e << 123
    else
      e << 456
    end
    assert_equal [456], e
  end

  def test_body_result
    a = if true
          123
        end
    assert_equal 123, a

    b = if true
          'foo'
          'bar'
          'baz'
        end
    assert_equal 'baz', b

    c = if true
          123
        else
          456
        end
    assert_equal 123, c

    d = if false
          123
        else
          456
        end
    assert_equal 456, d
  end

end

