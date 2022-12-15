# NOTE: run bin/format-filters after changing this file
opal_filter "regular_expressions" do
  fails "MatchData#regexp returns a Regexp for the result of gsub(String)" # Expected /\[/gm == /\[/ to be truthy but was false
  fails "MatchData#string returns a frozen copy of the matched string for gsub(String)" # NotImplementedError: String#gsub! not supported. Mutable String methods are not supported in Opal.
  fails "MatchData.allocate is undefined" # Expected NoMethodError but no exception was raised (#<MatchData>(#pretty_inspect raised #<NoMethodError: undefined method `named_captures' for nil>) was returned)  
  fails "Regexp#encoding allows otherwise invalid characters if NOENCODING is specified" # NameError: uninitialized constant Regexp::NOENCODING
  fails "Regexp#encoding defaults to US-ASCII if the Regexp contains only US-ASCII character" # NoMethodError: undefined method `encoding' for /ASCII/
  fails "Regexp#encoding defaults to UTF-8 if \\u escapes appear" # NoMethodError: undefined method `encoding' for /\u{9879}/
  fails "Regexp#encoding defaults to UTF-8 if a literal UTF-8 character appears" # NoMethodError: undefined method `encoding' for /¥/
  fails "Regexp#encoding ignores the default_internal encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "Regexp#encoding ignores the encoding and uses US-ASCII if the string has only ASCII characters" # ArgumentError: unknown encoding name - euc-jp
  fails "Regexp#encoding returns BINARY if the 'n' modifier is supplied and non-US-ASCII characters are present" # NoMethodError: undefined method `encoding' for /\xc2\xa1/
  fails "Regexp#encoding returns EUC_JP if the 'e' modifier is supplied" # NoMethodError: undefined method `encoding' for /ASCII/
  fails "Regexp#encoding returns US_ASCII if the 'n' modifier is supplied and only US-ASCII characters are present" # NoMethodError: undefined method `encoding' for /ASCII/
  fails "Regexp#encoding returns UTF-8 if the 'u' modifier is supplied" # NoMethodError: undefined method `encoding' for /ASCII/u
  fails "Regexp#encoding returns Windows-31J if the 's' modifier is supplied" # NoMethodError: undefined method `encoding' for /ASCII/
  fails "Regexp#encoding returns an Encoding object" # NoMethodError: undefined method `encoding' for /glar/
  fails "Regexp#encoding upgrades the encoding to that of an embedded String" # ArgumentError: unknown encoding name - euc-jp
  fails "Regexp#fixed_encoding? returns false by default" # NoMethodError: undefined method `fixed_encoding?' for /needle/
  fails "Regexp#fixed_encoding? returns false if the 'n' modifier was supplied to the Regexp" # NoMethodError: undefined method `fixed_encoding?' for /needle/
  fails "Regexp#fixed_encoding? returns true if the 'e' modifier was supplied to the Regexp" # NoMethodError: undefined method `fixed_encoding?' for /needle/
  fails "Regexp#fixed_encoding? returns true if the 's' modifier was supplied to the Regexp" # NoMethodError: undefined method `fixed_encoding?' for /needle/
  fails "Regexp#fixed_encoding? returns true if the 'u' modifier was supplied to the Regexp" # NoMethodError: undefined method `fixed_encoding?' for /needle/u
  fails "Regexp#fixed_encoding? returns true if the Regexp contains a UTF-8 literal" # NoMethodError: undefined method `fixed_encoding?' for /文字化け/
  fails "Regexp#fixed_encoding? returns true if the Regexp contains a \\u escape" # NoMethodError: undefined method `fixed_encoding?' for /needle \u{8768}/
  fails "Regexp#fixed_encoding? returns true if the Regexp was created with the Regexp::FIXEDENCODING option" # NameError: uninitialized constant Regexp::FIXEDENCODING
  fails "Regexp#hash is based on the text and options of Regexp" # Expected false == true to be truthy but was false
  fails "Regexp#hash returns the same value for two Regexps differing only in the /n option" # Expected false == true to be truthy but was false
  fails "Regexp#initialize raises a TypeError on an initialized non-literal Regexp" # Expected TypeError but no exception was raised (nil was returned)
  fails "Regexp#inspect does not include a character set code" # Expected "/(?:)/" == "//" to be truthy but was false
  fails "Regexp#inspect does not include the 'o' option" # Expected "/(?:)/" == "//" to be truthy but was false
  fails "Regexp#inspect returns options in the order 'mixn'" # Expected "/(?:)/" == "//mixn" to be truthy but was false
  fails "Regexp#named_captures works with duplicate capture group names" # Exception: Invalid regular expression: /this (?<is>is) [aA] (?<pat>pate?(?<is>rn))/: Duplicate capture group name
  fails "Regexp#names returns each capture name only once" # Exception: Invalid regular expression: /n(?<cap>ee)d(?<cap>le)/: Duplicate capture group name
  fails "Regexp#to_s deals properly with the two types of lookahead groups" # Expected "(?=5)" == "(?-mix:(?=5))" to be truthy but was false
  fails "Regexp#to_s returns a string in (?xxx:yyy) notation" # Expected "(?:.)" == "(?-mix:.)" to be truthy but was false
  fails "Regexp#to_s shows all options as excluded if none are selected" # Expected "abc" == "(?-mix:abc)" to be truthy but was false
  fails "Regexp#to_s shows non-included options after a - sign" # Expected "abc" == "(?i-mx:abc)" to be truthy but was false
  fails "Regexp#to_s shows the pattern after the options" # Expected "xyz" == "(?-mix:xyz)" to be truthy but was false
  fails "Regexp.compile given a Regexp does not honour options given as additional arguments" # Expected warning to match: /flags ignored/ but got: ""
  fails "Regexp.compile given a String accepts an Integer of two or more options ORed together as the second argument" # Expected 0 == 0 to be falsy but was true
  fails "Regexp.compile given a String ignores the third argument if it is 'e' or 'euc' (case-insensitive)" # ArgumentError: [Regexp.new] wrong number of arguments (given 3, expected -2)
  fails "Regexp.compile given a String ignores the third argument if it is 's' or 'sjis' (case-insensitive)" # ArgumentError: [Regexp.new] wrong number of arguments (given 3, expected -2)
  fails "Regexp.compile given a String ignores the third argument if it is 'u' or 'utf8' (case-insensitive)" # ArgumentError: [Regexp.new] wrong number of arguments (given 3, expected -2)
  fails "Regexp.compile given a String raises a RegexpError when passed an incorrect regexp" # Expected RegexpError but got: Exception (Invalid regular expression: /^[$/: Unterminated character class)
  fails "Regexp.compile given a String uses ASCII_8BIT encoding if third argument is 'n' or 'none' (case insensitive) and non-ascii characters" # ArgumentError: [Regexp.new] wrong number of arguments (given 3, expected -2)
  fails "Regexp.compile given a String uses US_ASCII encoding if third argument is 'n' or 'none' (case insensitive) and only ascii characters" # ArgumentError: [Regexp.new] wrong number of arguments (given 3, expected -2)
  fails "Regexp.compile given a String with escaped characters raises a RegexpError if \\x is not followed by any hexadecimal digits" # Expected RegexpError but no exception was raised (/\xn/ was returned)
  fails "Regexp.compile given a String with escaped characters raises a RegexpError if less than four digits are given for \\uHHHH" # Expected RegexpError but no exception was raised (/\u304/ was returned)
  fails "Regexp.compile given a String with escaped characters raises a RegexpError if more than six hexadecimal digits are given" # Expected RegexpError but no exception was raised (/\u{0ffffff}/ was returned)
  fails "Regexp.compile given a String with escaped characters raises a RegexpError if the \\u{} escape is empty" # Expected RegexpError but no exception was raised (/\u{}/ was returned)
  fails "Regexp.compile given a String with escaped characters returns a Regexp with US-ASCII encoding if UTF-8 escape sequences using only 7-bit ASCII are present" # NoMethodError: undefined method `encoding' for /a/
  fails "Regexp.compile given a String with escaped characters returns a Regexp with US-ASCII encoding if only 7-bit ASCII characters are present regardless of the input String's encoding" # NoMethodError: undefined method `encoding' for /abc/
  fails "Regexp.compile given a String with escaped characters returns a Regexp with UTF-8 encoding if any UTF-8 escape sequences outside 7-bit ASCII are present" # NoMethodError: undefined method `encoding' for /ÿ/
  fails "Regexp.compile given a String with escaped characters returns a Regexp with source String having US-ASCII encoding if UTF-8 escape sequences using only 7-bit ASCII are present" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "Regexp.compile given a String with escaped characters returns a Regexp with source String having US-ASCII encoding if only 7-bit ASCII characters are present regardless of the input String's encoding" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "Regexp.compile given a String with escaped characters returns a Regexp with source String having the input String's encoding" # NameError: uninitialized constant Encoding::Shift_JIS
  fails "Regexp.compile given a String with escaped characters returns a Regexp with the input String's encoding" # NameError: uninitialized constant Encoding::Shift_JIS
  fails "Regexp.compile works by default for subclasses with overridden #initialize" # Expected /hi/ (Regexp) to be kind of RegexpSpecsSubclass
  fails "Regexp.escape sets the encoding of the result to BINARY if any non-US-ASCII characters are present in an input String with invalid encoding" # Expected true to be false
  fails "Regexp.new given a String accepts an Integer of two or more options ORed together as the second argument" # Expected 0 == 0 to be falsy but was true
  fails "Regexp.new given a String raises a RegexpError when passed an incorrect regexp" # Expected RegexpError but got: Exception (Invalid regular expression: /^[$/: Unterminated character class)
  fails "Regexp.new given a String with escaped characters raises a RegexpError if \\x is not followed by any hexadecimal digits" # Expected RegexpError but no exception was raised (/\xn/ was returned)
  fails "Regexp.new given a String with escaped characters raises a RegexpError if more than six hexadecimal digits are given" # Expected RegexpError but no exception was raised (/\u{0ffffff}/ was returned)
  fails "Regexp.new given a non-String/Regexp raises TypeError if #to_str returns non-String value" # Expected TypeError (/can't convert Object to String/) but got: TypeError (can't convert Object into String (Object#to_str gives Array))
  fails "Regexp.new given a non-String/Regexp raises TypeError if there is no #to_str method for non-String/Regexp argument" # Expected TypeError (no implicit conversion of Integer into String) but got: TypeError (no implicit conversion of Number into String)
  fails "Regexp.new works by default for subclasses with overridden #initialize" # Expected /hi/ (Regexp) to be kind of RegexpSpecsSubclass
  fails "Regexp.quote sets the encoding of the result to BINARY if any non-US-ASCII characters are present in an input String with invalid encoding" # Expected true to be false
  fails "Regexp.try_convert returns nil if given an argument that can't be converted to a Regexp" # NoMethodError: undefined method `try_convert' for Regexp
  fails "Regexp.try_convert tries to coerce the argument by calling #to_regexp" # Mock 'regexp' expected to receive to_regexp("any_args") exactly 1 times but received it 0 times
  fails "Regexp.union uses to_regexp to convert argument" # Mock 'pattern' expected to receive to_regexp("any_args") exactly 1 times but received it 0 times
end
