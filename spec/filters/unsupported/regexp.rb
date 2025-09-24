# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Regexp" do
  fails "Regexp#options does not include Regexp::FIXEDENCODING for a Regexp literal with the 'n' option" # NameError: uninitialized constant Regexp::FIXEDENCODING
  fails "Regexp#options includes Regexp::FIXEDENCODING for a Regexp literal with the 'e' option" # NameError: uninitialized constant Regexp::FIXEDENCODING
  fails "Regexp#options includes Regexp::FIXEDENCODING for a Regexp literal with the 's' option" # NameError: uninitialized constant Regexp::FIXEDENCODING
  fails "Regexp#options includes Regexp::FIXEDENCODING for a Regexp literal with the 'u' option" # NameError: uninitialized constant Regexp::FIXEDENCODING
  fails "Regexp#options includes Regexp::NOENCODING for a Regexp literal with the 'n' option" # NameError: uninitialized constant Regexp::NOENCODING
  fails "Regexp.escape sets the encoding of the result to US-ASCII if there are only US-ASCII characters present in the input String" # ArgumentError: unknown encoding name - euc-jp
  fails "Regexp.new given a String ignores the third argument if it is 'e' or 'euc' (case-insensitive)" # ArgumentError: [Regexp.new] wrong number of arguments (given 3, expected -2)
  fails "Regexp.new given a String ignores the third argument if it is 's' or 'sjis' (case-insensitive)" # ArgumentError: [Regexp.new] wrong number of arguments (given 3, expected -2)
  fails "Regexp.new given a String ignores the third argument if it is 'u' or 'utf8' (case-insensitive)" # ArgumentError: [Regexp.new] wrong number of arguments (given 3, expected -2)
  fails "Regexp.new given a String uses ASCII_8BIT encoding if third argument is 'n' or 'none' (case insensitive) and non-ascii characters" # ArgumentError: [Regexp.new] wrong number of arguments (given 3, expected -2)
  fails "Regexp.new given a String uses US_ASCII encoding if third argument is 'n' or 'none' (case insensitive) and only ascii characters" # ArgumentError: [Regexp.new] wrong number of arguments (given 3, expected -2)
  fails "Regexp.new given a String with escaped characters raises a RegexpError if less than four digits are given for \\uHHHH" # Expected RegexpError but no exception was raised (/\u304/ was returned)
  fails "Regexp.new given a String with escaped characters raises a RegexpError if the \\u{} escape is empty" # Expected RegexpError but no exception was raised (/\u{}/ was returned)
  fails "Regexp.new given a String with escaped characters returns a Regexp with US-ASCII encoding if UTF-8 escape sequences using only 7-bit ASCII are present" # NoMethodError: undefined method `encoding' for /a/
  fails "Regexp.new given a String with escaped characters returns a Regexp with US-ASCII encoding if only 7-bit ASCII characters are present regardless of the input String's encoding" # NoMethodError: undefined method `encoding' for /abc/
  fails "Regexp.new given a String with escaped characters returns a Regexp with UTF-8 encoding if any UTF-8 escape sequences outside 7-bit ASCII are present" # NoMethodError: undefined method `encoding' for /ÿ/
  fails "Regexp.new given a String with escaped characters returns a Regexp with source String having US-ASCII encoding if UTF-8 escape sequences using only 7-bit ASCII are present" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "Regexp.new given a String with escaped characters returns a Regexp with source String having US-ASCII encoding if only 7-bit ASCII characters are present regardless of the input String's encoding" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "Regexp.new given a String with escaped characters returns a Regexp with source String having the input String's encoding" # NameError: uninitialized constant Encoding::Shift_JIS
  fails "Regexp.new given a String with escaped characters returns a Regexp with the input String's encoding" # NameError: uninitialized constant Encoding::Shift_JIS
  fails "Regexp.quote sets the encoding of the result to US-ASCII if there are only US-ASCII characters present in the input String" # ArgumentError: unknown encoding name - euc-jp
  fails "Regexp.union raises ArgumentError if the arguments include a String containing non-ASCII-compatible characters and a fixed encoding Regexp in a different encoding" # Expected ArgumentError but got: NameError (uninitialized constant Regexp::FIXEDENCODING)
  fails "Regexp.union raises ArgumentError if the arguments include a fixed encoding Regexp and a String containing non-ASCII-compatible characters in a different encoding" # Expected ArgumentError but got: NameError (uninitialized constant Regexp::FIXEDENCODING)
  fails "Regexp.union raises ArgumentError if the arguments include an ASCII-incompatible Regexp and a Regexp containing non-ASCII-compatible characters in a different encoding" # Expected ArgumentError but no exception was raised (/(a)|(©)/ was returned)
  fails "Regexp.union raises ArgumentError if the arguments include an ASCII-incompatible Regexp and a String containing non-ASCII-compatible characters in a different encoding" # Expected ArgumentError but no exception was raised (/(a)|©/ was returned)
  fails "Regexp.union raises ArgumentError if the arguments include an ASCII-incompatible Regexp and an ASCII-only Regexp" # Expected ArgumentError but no exception was raised (/(a)|(b)/ was returned)
  fails "Regexp.union raises ArgumentError if the arguments include an ASCII-incompatible Regexp and an ASCII-only String" # Expected ArgumentError but no exception was raised (/(a)|b/ was returned)
  fails "Regexp.union raises ArgumentError if the arguments include an ASCII-incompatible String and a Regexp containing non-ASCII-compatible characters in a different encoding" # Expected ArgumentError but no exception was raised (/a|(©)/ was returned)
  fails "Regexp.union raises ArgumentError if the arguments include an ASCII-incompatible String and a String containing non-ASCII-compatible characters in a different encoding" # Expected ArgumentError but no exception was raised (/a|©/ was returned)
  fails "Regexp.union raises ArgumentError if the arguments include an ASCII-incompatible String and an ASCII-only Regexp" # Expected ArgumentError but no exception was raised (/a|(b)/ was returned)
  fails "Regexp.union raises ArgumentError if the arguments include an ASCII-incompatible String and an ASCII-only String" # Expected ArgumentError but no exception was raised (/a|b/ was returned)
  fails "Regexp.union raises ArgumentError if the arguments include conflicting ASCII-incompatible Regexps" # Expected ArgumentError but no exception was raised (/(a)|(b)/ was returned)
  fails "Regexp.union raises ArgumentError if the arguments include conflicting ASCII-incompatible Strings" # Expected ArgumentError but no exception was raised (/a|b/ was returned)
  fails "Regexp.union raises ArgumentError if the arguments include conflicting fixed encoding Regexps" # Expected ArgumentError but got: NameError (uninitialized constant Regexp::FIXEDENCODING)
  fails "Regexp.union returns a Regexp with US-ASCII encoding if all arguments are ASCII-only" # ArgumentError: unknown encoding name - SJIS
  fails "Regexp.union returns a Regexp with UTF-8 if one part is UTF-8" # NoMethodError: undefined method `encoding' for /(probl[éeè]me)|(help)/i
  fails "Regexp.union returns a Regexp with the encoding of a String containing non-ASCII-compatible characters and another ASCII-only String" # NoMethodError: undefined method `encoding' for /©|a/
  fails "Regexp.union returns a Regexp with the encoding of a String containing non-ASCII-compatible characters" # NoMethodError: undefined method `encoding' for /©/
  fails "Regexp.union returns a Regexp with the encoding of an ASCII-incompatible String argument" # NoMethodError: undefined method `encoding' for /a/
  fails "Regexp.union returns a Regexp with the encoding of multiple non-conflicting ASCII-incompatible String arguments" # NoMethodError: undefined method `encoding' for /a|b/
  fails "Regexp.union returns a Regexp with the encoding of multiple non-conflicting Strings containing non-ASCII-compatible characters" # NoMethodError: undefined method `encoding' for /©|°/
end
