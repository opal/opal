require 'test/unit'
require 'nodejs'

class TestNodejsEncoding < Test::Unit::TestCase

  def test_should_get_bytes
    assert_equal('foo'.bytesize, 3)
    assert_equal('foo'.each_byte.to_a, [102, 111, 111])
    assert_equal('foo'.bytes, [102, 111, 111])
    assert_equal('foo'.bytes, [102, 111, 111])
  end
end
