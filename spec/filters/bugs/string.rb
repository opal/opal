# NOTE: run bin/format-filters after changing this file
opal_filter "String" do
  fails "String#% %c raises error when a codepoint isn't representable in an encoding of a format string" # Expected RangeError (out of char range) but no exception was raised ("Ԇ" was returned)
  fails "String#% %c uses the encoding of the format string to interpret codepoints" # Exception: Invalid code point 9415601
  fails "String#% can produce a string with invalid encoding" # Expected #<Encoding:ASCII-8BIT> == #<Encoding:UTF-8> to be truthy but was false
  fails "String#% formats single % character before a NUL as literal %" # ArgumentError: malformed format string
  fails "String#% formats single % character before a newline as literal %" # ArgumentError: malformed format string
  fails "String#% integer formats d works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "String#% integer formats i works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "String#% integer formats u works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "String#% other formats c raises TypeError if argument is nil" # Expected TypeError (no implicit conversion from nil to integer) but got: TypeError (no implicit conversion of NilClass into Integer)
  fails "String#% other formats c raises TypeError if converting to Integer with to_int returns non-Integer" # Expected TypeError (can't convert BasicObject to Integer) but got: TypeError (can't convert BasicObject into Integer (BasicObject#to_int gives String))
  fails "String#% other formats c raises TypeError if converting to String with to_str returns non-String" # Expected TypeError (can't convert BasicObject to String) but no exception was raised ("f" was returned)
  fails "String#% output's encoding raises if a compatible encoding can't be found" # Expected CompatibilityError but no exception was raised ("hello world" was returned)
  fails "String#% raises Encoding::CompatibilityError if both encodings are ASCII compatible and there are not ASCII characters" # Expected CompatibilityError but no exception was raised ("Ä Ђ" was returned)
  fails "String#% raises an ArgumentError for unused arguments when $DEBUG is true" # Expected ArgumentError but no exception was raised ("" was returned)
  fails "String#% replaces trailing absolute argument specifier without type with percent sign" # ArgumentError: malformed format string
  fails "String#% returns a String in the same encoding as the format String if compatible" # Expected #<Encoding:UTF-8> to be identical to #<Encoding:KOI8_U (dummy)>
  fails "String#% supports inspect formats using %p" # Expected "{\"capture\"=>1}" == "{:capture=>1}" to be truthy but was false
  fails "String#% supports negative bignums with %u or %d" # Expected "-18446744073709552000" == "-18446744073709551621" to be truthy but was false
  fails "String#* raises a RangeError when given integer is a Bignum" # Expected RangeError but no exception was raised ("" was returned)
  fails "String#+ when self and the argument are in different ASCII-compatible encodings raises Encoding::CompatibilityError if neither are ASCII-only" # Expected CompatibilityError but no exception was raised ("éé" was returned)
  fails "String#+ when self and the argument are in different ASCII-compatible encodings uses the argument's encoding if self is ASCII-only" # Expected #<Encoding:UTF-8> == #<Encoding:ISO-8859-1> to be truthy but was false
  fails "String#+ when self is in an ASCII-incompatible encoding incompatible with the argument's encoding raises Encoding::CompatibilityError if neither are empty" # Expected CompatibilityError but no exception was raised ("xy" was returned)
  fails "String#+ when the argument is in an ASCII-incompatible encoding incompatible with self's encoding raises Encoding::CompatibilityError if neither are empty" # Expected CompatibilityError but no exception was raised ("xy" was returned)
  fails "String#-@ does not deduplicate a frozen string when it has instance variables" # Exception: Cannot create property 'a' on string 'this string is frozen'
  fails "String#-@ returns the same object for equal unfrozen strings" # Expected "this is a string" not to be identical to "this is a string"
  fails "String#<< raises a NoMethodError if the given argument raises a NoMethodError during type coercion to a String" # Expected NoMethodError but got: NotImplementedError (String#<< not supported. Mutable String methods are not supported in Opal.)
  fails "String#<< when self is BINARY and argument is US-ASCII uses BINARY encoding" # NotImplementedError: String#<< not supported. Mutable String methods are not supported in Opal.
  fails "String#<< with Integer returns a BINARY string if self is US-ASCII and the argument is between 128-255 (inclusive)" # NotImplementedError: String#<< not supported. Mutable String methods are not supported in Opal.
  fails "String#<=> with String compares the indices of the encodings when the strings have identical non-ASCII-compatible bytes" # Expected 0 == -1 to be truthy but was false
  fails "String#== considers encoding compatibility" # Expected true to be false
  fails "String#== considers encoding difference of incompatible string" # Expected true to be false
  fails "String#=== considers encoding compatibility" # Expected true to be false
  fails "String#=== considers encoding difference of incompatible string" # Expected true to be false
  fails "String#byteindex raises on type errors raises a TypeError if passed a Symbol" # Expected TypeError (no implicit conversion of MockObject into String) but got: NoMethodError (undefined method `byteindex' for "hello")
  fails "String#byteindex with Regexp supports \\G which matches at the given start offset" # NoMethodError: undefined method `byteindex' for "helloYOU."
  fails "String#byteindex with String raises an Encoding::CompatibilityError if the encodings are incompatible" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#byteindex with multibyte codepoints raises an Encoding::CompatibilityError if the encodings are incompatible" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#byterindex with object raises on type errors raises a TypeError if passed a Symbol" # Expected TypeError (no implicit conversion of MockObject into String) but got: NoMethodError (undefined method `byterindex' for "hello")
  fails "String#byterindex with object with multibyte codepoints raises an Encoding::CompatibilityError if the encodings are incompatible" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#bytesplice mutates self" # NoMethodError: undefined method `bytesplice' for "hello"
  fails "String#bytesplice raises IndexError for negative length" # Expected IndexError (negative length -2) but got: NoMethodError (undefined method `bytesplice' for "abc")
  fails "String#bytesplice raises IndexError when index is greater than bytesize" # Expected IndexError (index 6 out of string) but got: NoMethodError (undefined method `bytesplice' for "hello")
  fails "String#bytesplice raises IndexError when index is less than -bytesize" # Expected IndexError (index -6 out of string) but got: NoMethodError (undefined method `bytesplice' for "hello")
  fails "String#bytesplice raises RangeError when range left boundary is less than -bytesize" # Expected RangeError (-6...-6 out of range) but got: NoMethodError (undefined method `bytesplice' for "hello")
  fails "String#bytesplice raises TypeError when integer index is provided without length argument" # Expected TypeError (wrong argument type Integer (expected Range)) but got: NoMethodError (undefined method `bytesplice' for "hello")
  fails "String#bytesplice raises when string is frozen" # Expected FrozenError (can't modify frozen String: "hello") but got: NoMethodError (undefined method `bytesplice' for "hello")
  fails "String#bytesplice replaces on an empty string" # NoMethodError: undefined method `bytesplice' for ""
  fails "String#bytesplice replaces with integer indices" # NoMethodError: undefined method `bytesplice' for "hello"
  fails "String#bytesplice replaces with ranges" # NoMethodError: undefined method `bytesplice' for "hello"
  fails "String#bytesplice with multibyte characters deals with a different encoded argument" # NoMethodError: undefined method `bytesplice' for "こんにちは"
  fails "String#bytesplice with multibyte characters raises IndexError when index is not on a codepoint boundary" # Expected IndexError (offset 1 does not land on character boundary) but got: NoMethodError (undefined method `bytesplice' for "こんにちは")
  fails "String#bytesplice with multibyte characters raises IndexError when index is out of byte size boundary" # Expected IndexError (index -16 out of string) but got: NoMethodError (undefined method `bytesplice' for "こんにちは")
  fails "String#bytesplice with multibyte characters raises IndexError when length is not matching the codepoint boundary" # Expected IndexError (offset 1 does not land on character boundary) but got: NoMethodError (undefined method `bytesplice' for "こんにちは")
  fails "String#bytesplice with multibyte characters raises when ranges not match codepoint boundaries" # Expected IndexError (offset 1 does not land on character boundary) but got: NoMethodError (undefined method `bytesplice' for "こんにちは")
  fails "String#bytesplice with multibyte characters replaces with integer indices" # NoMethodError: undefined method `bytesplice' for "こんにちは"
  fails "String#bytesplice with multibyte characters replaces with range" # NoMethodError: undefined method `bytesplice' for "こんにちは"
  fails "String#bytesplice with multibyte characters treats negative length for range as 0" # NoMethodError: undefined method `bytesplice' for "こんにちは"
  fails "String#capitalize full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # ArgumentError: [String#capitalize] wrong number of arguments (given 2, expected 0)
  fails "String#capitalize full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # ArgumentError: [String#capitalize] wrong number of arguments (given 1, expected 0)
  fails "String#capitalize full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # ArgumentError: [String#capitalize] wrong number of arguments (given 2, expected 0)
  fails "String#capitalize full Unicode case mapping adapted for Turkic languages capitalizes ASCII characters according to Turkic semantics" # ArgumentError: [String#capitalize] wrong number of arguments (given 1, expected 0)
  fails "String#capitalize! raises a FrozenError when self is frozen" # Expected FrozenError but got: NotImplementedError (String#capitalize! not supported. Mutable String methods are not supported in Opal.)
  fails "String#casecmp independent of case returns nil if incompatible encodings" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#casecmp? independent of case returns nil if incompatible encodings" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#chars works if the String's contents is invalid for its encoding" # Expected true to be false
  fails "String#chomp when passed no argument returns a copy of the String when it is not modified" # Expected "abc" not to be identical to "abc"
  fails "String#chomp! raises a FrozenError on a frozen instance when it is modified" # Expected FrozenError but got: NotImplementedError (String#chomp! not supported. Mutable String methods are not supported in Opal.)
  fails "String#chomp! raises a FrozenError on a frozen instance when it would not be modified" # Expected FrozenError but got: NotImplementedError (String#chomp! not supported. Mutable String methods are not supported in Opal.)
  fails "String#chop! raises a FrozenError on a frozen instance that is modified" # Expected FrozenError but got: NotImplementedError (String#chop! not supported. Mutable String methods are not supported in Opal.)
  fails "String#chop! raises a FrozenError on a frozen instance that would not be modified" # Expected FrozenError but got: NotImplementedError (String#chop! not supported. Mutable String methods are not supported in Opal.)
  fails "String#clear raises a FrozenError if self is frozen" # Expected FrozenError but got: NotImplementedError (String#clear not supported. Mutable String methods are not supported in Opal.)
  fails "String#clone calls #initialize_copy on the new instance" # Expected nil == "string" to be truthy but was false
  fails "String#clone copies singleton methods" # TypeError: can't define singleton
  fails "String#codepoints raises an ArgumentError if self's encoding is invalid and a block is given" # Expected true to be false
  fails "String#codepoints raises an ArgumentError when no block is given if self has an invalid encoding" # Expected true to be false
  fails "String#codepoints raises an ArgumentError when self has an invalid encoding and a method is called on the returned Enumerator" # Expected true to be false
  fails "String#concat raises a NoMethodError if the given argument raises a NoMethodError during type coercion to a String" # Mock 'world!' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "String#concat when self is BINARY and argument is US-ASCII uses BINARY encoding" # NoMethodError: undefined method `concat' for "abc"
  fails "String#concat with Integer returns a BINARY string if self is US-ASCII and the argument is between 128-255 (inclusive)" # NoMethodError: undefined method `concat' for ""
  fails "String#crypt calls #to_str to converts the salt arg to a String" # Mock 'aa' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "String#crypt doesn't return subclass instances" # NoMethodError: undefined method `crypt' for "hello"
  fails "String#crypt raises a type error when the salt arg can't be converted to a string" # Expected TypeError but got: NoMethodError (undefined method `crypt' for "")
  fails "String#crypt raises an ArgumentError when the salt is shorter than two characters" # Expected ArgumentError but got: NoMethodError (undefined method `crypt' for "hello")
  fails "String#crypt raises an ArgumentError when the string contains NUL character" # Expected ArgumentError but got: NoMethodError (undefined method `crypt' for "poison\u0000null")
  fails "String#crypt returns a cryptographic hash of self by applying the UNIX crypt algorithm with the specified salt" # NoMethodError: undefined method `crypt' for ""
  fails "String#delete! raises a FrozenError when self is frozen" # Expected FrozenError but got: NoMethodError (undefined method `delete!' for "hello")
  fails "String#delete_prefix! raises a FrozenError when self is frozen" # Expected FrozenError but got: NoMethodError (undefined method `delete_prefix!' for "hello")
  fails "String#delete_suffix! raises a FrozenError when self is frozen" # Expected FrozenError but got: NoMethodError (undefined method `delete_suffix!' for "hello")
  fails "String#downcase full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # ArgumentError: [String#downcase] wrong number of arguments (given 2, expected 0)
  fails "String#downcase full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # ArgumentError: [String#downcase] wrong number of arguments (given 1, expected 0)
  fails "String#downcase full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # ArgumentError: [String#downcase] wrong number of arguments (given 2, expected 0)
  fails "String#downcase full Unicode case mapping adapted for Turkic languages downcases characters according to Turkic semantics" # ArgumentError: [String#downcase] wrong number of arguments (given 1, expected 0)
  fails "String#downcase! raises a FrozenError when self is frozen" # Expected FrozenError but got: NotImplementedError (String#downcase! not supported. Mutable String methods are not supported in Opal.)
  fails "String#dump includes .force_encoding(name) if the encoding isn't ASCII compatible" # NoMethodError: undefined method `dump' for "ࡶ"
  fails "String#dump returns a String in the same encoding as self" # NoMethodError: undefined method `dump' for "foo"
  fails "String#dup calls #initialize_copy on the new instance" # Expected nil == "string" to be truthy but was false
  fails "String#dup does not modify the original setbyte-mutated string when changing dupped string" # NoMethodError: undefined method `setbyte' for "a"
  fails "String#each_byte keeps iterating from the old position (to new string end) when self changes" # NotImplementedError: String#<< not supported. Mutable String methods are not supported in Opal.
  fails "String#each_char works if the String's contents is invalid for its encoding" # Expected true to be false
  fails "String#each_codepoint raises an ArgumentError if self's encoding is invalid and a block is given" # Expected true to be false
  fails "String#each_codepoint raises an ArgumentError when self has an invalid encoding and a method is called on the returned Enumerator" # Expected true to be false
  fails "String#each_codepoint when no block is given returned Enumerator size should return the size of the string even when the string has an invalid encoding" # Expected true to be false
  fails "String#each_codepoint when no block is given returns an Enumerator even when self has an invalid encoding" # Expected true to be false
  fails "String#each_grapheme_cluster returns a different character if the String is transcoded" # NoMethodError: undefined method `each_grapheme_cluster' for "€"
  fails "String#each_grapheme_cluster uses the String's encoding to determine what characters it contains" # NoMethodError: undefined method `each_grapheme_cluster' for "𤭢"
  fails "String#each_grapheme_cluster works if the String's contents is invalid for its encoding" # Expected true to be false
  fails "String#encode when passed options replace multiple invalid bytes at the end with a single replacement character" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode when passed to, from, options returns a copy in the destination encoding when both encodings are the same" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! raises a FrozenError when called on a frozen String when it's a no-op" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! raises a FrozenError when called on a frozen String" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encoding for Strings with \\x escapes returns BINARY when an escape creates a byte with the 8th bit set if the source encoding is US-ASCII" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#end_with? checks that we are starting to match at the head of a character" # Expected "ab".end_with? "b" to be falsy but was true
  fails "String#end_with? raises an Encoding::CompatibilityError if the encodings are incompatible" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#eql? considers encoding compatibility" # Expected true to be false
  fails "String#eql? considers encoding difference of incompatible string" # Expected true to be false
  fails "String#force_encoding raises a FrozenError if self is frozen" # Expected FrozenError but no exception was raised ("abcd" was returned)
  fails "String#force_encoding with a special encoding name defaults to BINARY if special encoding name is not set" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#freeze doesn't produce the same object for different instances of literals in the source" # Expected "abc" not to be identical to "abc"
  fails "String#grapheme_clusters returns a different character if the String is transcoded" # NoMethodError: undefined method `grapheme_clusters' for "€"
  fails "String#grapheme_clusters uses the String's encoding to determine what characters it contains" # NoMethodError: undefined method `grapheme_clusters' for "𤭢"
  fails "String#grapheme_clusters works if the String's contents is invalid for its encoding" # Expected true to be false
  fails "String#gsub with pattern and block does not set $~ for procs created from methods" # Expected "he<l><l>o" == "he<unset><unset>o" to be truthy but was false
  fails "String#gsub with pattern and block raises an Encoding::CompatibilityError if the encodings are not compatible" # Expected CompatibilityError but got: ArgumentError (unknown encoding name - iso-8859-5)
  fails "String#gsub with pattern and block replaces the incompatible part properly even if the encodings are not compatible" # ArgumentError: unknown encoding name - iso-8859-5
  fails "String#gsub with pattern and block uses the compatible encoding if they are compatible" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "String#gsub with pattern and replacement doesn't freak out when replacing ^" # Expected  " Text  " ==  " Text " to be truthy but was false
  fails "String#gsub with pattern and replacement handles a pattern in a superset encoding" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#gsub with pattern and replacement replaces \\k named backreferences with the regexp's corresponding capture" # Expected "h<\\k<foo>>ll<\\k<foo>>" == "h<e>ll<o>" to be truthy but was false
  fails "String#gsub with pattern and replacement supports \\G which matches at the beginning of the remaining (non-matched) string" # Expected "hello homely world. hah!" == "huh? huh? world. hah!" to be truthy but was false
  fails "String#gsub! with pattern and block raises a FrozenError when self is frozen" # Expected FrozenError but got: NotImplementedError (String#gsub! not supported. Mutable String methods are not supported in Opal.)
  fails "String#gsub! with pattern and replacement raises a FrozenError when self is frozen" # Expected FrozenError but got: NotImplementedError (String#gsub! not supported. Mutable String methods are not supported in Opal.)
  fails "String#include? with String raises an Encoding::CompatibilityError if the encodings are incompatible" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#initialize with no arguments does not raise an exception when frozen" # Expected nil to be identical to "hello"
  fails "String#insert with index, other raises a FrozenError if self is frozen" # Expected FrozenError but got: NoMethodError (undefined method `insert' for "abcd")
  fails "String#insert with index, other should not call subclassed string methods" # NoMethodError: undefined method `insert' for "abcd"
  fails "String#inspect when the string's encoding is different than the result's encoding and the string has both ASCII-compatible and ASCII-incompatible chars returns a string with the non-ASCII characters replaced by \\u notation" # Expected "\"hello привет\"" == "\"hello \\u043F\\u0440\\u0438\\u0432\\u0435\\u0442\"" to be truthy but was false
  fails "String#inspect when the string's encoding is different than the result's encoding and the string's encoding is ASCII-compatible but the characters are non-ASCII returns a string with the non-ASCII characters replaced by \\x notation" # ArgumentError: unknown encoding name - EUC-JP
  fails "String#inspect works for broken US-ASCII strings" # Expected "\"©\"" == "\"\\xC2\\xA9\"" to be truthy but was false
  fails "String#intern ignores existing symbols with different encoding" # Expected #<Encoding:UTF-8> == #<Encoding:ISO-8859-1> to be truthy but was false
  fails "String#intern raises an EncodingError for UTF-8 String containing invalid bytes" # Expected "Ã".valid_encoding? to be falsy but was true
  fails "String#intern returns a US-ASCII Symbol for a UTF-8 String containing only US-ASCII characters" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#intern returns a US-ASCII Symbol for a binary String containing only US-ASCII characters" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#intern returns a UTF-16LE Symbol for a UTF-16LE String containing non US-ASCII characters" # Expected #<Encoding:UTF-8> == #<Encoding:UTF-16LE> to be truthy but was false
  fails "String#intern returns a binary Symbol for a binary String containing non US-ASCII characters" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "String#length adds 1 (and not 2) for a incomplete surrogate in UTF-16" # Expected 2 == 1 to be truthy but was false
  fails "String#length adds 1 for a broken sequence in UTF-32" # Expected 4 == 1 to be truthy but was false
  fails "String#length returns the correct length after force_encoding(BINARY)" # Expected 2 == 4 to be truthy but was false
  fails "String#ljust with length, padding with width, pattern returns a String in the compatible encoding" # Expected #<Encoding:IBM437 (dummy)> to be identical to #<Encoding:UTF-8>
  fails "String#lstrip returns a String in the same encoding as self" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#lstrip! raises a FrozenError on a frozen instance that is modified" # Expected FrozenError but got: NotImplementedError (String#lstrip! not supported. Mutable String methods are not supported in Opal.)
  fails "String#lstrip! raises a FrozenError on a frozen instance that would not be modified" # Expected FrozenError but got: NotImplementedError (String#lstrip! not supported. Mutable String methods are not supported in Opal.)
  fails "String#ord raises ArgumentError if the character is broken" # Expected ArgumentError (invalid byte sequence in US-ASCII) but no exception was raised (169 was returned)
  fails "String#partition with String handles a pattern in a superset encoding" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#partition with String returns String instances when called on a subclass" # Expected "hello" (StringSpecs::MyString) to be an instance of String
  fails "String#prepend raises a FrozenError when self is frozen" # Expected FrozenError but got: NotImplementedError (String#prepend not supported. Mutable String methods are not supported in Opal.)
  fails "String#reverse works with a broken string" # Expected true to be false
  fails "String#reverse! raises a FrozenError on a frozen instance that is modified" # Expected FrozenError but got: NotImplementedError (String#reverse! not supported. Mutable String methods are not supported in Opal.)
  fails "String#reverse! raises a FrozenError on a frozen instance that would not be modified" # Expected FrozenError but got: NotImplementedError (String#reverse! not supported. Mutable String methods are not supported in Opal.)
  fails "String#rindex with String raises an Encoding::CompatibilityError if the encodings are incompatible" # ArgumentError: unknown encoding name - ISO-2022-JP
  fails "String#rjust with length, padding with width, pattern returns a String in the compatible encoding" # Expected #<Encoding:IBM437 (dummy)> to be identical to #<Encoding:UTF-8>
  fails "String#rpartition with String handles a pattern in a superset encoding" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#rpartition with String returns String instances when called on a subclass" # Expected "hello" (StringSpecs::MyString) to be an instance of String
  fails "String#rpartition with String returns new object if doesn't match" # Expected "hello".equal? "hello" to be falsy but was true
  fails "String#rstrip! raises a FrozenError on a frozen instance that is modified" # Expected FrozenError but got: NoMethodError (undefined method `rstrip!' for "  hello  ")
  fails "String#rstrip! raises a FrozenError on a frozen instance that would not be modified" # Expected FrozenError but got: NoMethodError (undefined method `rstrip!' for "hello")
  fails "String#rstrip! raises an Encoding::CompatibilityError if the last non-space codepoint is invalid" # Expected true to be false
  fails "String#scrub with a block replaces invalid byte sequences using a custom encoding" # Expected "\uFFFD\uFFFD" == "€€" to be truthy but was false
  fails "String#scrub with a block replaces invalid byte sequences" # Expected "abcあã\u0080" == "abcあ<e380>" to be truthy but was false
  fails "String#scrub with a custom replacement raises ArgumentError for replacements with an invalid encoding" # Expected ArgumentError but no exception was raised ("foo\u0081" was returned)
  fails "String#scrub with a custom replacement replaces an incomplete character at the end with a single replacement" # Expected "ã\u0080" == "*" to be truthy but was false
  fails "String#scrub with a custom replacement replaces invalid byte sequences in frozen strings" # Expected "abcあ\u0081" == "abcあ*" to be truthy but was false
  fails "String#scrub with a custom replacement replaces invalid byte sequences" # Expected "abcあ\u0081" == "abcあ*" to be truthy but was false
  fails "String#scrub with a default replacement replaces invalid byte sequences in lazy substrings" # Expected "bcあ\u0081de" == "bcあ\uFFFDde" to be truthy but was false
  fails "String#scrub with a default replacement replaces invalid byte sequences when using ASCII as the input encoding" # Expected "abc??‚???€" == "abc?????" to be truthy but was false
  fails "String#scrub with a default replacement replaces invalid byte sequences" # Expected "abcあ\u0081" == "abcあ\uFFFD" to be truthy but was false
  fails "String#setbyte raises a FrozenError if self is frozen" # Expected FrozenError but got: NoMethodError (undefined method `setbyte' for "cold")
  fails "String#size adds 1 (and not 2) for a incomplete surrogate in UTF-16" # Expected 2 == 1 to be truthy but was false
  fails "String#size adds 1 for a broken sequence in UTF-32" # Expected 4 == 1 to be truthy but was false
  fails "String#size returns the correct length after force_encoding(BINARY)" # Expected 2 == 4 to be truthy but was false
  fails "String#slice! Range raises a FrozenError on a frozen instance that is modified" # Expected FrozenError but got: NotImplementedError (String#slice! not supported. Mutable String methods are not supported in Opal.)
  fails "String#slice! Range raises a FrozenError on a frozen instance that would not be modified" # Expected FrozenError but got: NotImplementedError (String#slice! not supported. Mutable String methods are not supported in Opal.)
  fails "String#slice! with Regexp raises a FrozenError on a frozen instance that is modified" # Expected FrozenError but got: NotImplementedError (String#slice! not supported. Mutable String methods are not supported in Opal.)
  fails "String#slice! with Regexp raises a FrozenError on a frozen instance that would not be modified" # Expected FrozenError but got: NotImplementedError (String#slice! not supported. Mutable String methods are not supported in Opal.)
  fails "String#slice! with Regexp, index raises a FrozenError if self is frozen" # Expected FrozenError but got: NotImplementedError (String#slice! not supported. Mutable String methods are not supported in Opal.)
  fails "String#slice! with String raises a FrozenError if self is frozen" # Expected FrozenError but got: NotImplementedError (String#slice! not supported. Mutable String methods are not supported in Opal.)
  fails "String#slice! with index raises a FrozenError if self is frozen" # Expected FrozenError but got: NotImplementedError (String#slice! not supported. Mutable String methods are not supported in Opal.)
  fails "String#slice! with index, length raises a FrozenError if self is frozen" # Expected FrozenError but got: NotImplementedError (String#slice! not supported. Mutable String methods are not supported in Opal.)
  fails "String#split with Regexp allows concurrent Regexp calls in a shared context" # NotImplementedError: Thread creation not available
  fails "String#split with Regexp raises a TypeError when not called with nil, String, or Regexp" # Expected TypeError but no exception was raised (["he", "o"] was returned)
  fails "String#split with Regexp returns String instances based on self" # Expected "x:y:z:" (StringSpecs::MyString) to be an instance of String
  fails "String#split with Regexp returns an ArgumentError if an invalid UTF-8 string is supplied" # NotImplementedError: String#chop! not supported. Mutable String methods are not supported in Opal.
  fails "String#split with Regexp throws an ArgumentError if the string  is not a valid" # Expected ArgumentError but no exception was raised ([] was returned)
  fails "String#split with String raises a RangeError when the limit is larger than int" # Expected RangeError but no exception was raised (["a,b"] was returned)
  fails "String#split with String returns String instances based on self" # Expected "x.y.z." (StringSpecs::MyString) to be an instance of String
  fails "String#split with String throws an ArgumentError if the pattern is not a valid string" # Expected ArgumentError but no exception was raised (["проверка"] was returned)
  fails "String#split with String throws an ArgumentError if the string  is not a valid" # Expected ArgumentError but no exception was raised (["ß"] was returned)
  fails "String#split with String when $; is not nil warns" # Expected warning to match: /warning: \$; is set to non-nil value/ but got: ""
  fails "String#squeeze! raises a FrozenError when self is frozen" # Expected FrozenError but got: NotImplementedError (String#squeeze! not supported. Mutable String methods are not supported in Opal.)
  fails "String#start_with? does not check that we are not matching part of a character" # Expected "é".start_with? "Ã" to be truthy but was false
  fails "String#start_with? does not check we are matching only part of a character" # Expected "あ".start_with? "ã" to be truthy but was false
  fails "String#strip! raises a FrozenError on a frozen instance that is modified" # Expected FrozenError but got: NotImplementedError (String#strip! not supported. Mutable String methods are not supported in Opal.)
  fails "String#strip! raises a FrozenError on a frozen instance that would not be modified" # Expected FrozenError but got: NotImplementedError (String#strip! not supported. Mutable String methods are not supported in Opal.)
  fails "String#sub with pattern, replacement handles a pattern in a superset encoding" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#sub with pattern, replacement returns a copy of self when no modification is made" # Expected "hello" not to be identical to "hello"
  fails "String#sub with pattern, replacement supports \\G which matches at the beginning of the string" # Expected "hello world!" == "hi world!" to be truthy but was false
  fails "String#sub! with pattern and block raises a FrozenError when self is frozen" # Expected FrozenError but got: NotImplementedError (String#sub! not supported. Mutable String methods are not supported in Opal.)
  fails "String#sub! with pattern, replacement raises a FrozenError when self is frozen" # Expected FrozenError but got: NotImplementedError (String#sub! not supported. Mutable String methods are not supported in Opal.)
  fails "String#swapcase full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # ArgumentError: [String#swapcase] wrong number of arguments (given 2, expected 0)
  fails "String#swapcase full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # ArgumentError: [String#swapcase] wrong number of arguments (given 1, expected 0)
  fails "String#swapcase full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # ArgumentError: [String#swapcase] wrong number of arguments (given 2, expected 0)
  fails "String#swapcase full Unicode case mapping adapted for Turkic languages swaps case of ASCII characters according to Turkic semantics" # ArgumentError: [String#swapcase] wrong number of arguments (given 1, expected 0)
  fails "String#swapcase! raises a FrozenError when self is frozen" # Expected FrozenError but got: NotImplementedError (String#swapcase! not supported. Mutable String methods are not supported in Opal.)
  fails "String#to_c allows null-byte" # Expected (1-2i) == (1+0i) to be truthy but was false
  fails "String#to_c ignores leading whitespaces" # Expected (79+79i) == (79+4i) to be truthy but was false
  fails "String#to_c ignores trailing garbage" # Expected (79+40i) == (7+0i) to be truthy but was false
  fails "String#to_c raises Encoding::CompatibilityError if String is in not ASCII-compatible encoding" # Expected CompatibilityError (ASCII incompatible encoding: UTF-16) but got: ArgumentError (unknown encoding name - UTF-16)
  fails "String#to_c treats a sequence of underscores as an end of Complex string" # Expected (5+31i) == (5+0i) to be truthy but was false
  fails "String#to_c understands 'a+i' to mean a complex number with 'a' as the real part, 1i as the imaginary" # Expected (79+0i) == (79+1i) to be truthy but was false
  fails "String#to_c understands 'a-i' to mean a complex number with 'a' as the real part, -1i as the imaginary" # Expected (79+0i) == (79-1i) to be truthy but was false
  fails "String#to_c understands 'm@a' to mean a complex number in polar form with 'm' as the modulus, 'a' as the argument" # Expected (79+4i) == (-51.63784604822534-59.78739712932633i) to be truthy but was false
  fails "String#to_c understands Float::INFINITY" # Expected (0+0i) == (0+1i) to be truthy but was false
  fails "String#to_c understands scientific notation with e and E" # Expected (2+3i) == (2000+20000i) to be truthy but was false
  fails "String#to_sym ignores existing symbols with different encoding" # Expected #<Encoding:UTF-8> == #<Encoding:ISO-8859-1> to be truthy but was false
  fails "String#to_sym raises an EncodingError for UTF-8 String containing invalid bytes" # Expected "Ã".valid_encoding? to be falsy but was true
  fails "String#to_sym returns a US-ASCII Symbol for a UTF-8 String containing only US-ASCII characters" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#to_sym returns a US-ASCII Symbol for a binary String containing only US-ASCII characters" # Expected #<Encoding:UTF-8> == #<Encoding:US-ASCII> to be truthy but was false
  fails "String#to_sym returns a UTF-16LE Symbol for a UTF-16LE String containing non US-ASCII characters" # Expected #<Encoding:UTF-8> == #<Encoding:UTF-16LE> to be truthy but was false
  fails "String#to_sym returns a binary Symbol for a binary String containing non US-ASCII characters" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT> to be truthy but was false
  fails "String#tr! raises a FrozenError if self is frozen" # Expected FrozenError but got: NotImplementedError (String#tr! not supported. Mutable String methods are not supported in Opal.)
  fails "String#tr_s! raises a FrozenError if self is frozen" # Expected FrozenError but got: NotImplementedError (String#tr_s! not supported. Mutable String methods are not supported in Opal.)
  fails "String#undump Limitations cannot undump non ASCII-compatible string" # Expected CompatibilityError but got: NoMethodError (undefined method `undump' for "\"foo\"")
  fails "String#undump always returns String instance" # NoMethodError: undefined method `undump' for "\"foo\""
  fails "String#undump does not take into account if a string is frozen" # NoMethodError: undefined method `undump' for "\"foo\""
  fails "String#undump invalid dump raises RuntimeError exception if wrapping \" are missing" # Expected RuntimeError (/invalid dumped string/) but got: NoMethodError (undefined method `undump' for "foo")
  fails "String#undump invalid dump raises RuntimeError if string contains \u0000 character" # Expected RuntimeError (/string contains null byte/) but got: NoMethodError (undefined method `undump' for "\"foo\u0000\"")
  fails "String#undump invalid dump raises RuntimeError if string contains non ASCII character" # Expected RuntimeError (/non-ASCII character detected/) but got: NoMethodError (undefined method `undump' for "\"あ\"")
  fails "String#undump invalid dump raises RuntimeError if there are some excessive \"" # Expected RuntimeError (/invalid dumped string/) but got: NoMethodError (undefined method `undump' for "\" \"\" \"")
  fails "String#undump invalid dump raises RuntimeError if there is incorrect \\x sequence" # Expected RuntimeError (/invalid hex escape/) but got: NoMethodError (undefined method `undump' for "\"\\x\"")
  fails "String#undump invalid dump raises RuntimeError if there is malformed dump of non ASCII-compatible string" # Expected RuntimeError (/invalid dumped string/) but got: NoMethodError (undefined method `undump' for "\"\".force_encoding(\"BINARY\"")
  fails "String#undump invalid dump raises RuntimeError in there is incorrect \\u sequence" # Expected RuntimeError (/invalid Unicode escape/) but got: NoMethodError (undefined method `undump' for "\"\\u\"")
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
  fails "String#unicode_normalize raises an Encoding::CompatibilityError if string is not in an unicode encoding" # Expected CompatibilityError but no exception was raised ("à" was returned)
  fails "String#unicode_normalized? raises an Encoding::CompatibilityError if the string is not in an unicode encoding" # Expected CompatibilityError but no exception was raised (true was returned)
  fails "String#unicode_normalized? returns true if str is in Unicode normalization form (nfc)" # NotImplementedError: String#unicode_normalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#unicode_normalized? returns true if str is in Unicode normalization form (nfd)" # NotImplementedError: String#unicode_normalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#unicode_normalized? returns true if str is in Unicode normalization form (nfkc)" # NotImplementedError: String#unicode_normalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#unicode_normalized? returns true if str is in Unicode normalization form (nfkd)" # NotImplementedError: String#unicode_normalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#unpack with format 'B' decodes into US-ASCII string values" # Expected "UTF-8" == "US-ASCII" to be truthy but was false
  fails "String#unpack with format 'M' unpacks incomplete escape sequences as literal characters" # Expected ["foo"] == ["foo="] to be truthy but was false
  fails "String#unpack with format 'Z' does not advance past the null byte when given a 'Z' format specifier" # RuntimeError: Unsupported unpack directive "x" (no chunk reader defined)
  fails "String#unpack with format 'm' when given count 0 raises an ArgumentError for an invalid base64 character" # Expected ArgumentError but no exception was raised (["test"] was returned)
  fails "String#unpack1 returns the first value of #unpack" # RuntimeError: Unsupported unpack directive "x" (no chunk reader defined)
  fails "String#unpack1 starts unpacking from the given offset" # RuntimeError: Unsupported unpack directive "x" (no chunk reader defined)
  fails "String#upcase full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # ArgumentError: [String#upcase] wrong number of arguments (given 2, expected 0)
  fails "String#upcase full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # ArgumentError: [String#upcase] wrong number of arguments (given 1, expected 0)
  fails "String#upcase full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # ArgumentError: [String#upcase] wrong number of arguments (given 2, expected 0)
  fails "String#upcase full Unicode case mapping adapted for Turkic languages upcases ASCII characters according to Turkic semantics" # ArgumentError: [String#upcase] wrong number of arguments (given 1, expected 0)
  fails "String#upcase! raises a FrozenError when self is frozen" # Expected FrozenError but got: NotImplementedError (String#upcase! not supported. Mutable String methods are not supported in Opal.)
  fails "String#upto raises Encoding::CompatibilityError when incompatible characters are given" # ArgumentError: unknown encoding name - EUC-JP
  fails "String#valid_encoding? returns false if self is valid in one encoding, but invalid in the one it's tagged with" # Expected true to be false
  fails "String#valid_encoding? returns true for IBM720 encoding self is valid in" # ArgumentError: unknown encoding name - IBM720
  fails "String.new is called on subclasses" # Expected "subclass" == "" to be truthy but was false
  fails "String.new returns a binary String"
  fails "String.try_convert sends #to_str to the argument and raises TypeError if it's not a kind of String" # Expected TypeError (can't convert MockObject to String (MockObject#to_str gives Object)) but got: TypeError (can't convert MockObject into String (MockObject#to_str gives Object))
end
