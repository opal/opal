# NOTE: run bin/format-filters after changing this file
opal_filter "CGI" do
  fails "CGI#http_header CGI#http_header when passed Hash includes Cookies in the @output_cookies field" # NoMethodError: undefined method `http_header' for #<CGI:0x98198 @output_cookies=["multiple", "cookies"]>
  fails "CGI#http_header CGI#http_header when passed Hash returns a HTTP header based on the Hash's key/value pairs" # NoMethodError: undefined method `http_header' for #<CGI:0x98194>
  fails "CGI#http_header CGI#http_header when passed Hash returns a HTTP header specifying the Content-Type as text/html when passed an empty Hash" # NoMethodError: undefined method `http_header' for #<CGI:0x98190>
  fails "CGI#http_header CGI#http_header when passed String includes Cookies in the @output_cookies field" # NoMethodError: undefined method `http_header' for #<CGI:0x98186 @output_cookies=["multiple", "cookies"]>
  fails "CGI#http_header CGI#http_header when passed String returns a HTTP header specifying the Content-Type as the passed String's content" # NoMethodError: undefined method `http_header' for #<CGI:0x9818c>
  fails "CGI#http_header CGI#http_header when passed no arguments includes Cookies in the @output_cookies field" # NoMethodError: undefined method `http_header' for #<CGI:0x9817c @output_cookies=["multiple", "cookies"]>
  fails "CGI#http_header CGI#http_header when passed no arguments returns a HTTP header specifying the Content-Type as text/html" # NoMethodError: undefined method `http_header' for #<CGI:0x98182>
  fails "CGI#initialize is private" # Expected CGI to have private instance method 'initialize' but it does not
  fails "CGI#initialize when passed no arguments does not extend self with CGI::HtmlExtension" # NameError: uninitialized constant CGI::HtmlExtension
  fails "CGI#initialize when passed no arguments does not extend self with any of the other HTML modules" # NameError: uninitialized constant CGI::Html3
  fails "CGI#initialize when passed no arguments extends self with CGI::QueryExtension" # NameError: uninitialized constant CGI::QueryExtension
  fails "CGI#initialize when passed no arguments sets #cookies based on ENV['HTTP_COOKIE']" # NoMethodError: undefined method `cookies' for #<CGI:0x12604>
  fails "CGI#initialize when passed no arguments sets #params based on ENV['QUERY_STRING'] when ENV['REQUEST_METHOD'] is GET" # NoMethodError: undefined method `params' for #<CGI:0x12614>
  fails "CGI#initialize when passed no arguments sets #params based on ENV['QUERY_STRING'] when ENV['REQUEST_METHOD'] is HEAD" # NoMethodError: undefined method `params' for #<CGI:0x12600>
  fails "CGI#initialize when passed type extends self with CGI::QueryExtension" # NameError: uninitialized constant CGI::QueryExtension
  fails "CGI#initialize when passed type extends self with CGI::QueryExtension, CGI::Html3 and CGI::HtmlExtension when the passed type is 'html3'" # NameError: uninitialized constant CGI::Html3
  fails "CGI#initialize when passed type extends self with CGI::QueryExtension, CGI::Html4 and CGI::HtmlExtension when the passed type is 'html4'" # NameError: uninitialized constant CGI::Html4
  fails "CGI#initialize when passed type extends self with CGI::QueryExtension, CGI::Html4Tr and CGI::HtmlExtension when the passed type is 'html4Tr'" # NameError: uninitialized constant CGI::Html4Tr
  fails "CGI#initialize when passed type extends self with CGI::QueryExtension, CGI::Html4Tr, CGI::Html4Fr and CGI::HtmlExtension when the passed type is 'html4Fr'" # NameError: uninitialized constant CGI::Html4Tr
  fails "CGI#out appends the block's return value to the HTML header" # NoMethodError: undefined method `out' for #<CGI:0x86a80>
  fails "CGI#out automatically sets the Content-Length Header based on the block's return value" # NoMethodError: undefined method `out' for #<CGI:0x86a8c>
  fails "CGI#out includes Cookies in the @output_cookies field" # NoMethodError: undefined method `out' for #<CGI:0x86a74 @output_cookies=["multiple", "cookies"]>
  fails "CGI#out it writes a HTMl header based on the passed argument to $stdout" # NoMethodError: undefined method `out' for #<CGI:0x86a86>
  fails "CGI#out when passed no block raises a LocalJumpError" # Expected LocalJumpError but got: NoMethodError (undefined method `out' for #<CGI:0x86a96>)
  fails "CGI.escape url-encodes the passed argument" # Expected "%20!%22\#$%25&'()*+,-./0123456789:;%3C=%3E?@ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5C%5D%5E_%60abcdefghijklmnopqrstuvwxyz%7B%7C%7D" == "+%21%22%23%24%25%26%27%28%29%2A%2B%2C-.%2F0123456789%3A%3B%3C%3D%3E%3F%40ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5C%5D%5E_%60abcdefghijklmnopqrstuvwxyz%7B%7C%7D" to be truthy but was false
  fails "CGI.escapeElement when passed String, elements, ... escapes only the tags of the passed elements in the passed String" # NoMethodError: undefined method `escapeElement' for CGI
  fails "CGI.escapeElement when passed String, elements, ... is case-insensitive" # NoMethodError: undefined method `escapeElement' for CGI
  fails "CGI.parse when passed String allows passing multiple values for one key" # NoMethodError: undefined method `parse' for CGI
  fails "CGI.parse when passed String parses a HTTP Query String into a Hash" # NoMethodError: undefined method `parse' for CGI
  fails "CGI.parse when passed String parses query strings with semicolons in place of ampersands" # NoMethodError: undefined method `parse' for CGI
  fails "CGI.parse when passed String unescapes keys and values" # NoMethodError: undefined method `parse' for CGI
  fails "CGI.pretty when passed html indents the passed html String with two spaces" # NoMethodError: undefined method `pretty' for CGI
  fails "CGI.pretty when passed html, indentation_unit indents the passed html String with the passed indentation_unit" # NoMethodError: undefined method `pretty' for CGI
  fails "CGI.rfc1123_date when passed Time returns the passed Time formatted in RFC1123 ('Sat, 01 Dec 2007 15:56:42 GMT')" # NoMethodError: undefined method `rfc1123_date' for CGI
  fails "CGI.unescape url-decodes the passed argument" # Expected "+!\"%23%24%%26'()*%2B%2C-.%2F0123456789%3A%3B<%3D>%3F%40ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~" == " !\"\#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~" to be truthy but was false
  fails "CGI.unescapeElement when passed String, elements, ... is case-insensitive" # NoMethodError: undefined method `unescapeElement' for CGI
  fails "CGI.unescapeElement when passed String, elements, ... unescapes only the tags of the passed elements in the passed String" # NoMethodError: undefined method `unescapeElement' for CGI
end
