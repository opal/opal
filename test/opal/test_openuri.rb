# frozen_string_literal: false
require "test/unit"
require "open-uri"

class TestOpenURI < Test::Unit::TestCase
  def test_open_http_plain_text
    open('http://localhost:4567/plain_text') {|f|
      assert_match(/plain text/, f.read)
      assert_equal('text/plain', f.content_type)
    }
  end

  def test_open_http_html_utf8
    open('http://localhost:4567/html') {|f|
      assert_match(/<body>/, f.read)
      assert_equal('text/html', f.content_type)
      assert_equal('utf-8', f.charset)
    }
  end

  def test_open_http_image_png
    #expected = File.open(File.join(File.dirname(__FILE__), 'cat.png'), 'rb').read
    open('http://localhost:4567/png') {|f|
      assert_match(/^\u0089PNG\r\n\u001A\n\u0000\u0000\u0000\rIHDR.*/, f.read)
      assert_equal('image/png', f.content_type)
    }
  end

  def test_open_last_modified
    open('http://localhost:4567/last_modified') {|f|
      assert_equal('Look Ma, I have a Last-Modified header', f.read)
      assert_equal(Time.utc(2015,10,21,7,28,0), f.last_modified)
    }
  end

  def test_open_http_404
    assert_raise(OpenURI::HTTPError) { open('http://localhost:4567/404') }
  end

  def test_open_http_505
    assert_raise(OpenURI::HTTPError) { open('http://localhost:4567/505') }
  end

  def test_open_http_error
    # No HTTP server on port 1234
    assert_raise(OpenURI::HTTPError) { open('http://localhost:1234') }
  end

  def test_open_no_header
    open('http://localhost:4567/no_header') {|f|
      assert_equal('no header', f.read)
    }
  end
end
