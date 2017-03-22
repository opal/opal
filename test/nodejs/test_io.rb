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
end
