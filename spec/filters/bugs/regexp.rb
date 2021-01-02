# NOTE: run bin/format-filters after changing this file
opal_filter "regular_expressions" do
  fails "MatchData#inspect returns a human readable representation of named captures" # Exception: named captures are not supported in javascript: "(?<first>\w+)\s+(?<last>\w+)\s+(\w+)"
  fails "MatchData#regexp returns a Regexp for the result of gsub(String)" # Expected /\[/gm == /\[/ to be truthy but was false
  fails "MatchData#string returns a frozen copy of the matched string for gsub(String)" # NotImplementedError: String#gsub! not supported. Mutable String methods are not supported in Opal.
  fails "Regexp#encoding allows otherwise invalid characters if NOENCODING is specified" # NameError: uninitialized constant Regexp::NOENCODING
  fails "Regexp#encoding defaults to US-ASCII if the Regexp contains only US-ASCII character"
  fails "Regexp#encoding defaults to UTF-8 if \\u escapes appear"
  fails "Regexp#encoding defaults to UTF-8 if a literal UTF-8 character appears"
  fails "Regexp#encoding ignores the default_internal encoding"
  fails "Regexp#encoding ignores the encoding and uses US-ASCII if the string has only ASCII characters"
  fails "Regexp#encoding returns ASCII-8BIT if the 'n' modifier is supplied and non-US-ASCII characters are present"
  fails "Regexp#encoding returns BINARY if the 'n' modifier is supplied and non-US-ASCII characters are present" # NoMethodError: undefined method `encoding' for /\xc2\xa1/
  fails "Regexp#encoding returns EUC_JP if the 'e' modifier is supplied"
  fails "Regexp#encoding returns US_ASCII if the 'n' modifier is supplied and only US-ASCII characters are present"
  fails "Regexp#encoding returns UTF-8 if the 'u' modifier is supplied"
  fails "Regexp#encoding returns Windows-31J if the 's' modifier is supplied"
  fails "Regexp#encoding returns an Encoding object"
  fails "Regexp#encoding upgrades the encoding to that of an embedded String"
  fails "Regexp#fixed_encoding? returns false by default"
  fails "Regexp#fixed_encoding? returns false if the 'n' modifier was supplied to the Regexp"
  fails "Regexp#fixed_encoding? returns true if the 'e' modifier was supplied to the Regexp"
  fails "Regexp#fixed_encoding? returns true if the 's' modifier was supplied to the Regexp"
  fails "Regexp#fixed_encoding? returns true if the 'u' modifier was supplied to the Regexp"
  fails "Regexp#fixed_encoding? returns true if the Regexp contains a UTF-8 literal"
  fails "Regexp#fixed_encoding? returns true if the Regexp contains a \\u escape"
  fails "Regexp#fixed_encoding? returns true if the Regexp was created with the Regexp::FIXEDENCODING option"
  fails "Regexp#hash is based on the text and options of Regexp"
  fails "Regexp#hash returns the same value for two Regexps differing only in the /n option"
  fails "Regexp#initialize raises a SecurityError on a Regexp literal"
  fails "Regexp#initialize raises a TypeError on an initialized non-literal Regexp"
  fails "Regexp#inspect does not include a character set code"
  fails "Regexp#inspect does not include the 'o' option"
  fails "Regexp#inspect returns options in the order 'mixn'"
  fails "Regexp#named_captures returns a Hash"
  fails "Regexp#named_captures returns an empty Hash when there are no capture groups"
  fails "Regexp#named_captures sets each element of the Array to the corresponding group's index"
  fails "Regexp#named_captures sets the keys of the Hash to the names of the capture groups"
  fails "Regexp#named_captures sets the values of the Hash to Arrays"
  fails "Regexp#named_captures works with duplicate capture group names"
  fails "Regexp#names returns all of the named captures"
  fails "Regexp#names returns an Array"
  fails "Regexp#names returns an empty Array if there are no named captures"
  fails "Regexp#names returns each capture name only once"
  fails "Regexp#names returns each named capture as a String"
  fails "Regexp#names works with nested named captures"
  fails "Regexp#source will remove escape characters" # Expected "foo\\/bar" to equal "foo/bar"
  fails "Regexp#to_s deals properly with the two types of lookahead groups"
  fails "Regexp#to_s returns a string in (?xxx:yyy) notation"
  fails "Regexp#to_s shows all options as excluded if none are selected"
  fails "Regexp#to_s shows non-included options after a - sign"
  fails "Regexp#to_s shows the pattern after the options"
  fails "Regexp.compile given a Regexp does not honour options given as additional arguments" # Expected warning to match: /flags ignored/ but got: ""
  fails "Regexp.compile given a String accepts a Fixnum of two or more options ORed together as the second argument" # Expected 0 not to equal 0
  fails "Regexp.compile given a String accepts an Integer of two or more options ORed together as the second argument" # Expected 0 == 0 to be falsy but was true
  fails "Regexp.compile given a String ignores the third argument if it is 'e' or 'euc' (case-insensitive)" # ArgumentError: [Regexp.new] wrong number of arguments(3 for -2)
  fails "Regexp.compile given a String ignores the third argument if it is 's' or 'sjis' (case-insensitive)" # ArgumentError: [Regexp.new] wrong number of arguments(3 for -2)
  fails "Regexp.compile given a String ignores the third argument if it is 'u' or 'utf8' (case-insensitive)" # ArgumentError: [Regexp.new] wrong number of arguments(3 for -2)
  fails "Regexp.compile given a String raises a RegexpError when passed an incorrect regexp" # Exception: Invalid regular expression: /^[$/: Unterminated character class
  fails "Regexp.compile given a String uses ASCII_8BIT encoding if third argument is 'n' or 'none' (case insensitive) and non-ascii characters" # ArgumentError: [Regexp.new] wrong number of arguments(3 for -2)
  fails "Regexp.compile given a String uses US_ASCII encoding if third argument is 'n' or 'none' (case insensitive) and only ascii characters" # ArgumentError: [Regexp.new] wrong number of arguments(3 for -2)
  fails "Regexp.compile given a String with escaped characters raises a RegexpError if \\x is not followed by any hexadecimal digits" # Expected RegexpError but no exception was raised (/\xn/ was returned)
  fails "Regexp.compile given a String with escaped characters raises a RegexpError if less than four digits are given for \\uHHHH" # Expected RegexpError but no exception was raised (/\u304/ was returned)
  fails "Regexp.compile given a String with escaped characters raises a RegexpError if more than six hexadecimal digits are given" # Expected RegexpError but no exception was raised (/\u{0ffffff}/ was returned)
  fails "Regexp.compile given a String with escaped characters raises a RegexpError if the \\u{} escape is empty" # Expected RegexpError but no exception was raised (/\u{}/ was returned)
  fails "Regexp.compile given a String with escaped characters returns a Regexp with US-ASCII encoding if UTF-8 escape sequences using only 7-bit ASCII are present" # NoMethodError: undefined method `encoding' for /a/
  fails "Regexp.compile given a String with escaped characters returns a Regexp with US-ASCII encoding if only 7-bit ASCII characters are present regardless of the input String's encoding" # NoMethodError: undefined method `encoding' for /abc/
  fails "Regexp.compile given a String with escaped characters returns a Regexp with UTF-8 encoding if any UTF-8 escape sequences outside 7-bit ASCII are present" # NoMethodError: undefined method `encoding' for /ÿ/
  fails "Regexp.compile given a String with escaped characters returns a Regexp with source String having US-ASCII encoding if UTF-8 escape sequences using only 7-bit ASCII are present" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Regexp.compile given a String with escaped characters returns a Regexp with source String having US-ASCII encoding if only 7-bit ASCII characters are present regardless of the input String's encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "Regexp.compile given a String with escaped characters returns a Regexp with source String having the input String's encoding" # NameError: uninitialized constant Encoding::Shift_JIS
  fails "Regexp.compile given a String with escaped characters returns a Regexp with the input String's encoding" # NameError: uninitialized constant Encoding::Shift_JIS
  fails "Regexp.compile works by default for subclasses with overridden #initialize" # Expected /hi/ (Regexp) to be kind of RegexpSpecsSubclass
  fails "Regexp.escape sets the encoding of the result to BINARY if any non-US-ASCII characters are present in an input String with invalid encoding" # Expected true to be false
  fails "Regexp.last_match returns nil when there is no match" # NoMethodError: undefined method `[]' for nil
  fails "Regexp.last_match when given a String returns a named capture" # Exception: named captures are not supported in javascript: "(?<test>[A-Z]+.*)"
  fails "Regexp.last_match when given a Symbol raises an IndexError when given a missing name" # Exception: named captures are not supported in javascript: "(?<test>[A-Z]+.*)"
  fails "Regexp.last_match when given a Symbol returns a named capture" # Exception: named captures are not supported in javascript: "(?<test>[A-Z]+.*)"
  fails "Regexp.last_match when given an Object coerces argument to an index using #to_int" # Exception: named captures are not supported in javascript: "(?<test>[A-Z]+.*)"
  fails "Regexp.last_match when given an Object raises a TypeError when unable to coerce" # Exception: named captures are not supported in javascript: "(?<test>[A-Z]+.*)"
  fails "Regexp.new given a String accepts an Integer of two or more options ORed together as the second argument" # Expected 0 == 0 to be falsy but was true
  fails "Regexp.new given a String raises a RegexpError when passed an incorrect regexp"
  fails "Regexp.new given a String with escaped characters raises a RegexpError if \\x is not followed by any hexadecimal digits"
  fails "Regexp.new given a String with escaped characters raises a RegexpError if more than six hexadecimal digits are given"
  fails "Regexp.new works by default for subclasses with overridden #initialize"
  fails "Regexp.quote sets the encoding of the result to BINARY if any non-US-ASCII characters are present in an input String with invalid encoding" # Expected true to be false
  fails "Regexp.try_convert returns nil if given an argument that can't be converted to a Regexp"
  fails "Regexp.try_convert tries to coerce the argument by calling #to_regexp"
  fails "Regexp.union uses to_regexp to convert argument" # Mock 'pattern' expected to receive to_regexp("any_args") exactly 1 times but received it 0 times
end
