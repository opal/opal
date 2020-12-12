require 'test/unit'
require 'nodejs'
require 'nodejs/file'

class TestNodejsFileEncoding < Test::Unit::TestCase

  def test_force_encoding_raw_text_to_utf8
    raw_text = 'çéà'
    assert_equal(raw_text.encoding, Encoding::UTF_8)
    utf8_text = raw_text.force_encoding('utf-8')
    assert_equal("çéà", utf8_text)
  end

  def test_force_encoding_from_binary_to_utf8
    raw_text = "\xC3\xA7\xC3\xA9\xC3\xA0"
    assert_equal(raw_text.encoding, Encoding::UTF_8)
    utf8_text = raw_text.force_encoding('utf-8')
    assert_equal("çéà", utf8_text)
  end
end