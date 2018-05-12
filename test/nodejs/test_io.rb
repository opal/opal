# Copied from cruby and modified to skip unsupported syntaxes
require 'test/unit'
require 'nodejs'
require 'nodejs/io'

class TestNodejsIO < Test::Unit::TestCase

  def test_binread
    File.write('tmp/foo', 'bar')
    assert_equal("bar", IO.binread('tmp/foo'))
  end

  def test_binread_noexistent_should_raise_io_error
    assert_raise IOError do
      IO.binread('tmp/nonexistent')
    end
  end

  def test_binread_encoding
    File.write('tmp/foo', 'Le français c\'est compliqué :)\n')
    assert_equal("Le fran\xC3\xA7ais c'est compliqu\xC3\xA9 :)\\n", IO.binread('tmp/foo'))
    assert_equal("Le français c'est compliqué :)\\n", IO.binread('tmp/foo'))
  end

  def test_binread_image
    assert_equal("iVBORwoaCgAAAApJSERSAAAAEQAAABEIAgAAALQP0K0AAAAaSURBVCiRY/z//z8DiYCJVAqjekb1jOqBAwCKaAMf7iyZAAAAAABJRU5ErkJggg==",
      Base64.strict_encode64(IO.binread('test/cruby/test/cgi/testdata/small.png')))
  end
end
