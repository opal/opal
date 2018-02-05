opal_filter "String" do
  fails "String#% supports inspect formats using %p" # Expected "{\"capture\"=>1}" to equal "{:capture=>1}"
  fails "String#[] raises a RangeError if the index is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#[] with index, length raises a RangeError if the index or length is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#[] with index, length returns a string with the same encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "String#bytes agrees with #unpack('C*')"
  fails "String#bytes yields each byte to a block if one is given, returning self"
  fails "String#byteslice raises a RangeError if the index is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#byteslice with index, length raises a RangeError if the index or length is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#byteslice with index, length returns a string with the same encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "String#dump includes .force_encoding(name) if the encoding isn't ASCII compatible"
  fails "String#dump returns a string with # not escaped when followed by any other character"
  fails "String#dump returns a string with \" and \\ escaped with a backslash"
  fails "String#dump returns a string with \\#<char> when # is followed by $, @, {"
  fails "String#dump returns a string with lower-case alpha characters unescaped"
  fails "String#dump returns a string with multi-byte UTF-8 characters replaced by \\u{} notation with lower-case hex digits"
  fails "String#dump returns a string with non-printing ASCII characters replaced by \\x notation"
  fails "String#dump returns a string with non-printing single-byte UTF-8 characters replaced by \\x notation"
  fails "String#dump returns a string with numeric characters unescaped"
  fails "String#dump returns a string with printable non-alphanumeric characters unescaped"
  fails "String#dump returns a string with special characters replaced with \\<char> notation"
  fails "String#dump returns a string with upper-case alpha characters unescaped"
  fails "String#dump returns a subclass instance"
  fails "String#each_byte keeps iterating from the old position (to new string end) when self changes"
  fails "String#each_byte passes each byte in self to the given block"
  fails "String#each_byte when no block is given returned enumerator size should return the bytesize of the string"
  fails "String#each_byte when no block is given returns an enumerator"
  fails "String#getbyte counts from the end of the String if given a negative argument"
  fails "String#getbyte interprets bytes relative to the String's encoding"
  fails "String#getbyte mirrors the output of #bytes"
  fails "String#getbyte raises a TypeError unless its argument can be coerced into an Integer"
  fails "String#getbyte regards a multi-byte character as having multiple bytes"
  fails "String#getbyte regards the empty String as containing no bytes"
  fails "String#getbyte returns an Integer between 0 and 255"
  fails "String#getbyte returns an Integer if given a valid index"
  fails "String#getbyte returns nil for out-of-bound indexes"
  fails "String#getbyte starts indexing at 0"
  fails "String#match? returns false when does not match the given regex" # NoMethodError: undefined method `match?' for "string":String
  fails "String#match? takes matching position as the 2nd argument" # NoMethodError: undefined method `match?' for "string":String
  fails "String#match? when matches the given regex returns true but does not set Regexp.last_match" # NoMethodError: undefined method `match?' for "string":String
  fails "String#prepend raises a RuntimeError when self is frozen" # NoMethodError: undefined method `prepend' for "hello":String
  fails "String#scan with pattern and block passes block arguments as individual arguments when blocks are provided" # Expected ["a", "b", "c"] to equal "a"
  fails "String#slice raises a RangeError if the index is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#slice with index, length raises a RangeError if the index or length is too big" # Expected RangeError but no exception was raised (nil was returned)
  fails "String#slice with index, length returns a string with the same encoding" # ArgumentError: unknown encoding name - ISO-8859-1
  fails "String#split with Regexp applies the limit to the number of split substrings, without counting captures" # Expected ["a", "aBa"] to equal ["a", "B", "", "", "aBa"]
  fails "String#sub with pattern, replacement returns a copy of self when no modification is made"
  fails "String#swapcase works for all of Unicode" # Expected "äÖü" to equal "ÄöÜ"
  fails "String#to_c returns a Complex object"
  fails "String#to_c returns a complex number with 0 as the real part, 0 as the imaginary part for unrecognised Strings"
  fails "String#to_c understands 'a+bi' to mean a complex number with 'a' as the real part, 'b' as the imaginary"
  fails "String#to_c understands 'a-bi' to mean a complex number with 'a' as the real part, '-b' as the imaginary"
  fails "String#to_c understands a '-i' by itself as denoting a complex number with an imaginary part of -1"
  fails "String#to_c understands a negative integer followed by 'i' to mean that negative integer is the imaginary part"
  fails "String#to_c understands an 'i' by itself as denoting a complex number with an imaginary part of 1"
  fails "String#to_c understands an integer followed by 'i' to mean that integer is the imaginary part"
  fails "String#to_c understands floats (a.b) for the imaginary part"
  fails "String#to_c understands floats (a.b) for the real part"
  fails "String#to_c understands fractions (numerator/denominator) for the imaginary part"
  fails "String#to_c understands fractions (numerator/denominator) for the real part"
  fails "String#to_c understands integers"
  fails "String#to_c understands negative floats (-a.b) for the imaginary part"
  fails "String#to_c understands negative floats (-a.b) for the real part"
  fails "String#to_c understands negative fractions (-numerator/denominator) for the imaginary part"
  fails "String#to_c understands negative fractions (-numerator/denominator) for the real part"
  fails "String#to_c understands negative integers"
  fails "String#to_c understands negative scientific notation for the imaginary part"
  fails "String#to_c understands negative scientific notation for the real and imaginary part in the same String"
  fails "String#to_c understands negative scientific notation for the real part"
  fails "String#to_c understands scientific notation for the imaginary part"
  fails "String#to_c understands scientific notation for the real and imaginary part in the same String"
  fails "String#to_c understands scientific notation for the real part"
  fails "String#to_r does not ignore arbitrary, non-numeric leading characters"
  fails "String#to_r does not treat a leading period without a numeric prefix as a decimal point"
  fails "String#to_r ignores leading spaces"
  fails "String#to_r ignores trailing characters"
  fails "String#to_r ignores underscores between numbers"
  fails "String#to_r returns (0/1) for Strings it can't parse"
  fails "String#to_r returns (0/1) for the empty String"
  fails "String#to_r returns (n/1) for a String starting with a decimal _n_"
  fails "String#to_r returns a Rational object"
  fails "String#to_r treats leading hypens as minus signs"
  fails "String#to_r understands a forward slash as separating the numerator from the denominator"
  fails "String#to_r understands decimal points"
  fails "String#unicode_normalize defaults to the nfc normalization form if no forms are specified"
  fails "String#unicode_normalize normalizes code points in the string according to the form that is specified"
  fails "String#unicode_normalize raises an ArgumentError if the specified form is invalid"
  fails "String#unicode_normalize raises an Encoding::CompatibilityError if string is not in an unicode encoding"
  fails "String#unicode_normalize returns normalized form of string by default 03D3 (ϓ) GREEK UPSILON WITH ACUTE AND HOOK SYMBOL"
  fails "String#unicode_normalize returns normalized form of string by default 03D4 (ϔ) GREEK UPSILON WITH DIAERESIS AND HOOK SYMBOL"
  fails "String#unicode_normalize returns normalized form of string by default 1E9B (ẛ) LATIN SMALL LETTER LONG S WITH DOT ABOVE"
  fails "String#unicode_normalize! modifies original string (nfc)"
  fails "String#unicode_normalize! modifies self in place (nfd)"
  fails "String#unicode_normalize! modifies self in place (nfkc)"
  fails "String#unicode_normalize! modifies self in place (nfkd)"
  fails "String#unicode_normalize! normalizes code points and modifies the receiving string"
  fails "String#unicode_normalize! raises an ArgumentError if the specified form is invalid"
  fails "String#unicode_normalize! raises an Encoding::CompatibilityError if the string is not in an unicode encoding"
  fails "String#unicode_normalized? defaults to the nfc normalization form if no forms are specified"
  fails "String#unicode_normalized? raises an ArgumentError if the specified form is invalid"
  fails "String#unicode_normalized? raises an Encoding::CompatibilityError if the string is not in an unicode encoding"
  fails "String#unicode_normalized? returns false if string is not in the supplied normalization form"
  fails "String#unicode_normalized? returns true if str is in Unicode normalization form (nfc)"
  fails "String#unicode_normalized? returns true if str is in Unicode normalization form (nfd)"
  fails "String#unicode_normalized? returns true if str is in Unicode normalization form (nfkc)"
  fails "String#unicode_normalized? returns true if str is in Unicode normalization form (nfkd)"
  fails "String#unicode_normalized? returns true if string does not contain any unicode codepoints"
  fails "String#unicode_normalized? returns true if string is empty"
  fails "String#unicode_normalized? returns true if string is in the specified normalization form"
  fails "String.new accepts an encoding argument"
  fails "String#casecmp? independent of case for UNICODE characters returns true when downcase(:fold) on unicode"
  fails "String#casecmp? independent of case in UTF-8 mode for non-ASCII characters returns true when they are the same with normalized case"
  fails "String#unpack1 returns the first value of #unpack" # Works, but requires "x" directive
  fails "String#% faulty key raises a KeyError"
  fails "String#% faulty key sets the Hash as the receiver of KeyError"
  fails "String#% faulty key sets the unmatched key as the key of KeyError"
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
  fails "String#% precision float types controls the number of decimal places displayed in fraction part" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "String#% precision float types does not affect G format" # Expected "12.12340000" to equal "12.1234"
  fails "String#% precision string formats determines the maximum number of characters to be copied from the string" # Expected "1" to equal "["
  fails "String#% raises Encoding::CompatibilityError if both encodings are ASCII compatible and there ano not ASCII characters" # ArgumentError: unknown encoding name - windows-1252
  fails "String#% raises an error if single % appears at the end" # Expected ArgumentError but no exception was raised ("%" was returned)
  fails "String#% returns a String in the argument's encoding if format encoding is more restrictive" # Expected #<Encoding:UTF-16LE> to be identical to #<Encoding:UTF-8>
  fails "String#% returns a String in the same encoding as the format String if compatible" # NameError: uninitialized constant Encoding::KOI8_U
  fails "String#% width specifies the minimum number of characters that will be written to the result" # Expected "         1.095200e+02" to equal "        1.095200e+02"
  fails "String#capitalize! capitalizes self in place for all of Unicode" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#codepoints is synonymous with #bytes for Strings which are single-byte optimisable" # Expected false to be true
  fails "String#downcase! modifies self in place for all of Unicode" # NotImplementedError: String#downcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#each_codepoint is synonymous with #bytes for Strings which are single-byte optimisable" # Expected false to be true
  fails "String#each_line when `chomp` keyword argument is passed removes new line characters" # TypeError: no implicit conversion of Hash into String
  fails "String#include? with String raises an Encoding::CompatibilityError if the encodings are incompatible" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#intern raises an EncodingError for UTF-8 String containing invalid bytes" # Expected true to equal false
  fails "String#intern returns a US-ASCII Symbol for a UTF-8 String containing only US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "String#intern returns a US-ASCII Symbol for a binary String containing only US-ASCII characters" # NoMethodError: undefined method `b' for "foobar":String
  fails "String#intern returns a UTF-8 Symbol for a UTF-8 String containing non US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:UTF-8>
  fails "String#intern returns a binary Symbol for a binary String containing non US-ASCII characters" # NoMethodError: undefined method `b' for "binarí":String
  fails "String#lines when `chomp` keyword argument is passed removes new line characters" # TypeError: no implicit conversion of Hash into String
  fails "String#start_with? sets Regexp.last_match if it returns true" # TypeError: no implicit conversion of Regexp into String
  fails "String#start_with? supports regexps with ^ and $ modifiers" # TypeError: no implicit conversion of Regexp into String
  fails "String#start_with? supports regexps" # TypeError: no implicit conversion of Regexp into String
  fails "String#swapcase! modifies self in place for all of Unicode" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#to_sym raises an EncodingError for UTF-8 String containing invalid bytes" # Expected true to equal false
  fails "String#to_sym returns a US-ASCII Symbol for a UTF-8 String containing only US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "String#to_sym returns a US-ASCII Symbol for a binary String containing only US-ASCII characters" # NoMethodError: undefined method `b' for "foobar":String
  fails "String#to_sym returns a UTF-8 Symbol for a UTF-8 String containing non US-ASCII characters" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:UTF-8>
  fails "String#to_sym returns a binary Symbol for a binary String containing non US-ASCII characters" # NoMethodError: undefined method `b' for "binarí":String
  fails "String#upcase! modifies self in place for all of Unicode" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
  fails "String.new accepts a capacity argument" # ArgumentError: [String.new] wrong number of arguments(2 for -1)
end
