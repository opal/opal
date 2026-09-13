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

  def test_foreach_yields_each_line
    File.write('tmp/foreach', "a\nb\nc\n")
    lines = []
    IO.foreach('tmp/foreach') { |line| lines << line }
    assert_equal(["a\n", "b\n", "c\n"], lines)
  end

  def test_foreach_returns_nil_when_given_a_block
    File.write('tmp/foreach', "a\n")
    assert_nil(IO.foreach('tmp/foreach') { |line| line })
  end

  def test_foreach_without_a_block_returns_an_enumerator
    File.write('tmp/foreach', "a\nb\n")
    assert_equal(["a\n", "b\n"], IO.foreach('tmp/foreach').to_a)
  end

  def test_foreach_honours_a_custom_separator
    File.write('tmp/foreach', "a\nb\nc\n")
    lines = []
    IO.foreach('tmp/foreach', 'b') { |line| lines << line }
    assert_equal(["a\nb", "\nc\n"], lines)
  end

  def test_foreach_keeps_a_last_line_without_a_trailing_separator
    File.write('tmp/foreach', 'no-newline')
    assert_equal(['no-newline'], IO.foreach('tmp/foreach').to_a)
  end

  def test_readlines_returns_every_line
    File.write('tmp/readlines', "a\nb\nc\n")
    assert_equal(["a\n", "b\n", "c\n"], IO.readlines('tmp/readlines'))
  end

  def test_readlines_of_an_empty_file
    File.write('tmp/readlines', '')
    assert_equal([], IO.readlines('tmp/readlines'))
  end
end
