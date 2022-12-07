# NOTE: run bin/format-filters after changing this file
opal_filter "String" do
  fails "Integer#chr with an encoding argument accepts a String as an argument" # Expected to not get Exception but got: ArgumentError (unknown encoding name - euc-jp)
  fails "String#% %c raises error when a codepoint isn't representable in an encoding of a format string" # Expected RangeError (/out of char range/) but no exception was raised ("Ԇ" was returned)
  fails "String#% %c uses the encoding of the format string to interpret codepoints" # ArgumentError: unknown encoding name - euc-jp
  fails "String#% can produce a string with invalid encoding" # Expected true to be false
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
  fails "String#% other formats c raises TypeError if argument is nil" # Expected TypeError (/no implicit conversion from nil to integer/) but got: TypeError (no implicit conversion of NilClass into Integer)
  fails "String#% other formats c raises TypeError if argument is not String or Integer and cannot be converted to them" # Expected TypeError (/no implicit conversion of Array into Integer/) but got: ArgumentError (too few arguments)
  fails "String#% other formats c raises TypeError if converting to Integer with to_int returns non-Integer" # Expected TypeError (/can't convert BasicObject to String/) but got: NoMethodError (undefined method `respond_to?' for #<BasicObject:0x45906>)
  fails "String#% other formats c raises TypeError if converting to String with to_str returns non-String" # Expected TypeError (/can't convert BasicObject to String/) but got: NoMethodError (undefined method `respond_to?' for #<BasicObject:0x4592e>)
  fails "String#% other formats c tries to convert argument to Integer with to_int" # NoMethodError: undefined method `respond_to?' for #<BasicObject:0x4590e>
  fails "String#% other formats c tries to convert argument to String with to_str" # NoMethodError: undefined method `respond_to?' for #<BasicObject:0x45912>
  fails "String#% other formats s preserves encoding of the format string" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#% output's encoding is the same as the format string if passed value is encoding-compatible" # NameError: uninitialized constant Encoding::SHIFT_JIS
  fails "String#% output's encoding raises if a compatible encoding can't be found" # Expected Encoding::CompatibilityError but no exception was raised ("hello world" was returned)
  fails "String#% precision float types controls the number of decimal places displayed in fraction part" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "String#% precision float types does not affect G format" # Expected "12.12340000" to equal "12.1234"
  fails "String#% precision string formats determines the maximum number of characters to be copied from the string" # Expected "1" to equal "["
  fails "String#% raises Encoding::CompatibilityError if both encodings are ASCII compatible and there ano not ASCII characters" # ArgumentError: unknown encoding name - windows-1252
  fails "String#% raises Encoding::CompatibilityError if both encodings are ASCII compatible and there are not ASCII characters" # ArgumentError: unknown encoding name - windows-1252
  fails "String#% raises an error if single % appears at the end" # Expected ArgumentError but no exception was raised ("%" was returned)
  fails "String#% returns a String in the same encoding as the format String if compatible" # NameError: uninitialized constant Encoding::KOI8_U
  fails "String#% supports inspect formats using %p" # Expected "{\"capture\"=>1}" to equal "{:capture=>1}"
  fails "String#% width specifies the minimum number of characters that will be written to the result" # Expected "         1.095200e+02" to equal "        1.095200e+02"
  fails "String#* raises a RangeError when given integer is a Bignum" # Expected RangeError but no exception was raised ("" was returned)
  fails "String#+ when self and the argument are in different ASCII-compatible encodings raises Encoding::CompatibilityError if neither are ASCII-only" # Expected Encoding::CompatibilityError but no exception was raised ("éé" was returned)
  fails "String#+ when self and the argument are in different ASCII-compatible encodings uses self's encoding if both are ASCII-only" # ArgumentError: unknown encoding name - SHIFT_JIS
  fails "String#+ when self and the argument are in different ASCII-compatible encodings uses the argument's encoding if self is ASCII-only" # Expected #<Encoding:UTF-8> == #<Encoding:ISO-8859-1> to be truthy but was false
  fails "String#+ when self is in an ASCII-incompatible encoding incompatible with the argument's encoding raises Encoding::CompatibilityError if neither are empty" # Expected Encoding::CompatibilityError but no exception was raised ("xy" was returned)
  fails "String#+ when the argument is in an ASCII-incompatible encoding incompatible with self's encoding raises Encoding::CompatibilityError if neither are empty" # Expected Encoding::CompatibilityError but no exception was raised ("xy" was returned)
  fails "String#-@ does not deduplicate a frozen string when it has instance variables" # Exception: Cannot create property 'a' on string 'this string is frozen'
  fails "String#-@ returns the same object for equal unfrozen strings" # Expected "this is a string" not to be identical to "this is a string"
  fails "String#<< when self is BINARY and argument is US-ASCII uses BINARY encoding" # NotImplementedError: String#<< not supported. Mutable String methods are not supported in Opal.
  fails "String#<< with Integer returns a BINARY string if self is US-ASCII and the argument is between 128-255 (inclusive)" # NotImplementedError: String#<< not supported. Mutable String methods are not supported in Opal.
  fails "String#<=> with String compares the indices of the encodings when the strings have identical non-ASCII-compatible bytes" # Expected 0 == -1 to be truthy but was false
  fails "String#<=> with String returns 0 when comparing 2 empty strings but one is not ASCII-compatible" # ArgumentError: unknown encoding name - iso-2022-jp
  fails "String#== considers encoding compatibility" # Expected true to be false
  fails "String#== considers encoding difference of incompatible string" # Expected true to be false
  fails "String#== returns true when comparing 2 empty strings but one is not ASCII-compatible" # ArgumentError: unknown encoding name - iso-2022-jp
  fails "String#=== considers encoding compatibility" # Expected true to be false
  fails "String#=== considers encoding difference of incompatible string" # Expected true to be false
  fails "String#=== returns true when comparing 2 empty strings but one is not ASCII-compatible" # ArgumentError: unknown encoding name - iso-2022-jp
  fails "String#[] raises a RangeError if the index is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#[] with Range raises a RangeError if one of the bound is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#[] with Range raises a type error if a range is passed with a length" # Expected TypeError but no exception was raised ("el" was returned)
  fails "String#[] with Range returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#[] with Regexp returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#[] with Regexp, index returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#[] with Regexp, index returns nil if the given capture group was not matched but still sets $~" # Exception: Cannot read properties of undefined (reading '$should')
  fails "String#[] with String returns a String instance when given a subclass instance" # Expected "el" (StringSpecs::MyString) to be an instance of String
  fails "String#[] with index, length raises a RangeError if the index or length is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#[] with index, length returns a string with the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#[] with index, length returns a string with the same encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "String#bytes yields each byte to a block if one is given, returning self" # Expected [113, 103, 172, 78] to equal "東京"
  fails "String#byteslice on on non ASCII strings returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#byteslice raises a RangeError if the index is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#byteslice with Range raises a RangeError if one of the bound is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#byteslice with Range raises a type error if a range is passed with a length" # Expected TypeError but no exception was raised ("el" was returned)
  fails "String#byteslice with Range returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#byteslice with index, length raises a RangeError if the index or length is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#byteslice with index, length returns a string with the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#byteslice with index, length returns a string with the same encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "String#capitalize ASCII-only case mapping does not capitalize non-ASCII characters" # ArgumentError: [String#capitalize] wrong number of arguments(1 for 0)
  fails "String#capitalize ASCII-only case mapping handles non-ASCII substrings properly" # ArgumentError: [String#capitalize] wrong number of arguments (given 1, expected 0)
  fails "String#capitalize full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # ArgumentError: [String#capitalize] wrong number of arguments(2 for 0)
  fails "String#capitalize full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # ArgumentError: [String#capitalize] wrong number of arguments(1 for 0)
  fails "String#capitalize full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # ArgumentError: [String#capitalize] wrong number of arguments(2 for 0)
  fails "String#capitalize full Unicode case mapping adapted for Turkic languages capitalizes ASCII characters according to Turkic semantics" # ArgumentError: [String#capitalize] wrong number of arguments(1 for 0)
  fails "String#capitalize full Unicode case mapping only capitalizes the first resulting character when upcasing a character produces a multi-character sequence" # Expected "SS" to equal "Ss"
  fails "String#capitalize full Unicode case mapping updates string metadata" # Expected "SSet" to equal "Sset"
  fails "String#capitalize returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#casecmp independent of case returns nil if incompatible encodings" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#casecmp? independent of case case folds" # Expected false to be true
  fails "String#casecmp? independent of case for UNICODE characters returns true when downcase(:fold) on unicode" # Expected false to equal true
  fails "String#casecmp? independent of case in UTF-8 mode for non-ASCII characters returns true when they are the same with normalized case" # Expected false to equal true
  fails "String#casecmp? independent of case returns nil if incompatible encodings" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#chomp when passed no argument returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#chomp when passed no argument returns a copy of the String when it is not modified" # Expected "abc" not to be identical to "abc"
  fails "String#chop returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#clone calls #initialize_copy on the new instance" # Expected nil to equal "string"
  fails "String#clone copies singleton methods" # NoMethodError: undefined method `special' for "string"
  fails "String#clone returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#concat when self is BINARY and argument is US-ASCII uses BINARY encoding" # NoMethodError: undefined method `concat' for "abc"
  fails "String#concat with Integer returns a BINARY string if self is US-ASCII and the argument is between 128-255 (inclusive)" # NoMethodError: undefined method `concat' for ""
  fails "String#delete returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#delete_prefix returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#delete_suffix returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#downcase ASCII-only case mapping does not downcase non-ASCII characters" # ArgumentError: [String#downcase] wrong number of arguments(1 for 0)
  fails "String#downcase ASCII-only case mapping works with substrings" # ArgumentError: [String#downcase] wrong number of arguments (given 1, expected 0)
  fails "String#downcase case folding case folds special characters" # ArgumentError: [String#downcase] wrong number of arguments(1 for 0)
  fails "String#downcase full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # ArgumentError: [String#downcase] wrong number of arguments(2 for 0)
  fails "String#downcase full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # ArgumentError: [String#downcase] wrong number of arguments(1 for 0)
  fails "String#downcase full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # ArgumentError: [String#downcase] wrong number of arguments(2 for 0)
  fails "String#downcase full Unicode case mapping adapted for Turkic languages downcases characters according to Turkic semantics" # ArgumentError: [String#downcase] wrong number of arguments(1 for 0)
  fails "String#downcase returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#dump does not take into account if a string is frozen" # NoMethodError: undefined method `dump' for "foo"
  fails "String#dump includes .force_encoding(name) if the encoding isn't ASCII compatible" # NoMethodError: undefined method `dump' for "ࡶ"
  fails "String#dump keeps origin encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "String#dump returns a String in the same encoding as self" # NoMethodError: undefined method `dump' for "foo"
  fails "String#dump returns a String instance" # NoMethodError: undefined method `dump' for ""
  fails "String#dump returns a string with # not escaped when followed by any other character" # NoMethodError: undefined method `dump' for "#"
  fails "String#dump returns a string with \" and \\ escaped with a backslash" # NoMethodError: undefined method `dump' for "\""
  fails "String#dump returns a string with \\#<char> when # is followed by $, @, @@, {" # NoMethodError: undefined method `dump' for "\#$PATH"
  fails "String#dump returns a string with lower-case alpha characters unescaped" # NoMethodError: undefined method `dump' for "a"
  fails "String#dump returns a string with multi-byte UTF-8 characters replaced by \\u{} notation with upper-case hex digits" # NoMethodError: undefined method `dump' for "\u0080"
  fails "String#dump returns a string with non-printing ASCII characters replaced by \\x notation" # NoMethodError: undefined method `dump' for "\u0000"
  fails "String#dump returns a string with non-printing single-byte UTF-8 characters replaced by \\x notation" # NoMethodError: undefined method `dump' for "\u0000"
  fails "String#dump returns a string with numeric characters unescaped" # NoMethodError: undefined method `dump' for "0"
  fails "String#dump returns a string with printable non-alphanumeric characters unescaped" # NoMethodError: undefined method `dump' for " "
  fails "String#dump returns a string with special characters replaced with \\<char> notation" # NoMethodError: undefined method `dump' for "\a"
  fails "String#dump returns a string with upper-case alpha characters unescaped" # NoMethodError: undefined method `dump' for "A"
  fails "String#dump wraps string with \"" # NoMethodError: undefined method `dump' for "foo"
  fails "String#dup calls #initialize_copy on the new instance" # Expected nil to equal "string"
  fails "String#dup does not modify the original setbyte-mutated string when changing dupped string" # NoMethodError: undefined method `setbyte' for "a"
  fails "String#dup returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#each_byte keeps iterating from the old position (to new string end) when self changes" # NotImplementedError: String#<< not supported. Mutable String methods are not supported in Opal.
  fails "String#each_grapheme_cluster is unicode aware" # NoMethodError: undefined method `each_grapheme_cluster' for "Ç∂éƒg"
  fails "String#each_grapheme_cluster passes each char in self to the given block" # NoMethodError: undefined method `each_grapheme_cluster' for "hello"
  fails "String#each_grapheme_cluster passes each grapheme cluster in self to the given block" # NoMethodError: undefined method `each_grapheme_cluster' for "ab🏳️\u200D🌈🐾"
  fails "String#each_grapheme_cluster returns a different character if the String is transcoded" # NoMethodError: undefined method `each_grapheme_cluster' for "€"
  fails "String#each_grapheme_cluster returns characters in the same encoding as self" # ArgumentError: unknown encoding name - Shift_JIS
  fails "String#each_grapheme_cluster returns self" # NoMethodError: undefined method `each_grapheme_cluster' for "ab🏳️\u200D🌈🐾"
  fails "String#each_grapheme_cluster uses the String's encoding to determine what characters it contains" # NoMethodError: undefined method `each_grapheme_cluster' for "𤭢"
  fails "String#each_grapheme_cluster when no block is given returned enumerator size should return the size of the string" # NoMethodError: undefined method `each_grapheme_cluster' for "hello"
  fails "String#each_grapheme_cluster when no block is given returns an enumerator" # NoMethodError: undefined method `each_grapheme_cluster' for "hello"
  fails "String#each_grapheme_cluster works if the String's contents is invalid for its encoding" # Expected true to be false
  fails "String#each_grapheme_cluster works with multibyte characters" # NoMethodError: undefined method `each_grapheme_cluster' for "覇"
  fails "String#each_grapheme_cluster yields String instances for subclasses" # NoMethodError: undefined method `each_grapheme_cluster' for "abc"
  fails "String#each_line returns Strings in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#encode when passed to, from, options returns a copy in the destination encoding when both encodings are the same" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encoding for Strings with \\x escapes returns BINARY when an escape creates a byte with the 8th bit set if the source encoding is US-ASCII" # Expected #<Encoding:UTF-8> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "String#end_with? checks that we are starting to match at the head of a character" # Expected "ab".end_with? "b" to be falsy but was true
  fails "String#end_with? raises an Encoding::CompatibilityError if the encodings are incompatible" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#eql? considers encoding compatibility" # Expected true to be false
  fails "String#eql? considers encoding difference of incompatible string" # Expected true to be false
  fails "String#eql? returns true when comparing 2 empty strings but one is not ASCII-compatible" # ArgumentError: unknown encoding name - iso-2022-jp
  fails "String#force_encoding with a special encoding name accepts valid special encoding names" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#force_encoding with a special encoding name defaults to BINARY if special encoding name is not set" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#grapheme_clusters is unicode aware" # NoMethodError: undefined method `grapheme_clusters' for "Ç∂éƒg"
  fails "String#grapheme_clusters passes each char in self to the given block" # NoMethodError: undefined method `grapheme_clusters' for "hello"
  fails "String#grapheme_clusters passes each grapheme cluster in self to the given block" # NoMethodError: undefined method `grapheme_clusters' for "ab🏳️\u200D🌈🐾"
  fails "String#grapheme_clusters returns a different character if the String is transcoded" # NoMethodError: undefined method `grapheme_clusters' for "€"
  fails "String#grapheme_clusters returns an array when no block given" # NoMethodError: undefined method `grapheme_clusters' for "ab🏳️\u200D🌈🐾"
  fails "String#grapheme_clusters returns characters in the same encoding as self" # ArgumentError: unknown encoding name - Shift_JIS
  fails "String#grapheme_clusters returns self" # NoMethodError: undefined method `grapheme_clusters' for "ab🏳️\u200D🌈🐾"
  fails "String#grapheme_clusters uses the String's encoding to determine what characters it contains" # NoMethodError: undefined method `grapheme_clusters' for "𤭢"
  fails "String#grapheme_clusters works if the String's contents is invalid for its encoding" # Expected true to be false
  fails "String#grapheme_clusters works with multibyte characters" # NoMethodError: undefined method `grapheme_clusters' for "覇"
  fails "String#gsub with pattern and block does not set $~ for procs created from methods" # Expected "he<l><l>o" == "he<unset><unset>o" to be truthy but was false
  fails "String#gsub with pattern and block raises an Encoding::CompatibilityError if the encodings are not compatible" # Expected Encoding::CompatibilityError but got: ArgumentError (unknown encoding name - iso-8859-5)
  fails "String#gsub with pattern and block replaces the incompatible part properly even if the encodings are not compatible" # ArgumentError: unknown encoding name - iso-8859-5
  fails "String#gsub with pattern and block uses the compatible encoding if they are compatible" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "String#gsub with pattern and replacement doesn't freak out when replacing ^" # Expected  " Text  " ==  " Text " to be truthy but was false
  fails "String#gsub with pattern and replacement handles a pattern in a superset encoding" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#gsub with pattern and replacement replaces \\k named backreferences with the regexp's corresponding capture" # Exception: named captures are not supported in javascript: "(?<foo>[aeiou])"
  fails "String#gsub with pattern and replacement supports \\G which matches at the beginning of the remaining (non-matched) string" # Expected "hello homely world. hah!" == "huh? huh? world. hah!" to be truthy but was false
  fails "String#include? with String raises an Encoding::CompatibilityError if the encodings are incompatible" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#include? with String returns true if both strings are empty" # ArgumentError: unknown encoding name - EUC-JP
  fails "String#include? with String returns true if the RHS is empty" # ArgumentError: unknown encoding name - EUC-JP
  fails "String#insert with index, other should not call subclassed string methods" # NoMethodError: undefined method `insert' for "abcd"
  fails "String#inspect returns a string with non-printing characters replaced by \\x notation" # Expected "\"\\xA0\"" to be computed by " ".inspect (computed "\" \"" instead)
  fails "String#inspect uses \\x notation for broken UTF-8 sequences" # Expected "\"ð\\u009F\"" == "\"\\xF0\\x9F\"" to be truthy but was false
  fails "String#inspect when the string's encoding is different than the result's encoding and the string has both ASCII-compatible and ASCII-incompatible chars returns a string with the non-ASCII characters replaced by \\u notation" # Expected "\"hello привет\"" == "\"hello \\u043F\\u0440\\u0438\\u0432\\u0435\\u0442\"" to be truthy but was false
  fails "String#inspect when the string's encoding is different than the result's encoding and the string's encoding is ASCII-compatible but the characters are non-ASCII returns a string with the non-ASCII characters replaced by \\x notation" # ArgumentError: unknown encoding name - EUC-JP
  fails "String#inspect works for broken US-ASCII strings" # Expected "\"©\"" == "\"\\xC2\\xA9\"" to be truthy but was false
  fails "String#intern ignores existing symbols with different encoding" # Expected #<Encoding:UTF-8> == #<Encoding:ISO-8859-1> to be truthy but was false
  fails "String#intern raises an EncodingError for UTF-8 String containing invalid bytes" # Expected true to equal false
  fails "String#intern returns a US-ASCII Symbol for a UTF-8 String containing only US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "String#intern returns a US-ASCII Symbol for a binary String containing only US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "String#intern returns a UTF-16LE Symbol for a UTF-16LE String containing non US-ASCII characters" # Error
  fails "String#intern returns a binary Symbol for a binary String containing non US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "String#length adds 1 (and not 2) for a incomplete surrogate in UTF-16" # Expected 2 == 1 to be truthy but was false
  fails "String#length adds 1 for a broken sequence in UTF-32" # Expected 4 == 1 to be truthy but was false
  fails "String#length returns the correct length after force_encoding(BINARY)" # Expected 2 == 4 to be truthy but was false
  fails "String#lines returns Strings in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#lstrip returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#next returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#ord raises ArgumentError if the character is broken" # Expected ArgumentError (invalid byte sequence in US-ASCII) but no exception was raised (169 was returned)
  fails "String#partition with String handles a pattern in a subset encoding" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#partition with String handles a pattern in a superset encoding" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#partition with String returns String instances when called on a subclass" # Expected "hello" (StringSpecs::MyString) to be an instance of String
  fails "String#partition with String returns before- and after- parts in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#reverse returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#reverse works with a broken string" # Expected true to be false
  fails "String#rpartition with String handles a pattern in a subset encoding" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#rpartition with String handles a pattern in a superset encoding" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#rpartition with String returns String instances when called on a subclass" # Expected "hello" (StringSpecs::MyString) to be an instance of String
  fails "String#rpartition with String returns before- and after- parts in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#rpartition with String returns new object if doesn't match" # Expected "hello".equal? "hello" to be falsy but was true
  fails "String#rstrip returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#scan returns Strings in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#size adds 1 (and not 2) for a incomplete surrogate in UTF-16" # Expected 2 == 1 to be truthy but was false
  fails "String#size adds 1 for a broken sequence in UTF-32" # Expected 4 == 1 to be truthy but was false
  fails "String#size returns the correct length after force_encoding(BINARY)" # Expected 2 == 4 to be truthy but was false
  fails "String#slice raises a RangeError if the index is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#slice with Range raises a RangeError if one of the bound is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#slice with Range raises a type error if a range is passed with a length" # Expected TypeError but no exception was raised ("el" was returned)
  fails "String#slice with Range returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#slice with Regexp returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#slice with Regexp, index returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#slice with Regexp, index returns nil if the given capture group was not matched but still sets $~" # Exception: Cannot read properties of undefined (reading '$should')
  fails "String#slice with String returns a String instance when given a subclass instance" # Expected "el" (StringSpecs::MyString) to be an instance of String
  fails "String#slice with index, length raises a RangeError if the index or length is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#slice with index, length returns a string with the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#slice with index, length returns a string with the same encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "String#split with Regexp allows concurrent Regexp calls in a shared context" # NotImplementedError: Thread creation not available
  fails "String#split with Regexp applies the limit to the number of split substrings, without counting captures" # Expected ["a", "aBa"] to equal ["a", "B", "", "", "aBa"]
  fails "String#split with Regexp for a String subclass yields instances of String" # Expected nil (NilClass) to be an instance of String
  fails "String#split with Regexp raises a TypeError when not called with nil, String, or Regexp" # Expected TypeError but no exception was raised (["he", "o"] was returned)
  fails "String#split with Regexp returns String instances based on self" # Expected "x" (StringSpecs::MyString) to be an instance of String
  fails "String#split with Regexp returns an ArgumentError if an invalid UTF-8 string is supplied" # NotImplementedError: String#chop! not supported. Mutable String methods are not supported in Opal.
  fails "String#split with Regexp throws an ArgumentError if the string  is not a valid" # Expected ArgumentError but no exception was raised ([] was returned)
  fails "String#split with Regexp when a block is given returns a string as is (and doesn't call block) if it is empty" # Expected [] == "" to be truthy but was false
  fails "String#split with Regexp when a block is given yields each split letter" # Expected ["c", "h", "u", "n", "k", "y"] == "chunky" to be truthy but was false
  fails "String#split with Regexp when a block is given yields each split substring with a pattern" # Expected ["chunky", "bacon"] == "chunky-bacon" to be truthy but was false
  fails "String#split with Regexp when a block is given yields each split substring with a regexp pattern" # Expected ["chunky", "bacon"] == "chunky:bacon" to be truthy but was false
  fails "String#split with Regexp when a block is given yields each split substring with default pattern for a lazy substring" # Expected ["hunky", "baco"] == "hunky baco" to be truthy but was false
  fails "String#split with Regexp when a block is given yields each split substring with default pattern for a non-ASCII lazy substring" # Expected ["'été", "arrive", "bientô"] == "'été arrive bientô" to be truthy but was false
  fails "String#split with Regexp when a block is given yields each split substring with default pattern for a non-ASCII string" # Expected ["l'été", "arrive", "bientôt"] == "l'été arrive bientôt" to be truthy but was false
  fails "String#split with Regexp when a block is given yields each split substring with default pattern" # Expected ["chunky", "bacon"] == "chunky bacon" to be truthy but was false
  fails "String#split with Regexp when a block is given yields each split substring with empty regexp pattern and limit" # Expected ["c", "h", "unky"] == "chunky" to be truthy but was false
  fails "String#split with Regexp when a block is given yields each split substring with empty regexp pattern" # Expected ["c", "h", "u", "n", "k", "y"] == "chunky" to be truthy but was false
  fails "String#split with Regexp when a block is given yields the string when limit is 1" # Expected ["chunky bacon"] == "chunky bacon" to be truthy but was false
  fails "String#split with String doesn't split on non-ascii whitespace" # Expected ["a", "b"] == ["a b"] to be truthy but was false
  fails "String#split with String raises a RangeError when the limit is larger than int" # Expected RangeError but no exception was raised (["a,b"] was returned)
  fails "String#split with String returns String instances based on self" # Expected "x" (StringSpecs::MyString) to be an instance of String
  fails "String#split with String returns Strings in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#split with String returns an empty array when whitespace is split on whitespace" # Expected [""] == [] to be truthy but was false
  fails "String#split with String throws an ArgumentError if the string  is not a valid" # Expected ArgumentError but no exception was raised (["ß"] was returned)
  fails "String#split with String when $; is not nil warns" # Expected warning to match: /warning: \$; is set to non-nil value/ but got: ""
  fails "String#squeeze returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#start_with? does not check that we are not matching part of a character" # Expected "é".start_with? "Ã" to be truthy but was false
  fails "String#start_with? does not check we are matching only part of a character" # Expected "あ".start_with? "ã" to be truthy but was false
  fails "String#strip returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#sub with pattern, replacement handles a pattern in a superset encoding" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#sub with pattern, replacement returns a copy of self when no modification is made" # Expected "hello" not to be identical to "hello"
  fails "String#sub with pattern, replacement supports \\G which matches at the beginning of the string" # Expected "hello world!" == "hi world!" to be truthy but was false
  fails "String#succ returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#swapcase ASCII-only case mapping does not swapcase non-ASCII characters" # ArgumentError: [String#swapcase] wrong number of arguments(1 for 0)
  fails "String#swapcase ASCII-only case mapping works with substrings" # ArgumentError: [String#swapcase] wrong number of arguments (given 1, expected 0)
  fails "String#swapcase full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # ArgumentError: [String#swapcase] wrong number of arguments(2 for 0)
  fails "String#swapcase full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # ArgumentError: [String#swapcase] wrong number of arguments(1 for 0)
  fails "String#swapcase full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # ArgumentError: [String#swapcase] wrong number of arguments(2 for 0)
  fails "String#swapcase full Unicode case mapping adapted for Turkic languages swaps case of ASCII characters according to Turkic semantics" # ArgumentError: [String#swapcase] wrong number of arguments(1 for 0)
  fails "String#swapcase full Unicode case mapping updates string metadata" # Expected "aßET" to equal "aSSET"
  fails "String#swapcase full Unicode case mapping works for all of Unicode with no option" # Expected "äÖü" to equal "ÄöÜ"
  fails "String#swapcase returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#to_c allows null-byte" # Expected (1-2i) == (1+0i) to be truthy but was false
  fails "String#to_c ignores leading whitespaces" # Expected (79+79i) == (79+4i) to be truthy but was false
  fails "String#to_c raises Encoding::CompatibilityError if String is in not ASCII-compatible encoding" # Expected CompatibilityError (ASCII incompatible encoding: UTF-16) but got: ArgumentError (unknown encoding name - UTF-16)
  fails "String#to_c understands 'a+i' to mean a complex number with 'a' as the real part, 1i as the imaginary" # Expected (79+0i) == (79+1i) to be truthy but was false
  fails "String#to_c understands 'a-i' to mean a complex number with 'a' as the real part, -1i as the imaginary" # Expected (79+0i) == (79-1i) to be truthy but was false
  fails "String#to_c understands 'm@a' to mean a complex number in polar form with 'm' as the modulus, 'a' as the argument" # Expected (79+4i) == (-51.63784604822534-59.78739712932633i) to be truthy but was false
  fails "String#to_c understands Float::INFINITY" # Expected (0+0i) == (0+1i) to be truthy but was false
  fails "String#to_c understands scientific notation with e and E" # Expected (2+3i) == (2000+20000i) to be truthy but was false
  fails "String#to_sym ignores existing symbols with different encoding" # Expected #<Encoding:UTF-8> == #<Encoding:ISO-8859-1> to be truthy but was false
  fails "String#to_sym raises an EncodingError for UTF-8 String containing invalid bytes" # Expected true to equal false
  fails "String#to_sym returns a US-ASCII Symbol for a UTF-8 String containing only US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "String#to_sym returns a US-ASCII Symbol for a binary String containing only US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "String#to_sym returns a UTF-16LE Symbol for a UTF-16LE String containing non US-ASCII characters" # ERROR
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
  fails "String#undump returns a String in the same encoding as self" # NoMethodError: undefined method `undump' for "\"foo\""
  fails "String#undump returns a string with # not escaped when followed by any other character" # NoMethodError: undefined method `undump' for "\"#\""
  fails "String#undump returns a string with \\uXXXX notation replaced with multi-byte UTF-8 characters" # NoMethodError: undefined method `undump' for "\"\\u0080\""
  fails "String#undump returns a string with \\u{} notation replaced with multi-byte UTF-8 characters" # NoMethodError: undefined method `undump' for "\"\\u80\""
  fails "String#undump returns a string with \\x notation replaced with non-printing ASCII character" # NoMethodError: undefined method `undump' for "\"\\x00\""
  fails "String#undump returns a string with lower-case alpha characters unescaped" # NoMethodError: undefined method `undump' for "\"a\""
  fails "String#undump returns a string with numeric characters unescaped" # NoMethodError: undefined method `undump' for "\"0\""
  fails "String#undump returns a string with printable non-alphanumeric characters" # NoMethodError: undefined method `undump' for "\" \""
  fails "String#undump returns a string with special characters in \\<char> notation replaced with the characters" # NoMethodError: undefined method `undump' for "\"\\a\""
  fails "String#undump returns a string with unescaped sequences \" and \\" # NoMethodError: undefined method `undump' for "\"\\\"\""
  fails "String#undump returns a string with unescaped sequences \\#<char> when # is followed by $, @, {" # NoMethodError: undefined method `undump' for "\"\\\#$PATH\""
  fails "String#undump returns a string with upper-case alpha characters unescaped" # NoMethodError: undefined method `undump' for "\"A\""
  fails "String#undump strips outer \"" # NoMethodError: undefined method `undump' for "\"foo\""
  fails "String#undump undumps correctly string produced from non ASCII-compatible one" # NoMethodError: undefined method `dump' for "ࡶ"
  fails "String#unicode_normalize raises an Encoding::CompatibilityError if string is not in an unicode encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "String#unicode_normalized? raises an Encoding::CompatibilityError if the string is not in an unicode encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "String#unicode_normalized? returns true if str is in Unicode normalization form (nfc)" # Expected true to be false
  fails "String#unicode_normalized? returns true if str is in Unicode normalization form (nfd)" # Expected true to be false
  fails "String#unicode_normalized? returns true if str is in Unicode normalization form (nfkc)" # Expected true to be false
  fails "String#unicode_normalized? returns true if str is in Unicode normalization form (nfkd)" # Expected true to be false
  fails "String#unpack with format 'B' decodes into US-ASCII string values" # Expected "UTF-8" == "US-ASCII" to be truthy but was false
  fails "String#unpack with format 'M' unpacks incomplete escape sequences as literal characters" # Expected ["foo"] == ["foo="] to be truthy but was false
  fails "String#unpack with format 'Z' does not advance past the null byte when given a 'Z' format specifier" # RuntimeError: Unsupported unpack directive "x" (no chunk reader defined)
  fails "String#unpack with format 'm' when given count 0 raises an ArgumentError for an invalid base64 character" # Expected ArgumentError but no exception was raised (["test"] was returned)
  fails "String#unpack1 returns the first value of #unpack" # RuntimeError: Unsupported unpack directive "x" (no chunk reader defined)
  fails "String#unpack1 starts unpacking from the given offset" # RuntimeError: Unsupported unpack directive "x" (no chunk reader defined)
  fails "String#upcase ASCII-only case mapping does not upcase non-ASCII characters" # ArgumentError: [String#upcase] wrong number of arguments(1 for 0)
  fails "String#upcase ASCII-only case mapping works with substrings" # ArgumentError: [String#upcase] wrong number of arguments (given 1, expected 0)
  fails "String#upcase full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # ArgumentError: [String#upcase] wrong number of arguments(2 for 0)
  fails "String#upcase full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # ArgumentError: [String#upcase] wrong number of arguments(1 for 0)
  fails "String#upcase full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # ArgumentError: [String#upcase] wrong number of arguments(2 for 0)
  fails "String#upcase full Unicode case mapping adapted for Turkic languages upcases ASCII characters according to Turkic semantics" # ArgumentError: [String#upcase] wrong number of arguments(1 for 0)
  fails "String#upcase returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#valid_encoding? returns true for IBM720 encoding self is valid in" # ArgumentError: unknown encoding name - IBM720
  fails "String.new accepts an encoding argument" # ArgumentError: [String.new] wrong number of arguments(2 for -1)
  fails "String.new is called on subclasses" # Expected nil to equal "subclass"
  fails_badly "String#split with Regexp returns Strings in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
end
