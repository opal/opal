# backtick_javascript: true

# This file contains parts of https://github.com/ruby/ruby/blob/master/lib/cgi/util.rb
# licensed under a Ruby license.

class CGI
  module Util
    # URL-encode a string into application/x-www-form-urlencoded.
    # Space characters (+" "+) are encoded with plus signs (+"+"+)
    #   url_encoded_string = CGI.escape("'Stop!' said Fred")
    #      # => "%27Stop%21%27+said+Fred"
    def escape(c)
      `encodeURI(c)`
    end

    # URL-decode an application/x-www-form-urlencoded string with encoding(optional).
    #   string = CGI.unescape("%27Stop%21%27+said+Fred")
    #      # => "'Stop!' said Fred"
    def unescape(c)
      `decodeURI(c)`
    end

    # URL-encode a string following RFC 3986
    # Space characters (+" "+) are encoded with (+"%20"+)
    #   url_encoded_string = CGI.escapeURIComponent("'Stop!' said Fred")
    #      # => "%27Stop%21%27%20said%20Fred"
    def escapeURIComponent(c)
      `encodeURIComponent(c)`
    end

    # URL-decode a string following RFC 3986 with encoding(optional).
    #   string = CGI.unescapeURIComponent("%27Stop%21%27+said%20Fred")
    #      # => "'Stop!'+said Fred"
    def unescapeURIComponent(c)
      `decodeURIComponent(c)`
    end

    # The set of special characters and their escaped values
    TABLE_FOR_ESCAPE_HTML__ = {
      "'" => '&#39;',
      '&' => '&amp;',
      '"' => '&quot;',
      '<' => '&lt;',
      '>' => '&gt;',
    }

    # Escape special characters in HTML, namely '&\"<>
    #   CGI.escapeHTML('Usage: foo "bar" <baz>')
    #      # => "Usage: foo &quot;bar&quot; &lt;baz&gt;"
    def escapeHTML(string)
      string.gsub(/['&"<>]/, TABLE_FOR_ESCAPE_HTML__)
    end

    # Unescape a string that has been HTML-escaped
    #   CGI.unescapeHTML("Usage: foo &quot;bar&quot; &lt;baz&gt;")
    #      # => "Usage: foo \"bar\" <baz>"
    def unescapeHTML(string)
      string.gsub(/&(apos|amp|quot|gt|lt|\#[0-9]+|\#[xX][0-9A-Fa-f]+);/) do
        match = ::Regexp.last_match(1)
        case match
        when 'apos'                then "'"
        when 'amp'                 then '&'
        when 'quot'                then '"'
        when 'gt'                  then '>'
        when 'lt'                  then '<'
        when /\A#0*(\d+)\z/
          n = ::Regexp.last_match(1).to_i
          n.chr('utf-8')
        when /\A#x([0-9a-f]+)\z/i
          n = ::Regexp.last_match(1).hex
          n.chr('utf-8')
        else
          "&#{match};"
        end
      end
    end

    # Synonym for CGI.escapeHTML(str)
    alias escape_html escapeHTML

    # Synonym for CGI.unescapeHTML(str)
    alias unescape_html unescapeHTML

    alias h escapeHTML
  end

  include Util
  extend Util
end
