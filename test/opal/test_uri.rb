# frozen_string_literal: false

require 'uri'

module URI
  class TestCommon < Test::Unit::TestCase
    def test_decode_www_form
      assert_equal([%w[a 1], %w[a 2]], URI.decode_www_form("a=1&a=2"))
      assert_equal([%w[a 1;a=2]], URI.decode_www_form("a=1;a=2"))
      assert_equal([%w[a 1], ['', ''], %w[a 2]], URI.decode_www_form("a=1&&a=2"))
      assert_raise(ArgumentError){URI.decode_www_form("\u3042")}
      # assert_equal([%w[a 1], ["\u3042", "\u6F22"]],
      #              URI.decode_www_form("a=1&%E3%81%82=%E6%BC%A2"))
      # assert_equal([%w[a 1], ["\uFFFD%8", "\uFFFD"]],
      #              URI.decode_www_form("a=1&%E3%81%8=%E6%BC"))
      assert_equal([%w[?a 1], %w[a 2]], URI.decode_www_form("?a=1&a=2"))
      assert_equal([], URI.decode_www_form(""))
      # assert_equal([%w[% 1]], URI.decode_www_form("%=1"))
      # assert_equal([%w[a %]], URI.decode_www_form("a=%"))
      # assert_equal([%w[a 1], %w[% 2]], URI.decode_www_form("a=1&%=2"))
      # assert_equal([%w[a 1], %w[b %]], URI.decode_www_form("a=1&b=%"))
      assert_equal([['a', ''], ['b', '']], URI.decode_www_form("a&b"))
      bug4098 = '[ruby-core:33464]'
      assert_equal([['a', 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'], ['b', '']], URI.decode_www_form("a=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA&b"), bug4098)

      assert_raise(ArgumentError){ URI.decode_www_form("a=1&%82%A0=%8A%BF", "x-sjis") }
      # assert_equal([["a", "1"], [s("\x82\xA0"), s("\x8a\xBF")]],
      #              URI.decode_www_form("a=1&%82%A0=%8A%BF", "sjis"))
      # assert_equal([["a", "1"], [s("\x82\xA0"), s("\x8a\xBF")], %w[_charset_ sjis], [s("\x82\xA1"), s("\x8a\xC0")]],
      #              URI.decode_www_form("a=1&%82%A0=%8A%BF&_charset_=sjis&%82%A1=%8A%C0", use__charset_: true))
      assert_equal([["", "isindex"], ["a", "1"]],
                   URI.decode_www_form("isindex&a=1", isindex: true))
    end
  end
end
