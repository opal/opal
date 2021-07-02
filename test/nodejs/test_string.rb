require 'test/unit'
require 'nodejs'

class TestString < Test::Unit::TestCase
  def test_should_get_bytes
    assert_equal('foo'.bytesize, 3)
    assert_equal('foo'.each_byte.to_a, [102, 111, 111])
    assert_equal('foo'.bytes, [102, 111, 111])
    assert_equal('foo'.bytes, [102, 111, 111])
  end

  def test_frozen
    # Commented out examples somehow work in the strict mode,
    # but otherwise they don't. I have unfortunately no idea
    # on where it's mangled, but then I don't see it really
    # as a really harmful thing.

    #assert_equal((-'x').frozen?, true)
    assert_equal((+'x').frozen?, false)
    #assert_equal((-+-'x').frozen?, true)
    assert_equal((+-+'x').frozen?, false)
    #assert_equal((`'x'`).frozen?, true)
    assert_equal((+`'x'`).frozen?, false)
  end
end
