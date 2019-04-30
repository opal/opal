opal_filter "String" do
  fails "String#% faulty key raises a KeyError" # NoMethodError: undefined method `call' for nil
  fails "String#% faulty key sets the Hash as the receiver of KeyError" # NoMethodError: undefined method `call' for nil
  fails "String#% faulty key sets the unmatched key as the key of KeyError" # NoMethodError: undefined method `call' for nil
  fails "String#% flags # applies to format o does nothing for negative argument" # Expected "0..7651" to equal "..7651"
  fails "String#% flags # applies to formats aAeEfgG changes format from dd.dddd to exponential form for gG" # Expected "1.234e+02" to equal "1.e+02"
  fails "String#% flags # applies to formats aAeEfgG forces a decimal point to be added, even if no digits follow" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "String#% flags (digit)$ specifies the absolute argument number for this field" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "String#% flags * left-justifies the result if specified with $ argument is negative" # Expected "1.095200e+2         " to equal "1.095200e+02        "
  fails "String#% flags * left-justifies the result if width is negative" # Expected "1.095200e+2         " to equal "1.095200e+02        "
  fails "String#% flags * raises ArgumentError when is mixed with width" # Expected ArgumentError but no exception was raised ("       112" was returned)
  fails "String#% flags * uses the previous argument as the field width" # Expected "         1.095200e+02" to equal "        1.095200e+02"
  fails "String#% flags * uses the specified argument as the width if * is followed by a number and $" # Expected "         1.095200e+02" to equal "        1.095200e+02"
  fails "String#% flags + applies to numeric formats bBdiouxXaAeEfgG adds a leading plus sign to non-negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "String#% flags - left-justifies the result of conversion if width is specified" # Expected "1.095200e+2         " to equal "1.095200e+02        "
  fails "String#% flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified pads with zeros, not spaces" # Expected "0000000001.095200e+02" to equal "000000001.095200e+02"
  fails "String#% flags space applies to numeric formats bBdiouxXeEfgGaA does not leave a space at the start of negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "String#% flags space applies to numeric formats bBdiouxXeEfgGaA leaves a space at the start of non-negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "String#% flags space applies to numeric formats bBdiouxXeEfgGaA treats several white spaces as one" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "String#% float formats A converts floating point argument as [-]0xh.hhhhp[+-]dd and use uppercase X and P" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "String#% float formats A displays Float::INFINITY as Inf" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "String#% float formats A displays Float::NAN as NaN" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "String#% float formats G otherwise cuts excessive digits in fractional part and keeps only 4 ones" # Expected "12.12341111" to equal "12.1234"
  fails "String#% float formats G otherwise cuts fraction part to have only 6 digits at all" # Expected "1.1234567" to equal "1.12346"
  fails "String#% float formats G otherwise rounds the last significant digit to the closest one in fractional part" # Expected "1.555555555" to equal "1.55556"
  fails "String#% float formats G the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # Expected "1.234567E+06" to equal "1.23457E+06"
  fails "String#% float formats a converts floating point argument as [-]0xh.hhhhp[+-]dd" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "String#% float formats a displays Float::INFINITY as Inf" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "String#% float formats a displays Float::NAN as NaN" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "String#% float formats g otherwise cuts excessive digits in fractional part and keeps only 4 ones" # Expected "12.12341111" to equal "12.1234"
  fails "String#% float formats g otherwise cuts fraction part to have only 6 digits at all" # Expected "1.1234567" to equal "1.12346"
  fails "String#% float formats g otherwise rounds the last significant digit to the closest one in fractional part" # Expected "1.555555555" to equal "1.55556"
  fails "String#% float formats g the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # Expected "1.234567e+06" to equal "1.23457e+06"
  fails "String#% integer formats d works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
  fails "String#% integer formats i works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
  fails "String#% integer formats u works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
  fails "String#% other formats % alone raises an ArgumentError" # Expected ArgumentError but no exception was raised ("%" was returned)
  fails "String#% output's encoding is the same as the format string if passed value is encoding-compatible" # NameError: uninitialized constant Encoding::SHIFT_JIS
  fails "String#% output's encoding raises if a compatible encoding can't be found" # Expected Encoding::CompatibilityError but no exception was raised ("hello world" was returned)
  fails "String#% precision float types controls the number of decimal places displayed in fraction part" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "String#% precision float types does not affect G format" # Expected "12.12340000" to equal "12.1234"
  fails "String#% precision string formats determines the maximum number of characters to be copied from the string" # Expected "1" to equal "["
  fails "String#% raises Encoding::CompatibilityError if both encodings are ASCII compatible and there ano not ASCII characters" # ArgumentError: unknown encoding name - windows-1252
  fails "String#% raises an error if single % appears at the end" # Expected ArgumentError but no exception was raised ("%" was returned)
  fails "String#% returns a String in the argument's encoding if format encoding is more restrictive" # Expected #<Encoding:UTF-16LE> to be identical to #<Encoding:UTF-8>
  fails "String#% returns a String in the same encoding as the format String if compatible" # NameError: uninitialized constant Encoding::KOI8_U
  fails "String#% supports inspect formats using %p" # Expected "{\"capture\"=>1}" to equal "{:capture=>1}"
  fails "String#% width specifies the minimum number of characters that will be written to the result" # Expected "         1.095200e+02" to equal "        1.095200e+02"
  fails "String#-@ does not deduplicate already frozen strings" # Expected "this string is frozen" not to be identical to "this string is frozen"
  fails "String#-@ returns the same object for equal unfrozen strings" # Expected "this is a string" not to be identical to "this is a string"
  fails "String#-@ returns the same object when it's called on the same String literal" # NoMethodError: undefined method `-@' for "unfrozen string"
  fails "String#[] raises a RangeError if the index is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#[] with index, length raises a RangeError if the index or length is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#[] with index, length returns a string with the same encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "String#bytes agrees with #unpack('C*')" # Expected [113, 103, 172, 78, 84, 0, 111, 0, 107, 0, 121, 0, 111, 0] to equal [230, 157, 177, 228, 186, 172, 84, 111, 107, 121, 111]
  fails "String#bytes yields each byte to a block if one is given, returning self" # Expected [113, 103, 172, 78] to equal "東京"
  fails "String#byteslice raises a RangeError if the index is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#byteslice with index, length raises a RangeError if the index or length is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#byteslice with index, length returns a string with the same encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "String#capitalize ASCII-only case mapping does not capitalize non-ASCII characters" # ArgumentError: [String#capitalize] wrong number of arguments(1 for 0)
  fails "String#capitalize full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # ArgumentError: [String#capitalize] wrong number of arguments(2 for 0)
  fails "String#capitalize full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # ArgumentError: [String#capitalize] wrong number of arguments(1 for 0)
  fails "String#capitalize full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # ArgumentError: [String#capitalize] wrong number of arguments(2 for 0)
  fails "String#capitalize full Unicode case mapping adapted for Turkic languages capitalizes ASCII characters according to Turkic semantics" # ArgumentError: [String#capitalize] wrong number of arguments(1 for 0)
  fails "String#capitalize full Unicode case mapping only capitalizes the first resulting character when upcasing a character produces a multi-character sequence" # Expected "SS" to equal "Ss"
  fails "String#capitalize full Unicode case mapping updates string metadata" # Expected "SSet" to equal "Sset"
  fails "String#casecmp independent of case returns nil if incompatible encodings" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#casecmp? independent of case case folds" # Expected false to be true
  fails "String#casecmp? independent of case for UNICODE characters returns true when downcase(:fold) on unicode" # Expected false to equal true
  fails "String#casecmp? independent of case in UTF-8 mode for non-ASCII characters returns true when they are the same with normalized case" # Expected false to equal true
  fails "String#casecmp? independent of case returns nil if incompatible encodings" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#clone calls #initialize_copy on the new instance" # Expected nil to equal "string"
  fails "String#clone copies constants defined in the singleton class" # Exception: Cannot read property 'prototype' of undefined
  fails "String#clone copies modules included in the singleton class" # NoMethodError: undefined method `repr' for "string"
  fails "String#clone copies singleton methods" # NoMethodError: undefined method `special' for "string"
  fails "String#codepoints is synonymous with #bytes for Strings which are single-byte optimisable" # Expected false to be true
  fails "String#downcase ASCII-only case mapping does not downcase non-ASCII characters" # ArgumentError: [String#downcase] wrong number of arguments(1 for 0)
  fails "String#downcase case folding case folds special characters" # ArgumentError: [String#downcase] wrong number of arguments(1 for 0)
  fails "String#downcase full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # ArgumentError: [String#downcase] wrong number of arguments(2 for 0)
  fails "String#downcase full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # ArgumentError: [String#downcase] wrong number of arguments(1 for 0)
  fails "String#downcase full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # ArgumentError: [String#downcase] wrong number of arguments(2 for 0)
  fails "String#downcase full Unicode case mapping adapted for Turkic languages downcases characters according to Turkic semantics" # ArgumentError: [String#downcase] wrong number of arguments(1 for 0)
  fails "String#downcase full Unicode case mapping updates string metadata" # Expected 8 to equal 4
  fails "String#dump does not take into account if a string is frozen" # NoMethodError: undefined method `dump' for "foo"
  fails "String#dump includes .force_encoding(name) if the encoding isn't ASCII compatible" # NoMethodError: undefined method `dump' for "ࡶ"
  fails "String#dump keeps origin encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "String#dump returns a string with # not escaped when followed by any other character" # NoMethodError: undefined method `dump' for "#"
  fails "String#dump returns a string with \" and \\ escaped with a backslash" # NoMethodError: undefined method `dump' for "\""
  fails "String#dump returns a string with \\#<char> when # is followed by $, @, @@, {" # NoMethodError: undefined method `dump' for "\#$PATH"
  fails "String#dump returns a string with \\#<char> when # is followed by $, @, {" # NoMethodError: undefined method `dump' for "\#$"
  fails "String#dump returns a string with lower-case alpha characters unescaped" # NoMethodError: undefined method `dump' for "a"
  fails "String#dump returns a string with multi-byte UTF-8 characters replaced by \\u{} notation with lower-case hex digits" # NoMethodError: undefined method `dump' for "\u0080"
  fails "String#dump returns a string with multi-byte UTF-8 characters replaced by \\u{} notation with upper-case hex digits" # NoMethodError: undefined method `dump' for "\u0080"
  fails "String#dump returns a string with non-printing ASCII characters replaced by \\x notation" # NoMethodError: undefined method `dump' for "\u0000"
  fails "String#dump returns a string with non-printing single-byte UTF-8 characters replaced by \\x notation" # NoMethodError: undefined method `dump' for "\u0000"
  fails "String#dump returns a string with numeric characters unescaped" # NoMethodError: undefined method `dump' for "0"
  fails "String#dump returns a string with printable non-alphanumeric characters unescaped" # NoMethodError: undefined method `dump' for " "
  fails "String#dump returns a string with special characters replaced with \\<char> notation" # NoMethodError: undefined method `dump' for "\a"
  fails "String#dump returns a string with upper-case alpha characters unescaped" # NoMethodError: undefined method `dump' for "A"
  fails "String#dump returns a subclass instance" # NoMethodError: undefined method `dump' for ""
  fails "String#dump wraps string with \"" # NoMethodError: undefined method `dump' for "foo"
  fails "String#dup calls #initialize_copy on the new instance" # Expected nil to equal "string"
  fails "String#dup does not copy constants defined in the singleton class" # Exception: Cannot read property 'prototype' of undefined
  fails "String#each_byte keeps iterating from the old position (to new string end) when self changes" # NotImplementedError: String#<< not supported. Mutable String methods are not supported in Opal.
  fails "String#each_byte passes each byte in self to the given block" # Expected [104, 0, 101, 0, 108, 0, 108, 0, 111, 0, 0, 0] to equal [104, 101, 108, 108, 111, 0]
  fails "String#each_byte when no block is given returned enumerator size should return the bytesize of the string" # Expected nil to equal 10
  fails "String#each_byte when no block is given returns an enumerator" # Expected [104, 0, 101, 0, 108, 0, 108, 0, 111, 0] to equal [104, 101, 108, 108, 111]
  fails "String#each_codepoint is synonymous with #bytes for Strings which are single-byte optimisable" # Expected false to be true
  fails "String#each_grapheme_cluster is unicode aware" # NoMethodError: undefined method `each_grapheme_cluster' for "Ç∂éƒg"
  fails "String#each_grapheme_cluster passes each char in self to the given block" # NoMethodError: undefined method `each_grapheme_cluster' for "hello"
  fails "String#each_grapheme_cluster passes each grapheme cluster in self to the given block" # NoMethodError: undefined method `each_grapheme_cluster' for "ab🏳️\u200D🌈🐾"
  fails "String#each_grapheme_cluster returns a different character if the String is transcoded" # NoMethodError: undefined method `each_grapheme_cluster' for "€"
  fails "String#each_grapheme_cluster returns characters in the same encoding as self" # ArgumentError: unknown encoding name - Shift_JIS
  fails "String#each_grapheme_cluster returns self" # NoMethodError: undefined method `each_grapheme_cluster' for "ab🏳️\u200D🌈🐾"
  fails "String#each_grapheme_cluster returns self" # NoMethodError: undefined method `each_grapheme_cluster' for "hello"
  fails "String#each_grapheme_cluster taints resulting strings when self is tainted" # NoMethodError: undefined method `each_grapheme_cluster' for "hello"
  fails "String#each_grapheme_cluster uses the String's encoding to determine what characters it contains" # NoMethodError: undefined method `each_grapheme_cluster' for "𤭢"
  fails "String#each_grapheme_cluster when no block is given returned enumerator size should return the size of the string" # NoMethodError: undefined method `each_grapheme_cluster' for "hello"
  fails "String#each_grapheme_cluster when no block is given returns an enumerator" # NoMethodError: undefined method `each_grapheme_cluster' for "hello"
  fails "String#each_grapheme_cluster works if the String's contents is invalid for its encoding" # Expected true to be false
  fails "String#each_grapheme_cluster works with multibyte characters" # NoMethodError: undefined method `each_grapheme_cluster' for "覇"
  fails "String#each_line when `chomp` keyword argument is passed ignores new line characters when separator is specified" # ArgumentError: [String#each_line] wrong number of arguments(2 for -1)
  fails "String#each_line when `chomp` keyword argument is passed removes new line characters when separator is not specified" # TypeError: no implicit conversion of Hash into String
  fails "String#each_line when `chomp` keyword argument is passed removes new line characters" # TypeError: no implicit conversion of Hash into String
  fails "String#each_line when `chomp` keyword argument is passed removes only specified separator" # ArgumentError: [String#each_line] wrong number of arguments(2 for -1)
  fails "String#each_line yields paragraphs (broken by 2 or more successive newlines) when passed '' and replaces multiple newlines with only two ones" # Expected ["hello\nworld\n\n\n", "and\nuniverse\n\n\n\n\n"] to equal ["hello\nworld\n\n", "and\nuniverse\n\n"]
  fails "String#force_encoding with a special encoding name accepts valid special encoding names" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#force_encoding with a special encoding name accepts valid special encoding names" # NoMethodError: undefined method `default_internal=' for Encoding
  fails "String#force_encoding with a special encoding name defaults to ASCII-8BIT if special encoding name is not set" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#force_encoding with a special encoding name defaults to ASCII-8BIT if special encoding name is not set" # NoMethodError: undefined method `default_internal=' for Encoding
  fails "String#getbyte counts from the end of the String if given a negative argument" # NotImplementedError: NotImplementedError
  fails "String#getbyte interprets bytes relative to the String's encoding" # NotImplementedError: NotImplementedError
  fails "String#getbyte mirrors the output of #bytes" # NotImplementedError: NotImplementedError
  fails "String#getbyte raises a TypeError unless its argument can be coerced into an Integer" # NotImplementedError: NotImplementedError
  fails "String#getbyte regards a multi-byte character as having multiple bytes" # Expected 2 to equal 3
  fails "String#getbyte regards the empty String as containing no bytes" # NotImplementedError: NotImplementedError
  fails "String#getbyte returns an Integer between 0 and 255" # NotImplementedError: NotImplementedError
  fails "String#getbyte returns an Integer if given a valid index" # NotImplementedError: NotImplementedError
  fails "String#getbyte returns nil for out-of-bound indexes" # NotImplementedError: NotImplementedError
  fails "String#getbyte starts indexing at 0" # NotImplementedError: NotImplementedError
  fails "String#grapheme_clusters is unicode aware" # NoMethodError: undefined method `grapheme_clusters' for "Ç∂éƒg"
  fails "String#grapheme_clusters passes each char in self to the given block" # NoMethodError: undefined method `grapheme_clusters' for "hello"
  fails "String#grapheme_clusters passes each grapheme cluster in self to the given block" # NoMethodError: undefined method `grapheme_clusters' for "ab🏳️\u200D🌈🐾"
  fails "String#grapheme_clusters returns a different character if the String is transcoded" # NoMethodError: undefined method `grapheme_clusters' for "€"
  fails "String#grapheme_clusters returns an array when no block given" # NoMethodError: undefined method `grapheme_clusters' for "ab🏳️\u200D🌈🐾"
  fails "String#grapheme_clusters returns characters in the same encoding as self" # ArgumentError: unknown encoding name - Shift_JIS
  fails "String#grapheme_clusters returns self" # NoMethodError: undefined method `grapheme_clusters' for "ab🏳️\u200D🌈🐾"
  fails "String#grapheme_clusters returns self" # NoMethodError: undefined method `grapheme_clusters' for "hello"
  fails "String#grapheme_clusters taints resulting strings when self is tainted" # NoMethodError: undefined method `grapheme_clusters' for "hello"
  fails "String#grapheme_clusters uses the String's encoding to determine what characters it contains" # NoMethodError: undefined method `grapheme_clusters' for "𤭢"
  fails "String#grapheme_clusters works if the String's contents is invalid for its encoding" # Expected true to be false
  fails "String#grapheme_clusters works with multibyte characters" # NoMethodError: undefined method `grapheme_clusters' for "覇"
  fails "String#include? with String raises an Encoding::CompatibilityError if the encodings are incompatible" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#intern raises an EncodingError for UTF-8 String containing invalid bytes" # Expected true to equal false
  fails "String#intern returns a US-ASCII Symbol for a UTF-8 String containing only US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "String#intern returns a US-ASCII Symbol for a binary String containing only US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "String#intern returns a UTF-8 Symbol for a UTF-8 String containing non US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:UTF-8>
  fails "String#intern returns a binary Symbol for a binary String containing non US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "String#lines when `chomp` keyword argument is passed ignores new line characters when separator is specified" # ArgumentError: [String#lines] wrong number of arguments(2 for -1)
  fails "String#lines when `chomp` keyword argument is passed removes new line characters when separator is not specified" # TypeError: no implicit conversion of Hash into String
  fails "String#lines when `chomp` keyword argument is passed removes new line characters" # TypeError: no implicit conversion of Hash into String
  fails "String#lines when `chomp` keyword argument is passed removes new line characters" # TypeError: no implicit conversion of Hash into String
  fails "String#lines when `chomp` keyword argument is passed removes only specified separator" # ArgumentError: [String#lines] wrong number of arguments(2 for -1)
  fails "String#lines yields paragraphs (broken by 2 or more successive newlines) when passed '' and replaces multiple newlines with only two ones" # Expected ["hello\nworld\n\n\n", "and\nuniverse\n\n\n\n\n"] to equal ["hello\nworld\n\n", "and\nuniverse\n\n"]
  fails "String#scan with pattern and block passes block arguments as individual arguments when blocks are provided" # Expected ["a", "b", "c"] to equal "a"
  fails "String#slice raises a RangeError if the index is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#slice with index, length raises a RangeError if the index or length is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#slice with index, length returns a string with the same encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "String#split with Regexp applies the limit to the number of split substrings, without counting captures" # Expected ["a", "aBa"] to equal ["a", "B", "", "", "aBa"]
  fails "String#start_with? sets Regexp.last_match if it returns true" # TypeError: no implicit conversion of Regexp into String
  fails "String#start_with? supports regexps with ^ and $ modifiers" # TypeError: no implicit conversion of Regexp into String
  fails "String#start_with? supports regexps" # TypeError: no implicit conversion of Regexp into String
  fails "String#sub with pattern, replacement returns a copy of self when no modification is made" # Expected "hello" not to be identical to "hello"
  fails "String#swapcase ASCII-only case mapping does not swapcase non-ASCII characters" # ArgumentError: [String#swapcase] wrong number of arguments(1 for 0)
  fails "String#swapcase full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # ArgumentError: [String#swapcase] wrong number of arguments(2 for 0)
  fails "String#swapcase full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # ArgumentError: [String#swapcase] wrong number of arguments(1 for 0)
  fails "String#swapcase full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # ArgumentError: [String#swapcase] wrong number of arguments(2 for 0)
  fails "String#swapcase full Unicode case mapping adapted for Turkic languages swaps case of ASCII characters according to Turkic semantics" # ArgumentError: [String#swapcase] wrong number of arguments(1 for 0)
  fails "String#swapcase full Unicode case mapping updates string metadata" # Expected "aßET" to equal "aSSET"
  fails "String#swapcase full Unicode case mapping works for all of Unicode with no option" # Expected "äÖü" to equal "ÄöÜ"
  fails "String#swapcase works for all of Unicode" # Expected "äÖü" to equal "ÄöÜ"
  fails "String#to_sym raises an EncodingError for UTF-8 String containing invalid bytes" # Expected true to equal false
  fails "String#to_sym returns a US-ASCII Symbol for a UTF-8 String containing only US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "String#to_sym returns a US-ASCII Symbol for a binary String containing only US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "String#to_sym returns a UTF-8 Symbol for a UTF-8 String containing non US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:UTF-8>
  fails "String#to_sym returns a binary Symbol for a binary String containing non US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "String#undump Limitations cannot undump non ASCII-compatible string" # NoMethodError: undefined method `undump' for "\"foo\""
  fails "String#undump always returns String instance" # NoMethodError: undefined method `undump' for "\"foo\""
  fails "String#undump does not take into account if a string is frozen" # NoMethodError: undefined method `undump' for "\"foo\""
  fails "String#undump invalid dump raises RuntimeError exception if wrapping \" are missing" # NoMethodError: undefined method `undump' for "foo"
  fails "String#undump invalid dump raises RuntimeError if string contains \u0000 character" # NoMethodError: undefined method `undump' for "\"foo\u0000\""
  fails "String#undump invalid dump raises RuntimeError if string contains non ASCII character" # NoMethodError: undefined method `undump' for "\"あ\""
  fails "String#undump invalid dump raises RuntimeError if there are some excessive \"" # NoMethodError: undefined method `undump' for "\" \"\" \""
  fails "String#undump invalid dump raises RuntimeError if there is incorrect \\x sequence" # NoMethodError: undefined method `undump' for "\"\\x\""
  fails "String#undump invalid dump raises RuntimeError if there is malformed dump of non ASCII-compatible string" # NoMethodError: undefined method `undump' for "\"\".force_encoding(\"ASCII-8BIT\""
  fails "String#undump invalid dump raises RuntimeError in there is incorrect \\u sequence" # NoMethodError: undefined method `undump' for "\"\\u\""
  fails "String#undump keeps origin encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "String#undump returns a string with # not escaped when followed by any other character" # NoMethodError: undefined method `undump' for "\"#\""
  fails "String#undump returns a string with \\uXXXX notation replaced with multi-byte UTF-8 characters" # NoMethodError: undefined method `undump' for "\"\\u0080\""
  fails "String#undump returns a string with \\u{} notation replaced with multi-byte UTF-8 characters" # NoMethodError: undefined method `undump' for "\"\\u80\""
  fails "String#undump returns a string with \\x notation replaced with non-printing ASCII character" # NoMethodError: undefined method `undump' for "\"\\x00\""
  fails "String#undump returns a string with lower-case alpha characters unescaped" # NoMethodError: undefined method `undump' for "\"a\""
  fails "String#undump returns a string with numeric characters unescaped" # NoMethodError: undefined method `undump' for "\"0\""
  fails "String#undump returns a string with printable non-alphanumeric characters" # NoMethodError: undefined method `undump' for "\" \""
  fails "String#undump returns a string with special characters in \\<char> notation replaced with the characters" # NoMethodError: undefined method `undump' for "\"\\a\""
  fails "String#undump returns a string with unescaped sequences \\#<char> when # is followed by $, @, {" # NoMethodError: undefined method `undump' for "\"\\\#$PATH\""
  fails "String#undump returns a string with unescaped sequencies \" and \\" # NoMethodError: undefined method `undump' for "\"\\\"\""
  fails "String#undump returns a string with upper-case alpha characters unescaped" # NoMethodError: undefined method `undump' for "\"A\""
  fails "String#undump strips outer \"" # NoMethodError: undefined method `undump' for "\"foo\""
  fails "String#undump taints the result if self is tainted" # NoMethodError: undefined method `undump' for "\"foo\""
  fails "String#undump undumps correctly string produced from non ASCII-compatible one" # NoMethodError: undefined method `dump' for "ࡶ"
  fails "String#undump untrusts the result if self is untrusted" # NoMethodError: undefined method `untrust' for "\"foo\""
  fails "String#unicode_normalize defaults to the nfc normalization form if no forms are specified" # Expected "Å" to equal "Å"
  fails "String#unicode_normalize normalizes code points in the string according to the form that is specified" # Expected "ẛ̣" to equal "ẛ̣"
  fails "String#unicode_normalize raises an ArgumentError if the specified form is invalid" # Expected ArgumentError but no exception was raised ("Å" was returned)
  fails "String#unicode_normalize raises an Encoding::CompatibilityError if string is not in an unicode encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "String#unicode_normalize returns normalized form of string by default 03D3 (ϓ) GREEK UPSILON WITH ACUTE AND HOOK SYMBOL" # Expected "ϓ" to equal "ϓ"
  fails "String#unicode_normalize returns normalized form of string by default 03D4 (ϔ) GREEK UPSILON WITH DIAERESIS AND HOOK SYMBOL" # Expected "ϔ" to equal "ϔ"
  fails "String#unicode_normalize returns normalized form of string by default 1E9B (ẛ) LATIN SMALL LETTER LONG S WITH DOT ABOVE" # Expected "ẛ" to equal "ẛ"
  fails "String#unicode_normalized? defaults to the nfc normalization form if no forms are specified" # Expected true to equal false
  fails "String#unicode_normalized? raises an ArgumentError if the specified form is invalid" # Expected ArgumentError but no exception was raised (true was returned)
  fails "String#unicode_normalized? raises an Encoding::CompatibilityError if the string is not in an unicode encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "String#unicode_normalized? returns false if string is not in the supplied normalization form" # Expected true to equal false
  fails "String#unicode_normalized? returns true if str is in Unicode normalization form (nfc)" # Expected true to be false
  fails "String#unicode_normalized? returns true if str is in Unicode normalization form (nfd)" # Expected true to be false
  fails "String#unicode_normalized? returns true if str is in Unicode normalization form (nfkc)" # Expected true to be false
  fails "String#unicode_normalized? returns true if str is in Unicode normalization form (nfkd)" # Expected true to be false
  fails "String#unpack1 returns the first value of #unpack" # RuntimeError: Unsupported unpack directive "x" (no chunk reader defined)
  fails "String#upcase ASCII-only case mapping does not upcase non-ASCII characters" # ArgumentError: [String#upcase] wrong number of arguments(1 for 0)
  fails "String#upcase full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # ArgumentError: [String#upcase] wrong number of arguments(2 for 0)
  fails "String#upcase full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # ArgumentError: [String#upcase] wrong number of arguments(1 for 0)
  fails "String#upcase full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # ArgumentError: [String#upcase] wrong number of arguments(2 for 0)
  fails "String#upcase full Unicode case mapping adapted for Turkic languages upcases ASCII characters according to Turkic semantics" # ArgumentError: [String#upcase] wrong number of arguments(1 for 0)
  fails "String#upcase full Unicode case mapping updates string metadata" # Expected 10 to equal 5
  fails "String.new accepts a capacity argument" # ArgumentError: [String.new] wrong number of arguments(2 for -1)
  fails "String.new accepts an encoding argument" # ArgumentError: [String.new] wrong number of arguments(2 for -1)
  fails "String.new is called on subclasses" # Expected nil to equal "subclass"
end
