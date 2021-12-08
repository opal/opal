# NOTE: run bin/format-filters after changing this file
opal_filter "String/Mutable" do
  fails "Binding#local_variable_set sets a local variable using a String as the variable name" # Expected "number" == 10 to be truthy but was false
  fails "Date#parse with ' ' separator can parse a 'DD mmm YYYY' string into a Date object" # Expected 2007 == 2008 to be truthy but was false
  fails "Date#parse with ' ' separator can parse a 'YYYY mmm DD' string into a Date object" # Expected 2007 == 2008 to be truthy but was false
  fails "Date#parse with ' ' separator can parse a 'mmm DD YYYY' string into a Date object" # Expected 2007 == 2008 to be truthy but was false
  fails "Date#parse with ' ' separator can parse a mmm-YYYY string into a Date object" # Expected 2007 == 2008 to be truthy but was false
  fails "Date#parse with '.' separator can parse a 'DD mmm YYYY' string into a Date object" # Expected 2007 == 2008 to be truthy but was false
  fails "Date#parse with '.' separator can parse a 'YYYY mmm DD' string into a Date object" # Expected 2007 == 2008 to be truthy but was false
  fails "Date#parse with '.' separator can parse a 'mmm DD YYYY' string into a Date object" # Expected 2007 == 2008 to be truthy but was false
  fails "Date#parse with '.' separator can parse a mmm-YYYY string into a Date object" # Expected 2007 == 2008 to be truthy but was false
  fails "Date#parse with '/' separator can parse a 'DD mmm YYYY' string into a Date object" # Expected 2007 == 2008 to be truthy but was false
  fails "Date#parse with '/' separator can parse a 'YYYY mmm DD' string into a Date object" # Expected 2007 == 2008 to be truthy but was false
  fails "Date#parse with '/' separator can parse a 'mmm DD YYYY' string into a Date object" # Expected 2007 == 2008 to be truthy but was false
  fails "Date#parse with '/' separator can parse a mmm-YYYY string into a Date object" # Expected 2007 == 2008 to be truthy but was false
  fails "File.absolute_path does not expand '~' to a home directory." # Expected "" == "" to be falsy but was true
  fails "File.absolute_path does not expand '~' when given dir argument" # Expected "." == "/~" to be truthy but was false
  fails "File.basename ignores a trailing directory separator" # Expected "bar.rb" == "bar" to be truthy but was false
  fails "File.basename returns the basename for unix suffix" # Expected "bar.txt" == "bar" to be truthy but was false
  fails "File.basename returns the basename of a path (basic cases)" # Expected "tmp.c" == "tmp" to be truthy but was false
  fails "File.expand_path when HOME is set converts a pathname to an absolute pathname, using ~ (home) as base" # Expected "" == "/rubyspec_home" to be truthy but was false
  fails "String#<< when self and the argument are in different ASCII-compatible encodings raises Encoding::CompatibilityError if neither are ASCII-only" # Expected CompatibilityError but got: NoMethodError (undefined method `<<' for "é")
  fails "String#<< when self and the argument are in different ASCII-compatible encodings uses self's encoding if both are ASCII-only" # ArgumentError: unknown encoding name - SHIFT_JIS
  fails "String#<< when self and the argument are in different ASCII-compatible encodings uses the argument's encoding if self is ASCII-only" # NoMethodError: undefined method `<<' for "abc"
  fails "String#<< when self is in an ASCII-incompatible encoding incompatible with the argument's encoding raises Encoding::CompatibilityError if neither are empty" # Expected CompatibilityError but got: NoMethodError (undefined method `<<' for "x")
  fails "String#<< when self is in an ASCII-incompatible encoding incompatible with the argument's encoding uses the argument's encoding if self is empty" # NoMethodError: undefined method `<<' for ""
  fails "String#<< when the argument is in an ASCII-incompatible encoding incompatible with self's encoding raises Encoding::CompatibilityError if neither are empty" # Expected CompatibilityError but got: NoMethodError (undefined method `<<' for "x")
  fails "String#<< when the argument is in an ASCII-incompatible encoding incompatible with self's encoding uses the argument's encoding if self is empty" # NoMethodError: undefined method `<<' for ""
  fails "String#<< with Integer concatenates the argument interpreted as a codepoint" # NoMethodError: undefined method `<<' for ""
  fails "String#<< with Integer raises RangeError if the argument is an invalid codepoint for self's encoding" # Expected RangeError but got: NoMethodError (undefined method `<<' for "")
  fails "String#<< with Integer raises RangeError if the argument is negative" # Expected RangeError but got: NoMethodError (undefined method `<<' for "")
  fails "String#[]= with Integer index allows assignment to the zero'th element of an empty String" # NoMethodError: undefined method `[]=' for ""
  fails "String#[]= with Integer index calls #to_int to convert the index" # Mock 'string element set' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "String#[]= with Integer index calls #to_str to convert other to a String" # Mock '-test-' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "String#[]= with Integer index calls to_int on index" # NoMethodError: undefined method `[]=' for "hello"
  fails "String#[]= with Integer index encodes the String in an encoding compatible with the replacement" # NoMethodError: undefined method `[]=' for " "
  fails "String#[]= with Integer index raises IndexError if the string index doesn't match a position in the string" # Expected IndexError but got: NoMethodError (undefined method `[]=' for "hello")
  fails "String#[]= with Integer index raises a FrozenError when self is frozen" # Expected FrozenError but got: NoMethodError (undefined method `[]=' for "hello")
  fails "String#[]= with Integer index raises a TypeError if #to_int does not return an Integer" # Expected TypeError but got: NoMethodError (undefined method `[]=' for "abc")
  fails "String#[]= with Integer index raises a TypeError if other_str can't be converted to a String" # Expected TypeError but got: NoMethodError (undefined method `[]=' for "test")
  fails "String#[]= with Integer index raises a TypeError if passed an Integer replacement" # Expected TypeError but got: NoMethodError (undefined method `[]=' for "abc")
  fails "String#[]= with Integer index raises an Encoding::CompatibilityError if the replacement encoding is incompatible" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#[]= with Integer index raises an IndexError if #to_int returns a value out of range" # Expected IndexError but got: NoMethodError (undefined method `[]=' for "ab")
  fails "String#[]= with Integer index raises an IndexError if the index is greater than character size" # Expected IndexError but got: NoMethodError (undefined method `[]=' for "あれ")
  fails "String#[]= with Integer index raises an IndexError without changing self if idx is outside of self" # Expected IndexError but got: NoMethodError (undefined method `[]=' for "hello")
  fails "String#[]= with Integer index replaces a character with a multibyte character" # NoMethodError: undefined method `[]=' for "ありがとu"
  fails "String#[]= with Integer index replaces a multibyte character with a character" # NoMethodError: undefined method `[]=' for "ありがとう"
  fails "String#[]= with Integer index replaces a multibyte character with a multibyte character" # NoMethodError: undefined method `[]=' for "ありがとお"
  fails "String#[]= with Integer index replaces the char at idx with other_str" # NoMethodError: undefined method `[]=' for "hello"
  fails "String#[]= with Integer index, count appends other_str to the end of the string if idx == the length of the string" # NoMethodError: undefined method `[]=' for "hello"
  fails "String#[]= with Integer index, count calls #to_int to convert the index and count objects" # Mock 'string element set index' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "String#[]= with Integer index, count calls #to_str to convert the replacement object" # Mock 'string element set replacement' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "String#[]= with Integer index, count counts negative idx values from end of the string" # NoMethodError: undefined method `[]=' for "hello"
  fails "String#[]= with Integer index, count deletes a multibyte character" # NoMethodError: undefined method `[]=' for "ありとう"
  fails "String#[]= with Integer index, count deletes characters if other_str is an empty string" # NoMethodError: undefined method `[]=' for "hello"
  fails "String#[]= with Integer index, count deletes characters up to the maximum length of the existing string" # NoMethodError: undefined method `[]=' for "hello"
  fails "String#[]= with Integer index, count encodes the String in an encoding compatible with the replacement" # NoMethodError: undefined method `[]=' for " "
  fails "String#[]= with Integer index, count inserts a multibyte character" # NoMethodError: undefined method `[]=' for "ありとう"
  fails "String#[]= with Integer index, count overwrites and deletes characters if count is more than the length of other_str" # NoMethodError: undefined method `[]=' for "hello"
  fails "String#[]= with Integer index, count raises a TypeError if #to_int for count does not return an Integer" # Expected TypeError but got: NoMethodError (undefined method `[]=' for "abc")
  fails "String#[]= with Integer index, count raises a TypeError if #to_int for index does not return an Integer" # Expected TypeError but got: NoMethodError (undefined method `[]=' for "abc")
  fails "String#[]= with Integer index, count raises a TypeError if other_str is a type other than String" # Expected TypeError but got: NoMethodError (undefined method `[]=' for "hello")
  fails "String#[]= with Integer index, count raises a TypeError of #to_str does not return a String" # Expected TypeError but got: NoMethodError (undefined method `[]=' for "abc")
  fails "String#[]= with Integer index, count raises an Encoding::CompatibilityError if the replacement encoding is incompatible" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#[]= with Integer index, count raises an IndexError if count < 0" # Expected IndexError but got: NoMethodError (undefined method `[]=' for "hello")
  fails "String#[]= with Integer index, count raises an IndexError if the character index is out of range of a multibyte String" # Expected IndexError but got: NoMethodError (undefined method `[]=' for "あれ")
  fails "String#[]= with Integer index, count raises an IndexError if |idx| is greater than the length of the string" # Expected IndexError but got: NoMethodError (undefined method `[]=' for "hello")
  fails "String#[]= with Integer index, count replaces characters with a multibyte character" # NoMethodError: undefined method `[]=' for "ありgaとう"
  fails "String#[]= with Integer index, count replaces multibyte characters with characters" # NoMethodError: undefined method `[]=' for "ありがとう"
  fails "String#[]= with Integer index, count replaces multibyte characters with multibyte characters" # NoMethodError: undefined method `[]=' for "ありがとう"
  fails "String#[]= with Integer index, count starts at idx and overwrites count characters before inserting the rest of other_str" # NoMethodError: undefined method `[]=' for "hello"
  fails "String#[]= with String index raises an IndexError if the search String is not found" # Expected IndexError but got: NoMethodError (undefined method `[]=' for "abcde")
  fails "String#[]= with String index replaces characters with no characters" # NoMethodError: undefined method `[]=' for "abcde"
  fails "String#[]= with String index replaces fewer characters with more characters" # NoMethodError: undefined method `[]=' for "abcde"
  fails "String#[]= with String index replaces more characters with fewer characters" # NoMethodError: undefined method `[]=' for "abcde"
  fails "String#[]= with a Range index raises a RangeError if negative Range begin is out of range" # Expected RangeError but got: NoMethodError (undefined method `[]=' for "abc")
  fails "String#[]= with a Range index raises a RangeError if positive Range begin is greater than String size" # Expected RangeError but got: NoMethodError (undefined method `[]=' for "abc")
  fails "String#[]= with a Range index replaces a partial string" # NoMethodError: undefined method `[]=' for "abcde"
  fails "String#[]= with a Range index replaces the contents with a longer String" # NoMethodError: undefined method `[]=' for "abc"
  fails "String#[]= with a Range index replaces the contents with a shorter String" # NoMethodError: undefined method `[]=' for "abcde"
  fails "String#[]= with a Range index treats a negative out-of-range Range end with a negative Range begin as a zero count" # NoMethodError: undefined method `[]=' for "abcd"
  fails "String#[]= with a Range index treats a negative out-of-range Range end with a positive Range begin as a zero count" # NoMethodError: undefined method `[]=' for "abc"
  fails "String#[]= with a Range index uses the Range end as an index rather than a count" # NoMethodError: undefined method `[]=' for "abcdefg"
  fails "String#[]= with a Range index with an empty replacement does not replace a character with a zero exclude-end range" # NoMethodError: undefined method `[]=' for "abc"
  fails "String#[]= with a Range index with an empty replacement does not replace a character with a zero-index, zero exclude-end range" # NoMethodError: undefined method `[]=' for "abc"
  fails "String#[]= with a Range index with an empty replacement replaces a character with a zero non-exclude-end range" # NoMethodError: undefined method `[]=' for "abc"
  fails "String#[]= with a Range index with an empty replacement replaces a character with zero-index, zero non-exclude-end range" # NoMethodError: undefined method `[]=' for "abc"
  fails "String#[]= with a Regexp index calls #to_str to convert the replacement" # Mock 'string element set regexp' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "String#[]= with a Regexp index checks the match before calling #to_str to convert the replacement" # Expected IndexError but got: NoMethodError (undefined method `[]=' for "abc")
  fails "String#[]= with a Regexp index raises IndexError if the regexp index doesn't match a position in the string" # Expected IndexError but got: NoMethodError (undefined method `[]=' for "hello")
  fails "String#[]= with a Regexp index replaces the matched text with the rhs" # NoMethodError: undefined method `[]=' for "hello"
  fails "String#[]= with a Regexp index with 3 arguments allows the specified capture to be negative and count from the end" # NoMethodError: undefined method `[]=' for "abcd"
  fails "String#[]= with a Regexp index with 3 arguments calls #to_int to convert the second object" # Mock 'string element set regexp ref' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "String#[]= with a Regexp index with 3 arguments checks the match index before calling #to_str to convert the replacement" # Expected IndexError but got: NoMethodError (undefined method `[]=' for "abc")
  fails "String#[]= with a Regexp index with 3 arguments raises IndexError if the specified capture isn't available" # Expected IndexError but got: NoMethodError (undefined method `[]=' for "aaa bbb ccc")
  fails "String#[]= with a Regexp index with 3 arguments raises a TypeError if #to_int does not return an Integer" # Expected TypeError but got: NoMethodError (undefined method `[]=' for "abc")
  fails "String#[]= with a Regexp index with 3 arguments uses the 2nd of 3 arguments as which capture should be replaced" # NoMethodError: undefined method `[]=' for "aaa bbb ccc"
  fails "String#[]= with a Regexp index with 3 arguments when the optional capture does not match raises an IndexError before setting the replacement" # Expected IndexError but got: NoMethodError (undefined method `[]=' for "a b c")
  fails "String#capitalize! full Unicode case mapping only capitalizes the first resulting character when upcasing a character produces a multi-character sequence" # NoMethodError: undefined method `capitalize!' for "ß"
  fails "String#capitalize! full Unicode case mapping updates string metadata" # NoMethodError: undefined method `capitalize!' for "ßeT"
  fails "String#capitalize! modifies self in place for ASCII-only case mapping does not capitalize non-ASCII characters" # NoMethodError: undefined method `capitalize!' for "ßet"
  fails "String#capitalize! modifies self in place for ASCII-only case mapping works for non-ascii-compatible encodings" # NoMethodError: undefined method `capitalize!' for "aBc"
  fails "String#capitalize! modifies self in place for full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # NoMethodError: undefined method `capitalize!' for "iß"
  fails "String#capitalize! modifies self in place for full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # NoMethodError: undefined method `capitalize!' for "iß"
  fails "String#capitalize! modifies self in place for full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # NoMethodError: undefined method `capitalize!' for "iSa"
  fails "String#capitalize! modifies self in place for full Unicode case mapping adapted for Turkic languages capitalizes ASCII characters according to Turkic semantics" # NoMethodError: undefined method `capitalize!' for "iSa"
  fails "String#chop returns a new string when applied to an empty string" # Expected "" not to be identical to ""
  fails "String#clear preserves its encoding" # NameError: uninitialized constant Encoding::SHIFT_JIS
  fails "String#clear returns self after emptying it" # NoMethodError: undefined method `clear' for "Jolene"
  fails "String#clear sets self equal to the empty String" # NoMethodError: undefined method `clear' for "Jolene"
  fails "String#clear works with multibyte Strings" # NoMethodError: undefined method `clear' for "靥ࡶ"
  fails "String#clone copies instance variables" # NoMethodError: undefined method `ivar' for "string"
  fails "String#clone does not modify the original string when changing cloned string" # NoMethodError: undefined method `[]=' for "string"
  fails "String#concat raises a TypeError if the given argument can't be converted to a String" # Expected TypeError but got: NoMethodError (undefined method `concat' for "hello ")
  fails "String#concat when self and the argument are in different ASCII-compatible encodings raises Encoding::CompatibilityError if neither are ASCII-only" # Expected CompatibilityError but got: NoMethodError (undefined method `concat' for "é")
  fails "String#concat when self and the argument are in different ASCII-compatible encodings uses self's encoding if both are ASCII-only" # ArgumentError: unknown encoding name - SHIFT_JIS
  fails "String#concat when self and the argument are in different ASCII-compatible encodings uses the argument's encoding if self is ASCII-only" # NoMethodError: undefined method `concat' for "abc"
  fails "String#concat when self is in an ASCII-incompatible encoding incompatible with the argument's encoding raises Encoding::CompatibilityError if neither are empty" # Expected CompatibilityError but got: NoMethodError (undefined method `concat' for "x")
  fails "String#concat when self is in an ASCII-incompatible encoding incompatible with the argument's encoding uses the argument's encoding if self is empty" # NoMethodError: undefined method `concat' for ""
  fails "String#concat when the argument is in an ASCII-incompatible encoding incompatible with self's encoding raises Encoding::CompatibilityError if neither are empty" # Expected CompatibilityError but got: NoMethodError (undefined method `concat' for "x")
  fails "String#concat when the argument is in an ASCII-incompatible encoding incompatible with self's encoding uses the argument's encoding if self is empty" # NoMethodError: undefined method `concat' for ""
  fails "String#concat with Integer concatenates the argument interpreted as a codepoint" # NoMethodError: undefined method `concat' for ""
  fails "String#concat with Integer doesn't call to_int on its argument" # Expected TypeError but got: NoMethodError (undefined method `concat' for "")
  fails "String#concat with Integer raises RangeError if the argument is an invalid codepoint for self's encoding" # Expected RangeError but got: NoMethodError (undefined method `concat' for "")
  fails "String#concat with Integer raises RangeError if the argument is negative" # Expected RangeError but got: NoMethodError (undefined method `concat' for "")
  fails "String#delete! modifies self in place and returns self" # NoMethodError: undefined method `delete!' for "hello"
  fails "String#delete! returns nil if no modifications were made" # NoMethodError: undefined method `delete!' for "hello"
  fails "String#delete_prefix calls to_str on its argument" # Expected "hello" == "o" to be truthy but was false
  fails "String#delete_prefix returns a copy of the string, when the prefix isn't found" # Expected "hello" not to be identical to "hello"
  fails "String#delete_prefix returns a copy of the string, with the given prefix removed" # Expected "hello" == "o" to be truthy but was false
  fails "String#delete_prefix! calls to_str on its argument" # Mock 'x' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "String#delete_prefix! doesn't set $~" # NoMethodError: undefined method `delete_prefix!' for "hello"
  fails "String#delete_prefix! removes the found prefix" # NoMethodError: undefined method `delete_prefix!' for "hello"
  fails "String#delete_prefix! returns nil if no change is made" # NoMethodError: undefined method `delete_prefix!' for "hello"
  fails "String#delete_suffix calls to_str on its argument" # Expected "hello" == "h" to be truthy but was false
  fails "String#delete_suffix returns a copy of the string, when the suffix isn't found" # Expected "hello" not to be identical to "hello"
  fails "String#delete_suffix returns a copy of the string, with the given suffix removed" # Expected "hello" == "h" to be truthy but was false
  fails "String#delete_suffix! calls to_str on its argument" # Mock 'x' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "String#delete_suffix! doesn't set $~" # NoMethodError: undefined method `delete_suffix!' for "hello"
  fails "String#delete_suffix! removes the found prefix" # NoMethodError: undefined method `delete_suffix!' for "hello"
  fails "String#delete_suffix! returns nil if no change is made" # NoMethodError: undefined method `delete_suffix!' for "hello"
  fails "String#downcase! ASCII-only case mapping does not downcase non-ASCII characters" # NoMethodError: undefined method `downcase!' for "CÅR"
  fails "String#downcase! ASCII-only case mapping works for non-ascii-compatible encodings" # NoMethodError: undefined method `downcase!' for "ABC"
  fails "String#downcase! case folding case folds special characters" # NoMethodError: undefined method `downcase!' for "ß"
  fails "String#downcase! does not allow invalid options" # Expected ArgumentError but got: NoMethodError (undefined method `downcase!' for "ABC")
  fails "String#downcase! full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # NoMethodError: undefined method `downcase!' for "İS"
  fails "String#downcase! full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # NoMethodError: undefined method `downcase!' for "İS"
  fails "String#downcase! full Unicode case mapping adapted for Lithuanian does not allow any other additional option" # Expected ArgumentError but got: NoMethodError (undefined method `downcase!' for "İS")
  fails "String#downcase! full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # NoMethodError: undefined method `downcase!' for "İ"
  fails "String#downcase! full Unicode case mapping adapted for Turkic languages does not allow any other additional option" # Expected ArgumentError but got: NoMethodError (undefined method `downcase!' for "İ")
  fails "String#downcase! full Unicode case mapping adapted for Turkic languages downcases characters according to Turkic semantics" # NoMethodError: undefined method `downcase!' for "İ"
  fails "String#downcase! full Unicode case mapping modifies self in place for all of Unicode with no option" # NoMethodError: undefined method `downcase!' for "ÄÖÜ"
  fails "String#downcase! full Unicode case mapping updates string metadata" # NoMethodError: undefined method `downcase!' for "KING"
  fails "String#downcase! modifies self in place for non-ascii-compatible encodings" # NoMethodError: undefined method `downcase!' for "HeLlO"
  fails "String#downcase! modifies self in place" # NoMethodError: undefined method `downcase!' for "HeLlO"
  fails "String#downcase! returns nil if no modifications were made" # NoMethodError: undefined method `downcase!' for "hello"
  fails "String#dup copies instance variables" # NoMethodError: undefined method `ivar' for "string"
  fails "String#dup does not copy singleton methods" # TypeError: can't define singleton
  fails "String#dup does not modify the original string when changing dupped string" # NoMethodError: undefined method `[]=' for "string"
  fails "String#each_line does not care if the string is modified while substituting" # NoMethodError: undefined method `[]=' for "hello\nworld."
  fails "String#each_line raises a TypeError when the separator is a symbol" # Expected TypeError but no exception was raised (["hello", " wo", "rld"] was returned)
  fails "String#encode! given the xml: :attr option replaces all instances of '&' with '&amp;'" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! given the xml: :attr option replaces all instances of '<' with '&lt;'" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! given the xml: :attr option replaces all instances of '>' with '&gt;'" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! given the xml: :attr option replaces all instances of '\"' with '&quot;'" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! given the xml: :attr option replaces undefined characters with their upper-case hexadecimal numeric character references" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! given the xml: :attr option surrounds the encoded text with double-quotes" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! given the xml: :text option does not replace '\"'" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! given the xml: :text option replaces all instances of '&' with '&amp;'" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! given the xml: :text option replaces all instances of '<' with '&lt;'" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! given the xml: :text option replaces all instances of '>' with '&gt;'" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! given the xml: :text option replaces undefined characters with their upper-case hexadecimal numeric character references" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! raises ArgumentError if the value of the :xml option is not :text or :attr" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed no options raises an Encoding::ConverterNotFoundError when no conversion is possible" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed no options returns self for a ASCII-only String when Encoding.default_internal is nil" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed no options returns self when Encoding.default_internal is nil" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed no options transcodes a 7-bit String despite no generic converting being available" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed no options transcodes to Encoding.default_internal when set" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed options calls #to_hash to convert the object" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed options does not process transcoding options if not transcoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed options raises an Encoding::ConverterNotFoundError when no conversion is possible despite 'invalid: :replace, undef: :replace'" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed options replaces invalid characters when replacing Emacs-Mule encoded strings" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed options returns self for ASCII-only String when Encoding.default_internal is nil" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed options transcodes to Encoding.default_internal when set" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to encoding accepts a String argument" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to encoding calls #to_str to convert the object to an Encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to encoding raises an Encoding::ConverterNotFoundError for an invalid encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to encoding raises an Encoding::ConverterNotFoundError when no conversion is possible" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to encoding returns self" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to encoding transcodes Japanese multibyte characters" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to encoding transcodes a 7-bit String despite no generic converting being available" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to encoding transcodes to the passed encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, from calls #to_str to convert the from object to an Encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, from returns self" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, from transcodes between the encodings ignoring the String encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, from, options calls #to_hash to convert the options object" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, from, options calls #to_str to convert the from object to an encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, from, options calls #to_str to convert the to object to an encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, from, options replaces invalid characters in the destination encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, from, options replaces undefined characters in the destination encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, options calls #to_hash to convert the options object" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, options replaces invalid characters in the destination encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, options replaces undefined characters in the destination encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#gsub with pattern and Hash ignores non-String keys" # Expected "tazoo" == "taboo" to be truthy but was false
  fails "String#gsub! with pattern and Hash ignores non-String keys" # NoMethodError: undefined method `gsub!' for "hello"
  fails "String#gsub! with pattern and block raises an Encoding::CompatibilityError if the encodings are not compatible" # Expected CompatibilityError but got: NoMethodError (undefined method `gsub!' for "hllëllo")
  fails "String#gsub! with pattern and block replaces the incompatible part properly even if the encodings are not compatible" # NoMethodError: undefined method `gsub!' for "hllëllo"
  fails "String#gsub! with pattern and block uses the compatible encoding if they are compatible" # NoMethodError: undefined method `gsub!' for "hello"
  fails "String#gsub! with pattern and without replacement and block returned Enumerator size should return nil" # NoMethodError: undefined method `gsub!' for "abca"
  fails "String#gsub! with pattern and without replacement and block returns an enumerator" # NoMethodError: undefined method `gsub!' for "abca"
  fails "String#insert with index, other converts index to an integer using to_int" # Mock '-3' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "String#insert with index, other converts other to a string using to_str" # Mock 'XYZ' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "String#insert with index, other inserts after the given character on an negative count" # NoMethodError: undefined method `insert' for "abcd"
  fails "String#insert with index, other inserts other before the character at the given index" # NoMethodError: undefined method `insert' for "abcd"
  fails "String#insert with index, other modifies self in place" # NoMethodError: undefined method `insert' for "abcd"
  fails "String#insert with index, other raises a TypeError if other can't be converted to string" # Expected TypeError but got: NoMethodError (undefined method `insert' for "abcd")
  fails "String#insert with index, other raises an IndexError if the index is beyond string" # Expected IndexError but got: NoMethodError (undefined method `insert' for "abcd")
  fails "String#prepend raises a TypeError if the given argument can't be converted to a String" # Expected TypeError but got: NoMethodError (undefined method `prepend' for "hello ")
  fails "String#replace carries over the encoding invalidity" # NoMethodError: undefined method `replace' for ""
  fails "String#replace raises a TypeError if other can't be converted to string" # Expected TypeError but got: NoMethodError (undefined method `replace' for "hello")
  fails "String#replace replaces the content of self with other" # NoMethodError: undefined method `replace' for "some string"
  fails "String#replace replaces the encoding of self with that of other" # NoMethodError: undefined method `replace' for ""
  fails "String#replace tries to convert other to string using to_str" # Mock 'x' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "String#rstrip! modifies self in place and returns self" # NoMethodError: undefined method `rstrip!' for "  hello  "
  fails "String#rstrip! modifies self removing trailing NULL bytes and whitespace" # NoMethodError: undefined method `rstrip!' for "\u0000 \u0000hello\u0000 \u0000"
  fails "String#rstrip! returns nil if no modifications were made" # NoMethodError: undefined method `rstrip!' for "hello"
  fails "String#setbyte allows changing bytes in multi-byte characters" # NoMethodError: undefined method `setbyte' for "क"
  fails "String#setbyte calls #to_int to convert the index" # Mock 'setbyte index' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "String#setbyte calls to_int to convert the value" # Mock 'setbyte value' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "String#setbyte can invalidate a String's encoding" # NoMethodError: undefined method `setbyte' for "glark"
  fails "String#setbyte changes the byte at the given index to the new byte" # NoMethodError: undefined method `setbyte' for "a"
  fails "String#setbyte does not modify the original string when using String.new" # NoMethodError: undefined method `setbyte' for "hedgehog"
  fails "String#setbyte modifies the receiver" # NoMethodError: undefined method `setbyte' for "glark"
  fails "String#setbyte raises a TypeError unless the second argument is an Integer" # Expected TypeError but got: NoMethodError (undefined method `setbyte' for "a")
  fails "String#setbyte raises an IndexError if the index is greater than the String bytesize" # Expected IndexError but got: NoMethodError (undefined method `setbyte' for "?")
  fails "String#setbyte raises an IndexError if the negative index is greater magnitude than the String bytesize" # Expected IndexError but got: NoMethodError (undefined method `setbyte' for "???")
  fails "String#setbyte regards a negative index as counting from the end of the String" # NoMethodError: undefined method `setbyte' for "hedgehog"
  fails "String#setbyte returns an Integer" # NoMethodError: undefined method `setbyte' for "a"
  fails "String#setbyte sets a byte at an index greater than String size" # NoMethodError: undefined method `setbyte' for "ঘ"
  fails "String#slice! Range calls to_int on range arguments" # NoMethodError: undefined method `slice!' for "hello there"
  fails "String#slice! Range deletes and return the substring given by the offsets of the range" # NoMethodError: undefined method `slice!' for "hello"
  fails "String#slice! Range returns String instances" # NoMethodError: undefined method `slice!' for "hello"
  fails "String#slice! Range returns nil if the given range is out of self" # NoMethodError: undefined method `slice!' for "hello"
  fails "String#slice! Range returns the substring given by the character offsets of the range" # NoMethodError: undefined method `slice!' for "hellö there"
  fails "String#slice! Range works with Range subclasses" # NoMethodError: undefined method `slice!' for "GOOD"
  fails "String#slice! with Regexp deletes and returns the first match from self" # NoMethodError: undefined method `slice!' for "this is a string"
  fails "String#slice! with Regexp returns String instances" # NoMethodError: undefined method `slice!' for "hello"
  fails "String#slice! with Regexp returns nil if there was no match" # NoMethodError: undefined method `slice!' for "this is a string"
  fails "String#slice! with Regexp returns the matching portion of self with a multi byte character" # NoMethodError: undefined method `slice!' for "hëllo there"
  fails "String#slice! with Regexp sets $~ to MatchData when there is a match and nil when there's none" # NoMethodError: undefined method `slice!' for "hello"
  fails "String#slice! with Regexp, index accepts a Float for capture index" # NoMethodError: undefined method `slice!' for "har"
  fails "String#slice! with Regexp, index calls #to_int to convert an Object to capture index" # Mock '2' expected to receive to_int("any_args") at least 1 times but received it 0 times
  fails "String#slice! with Regexp, index deletes and returns the capture for idx from self" # NoMethodError: undefined method `slice!' for "hello there"
  fails "String#slice! with Regexp, index returns String instances" # NoMethodError: undefined method `slice!' for "hello"
  fails "String#slice! with Regexp, index returns nil if there is no capture for idx" # NoMethodError: undefined method `slice!' for "hello there"
  fails "String#slice! with Regexp, index returns nil if there was no match" # NoMethodError: undefined method `slice!' for "this is a string"
  fails "String#slice! with Regexp, index returns the encoding aware capture for the given index" # NoMethodError: undefined method `slice!' for "hår"
  fails "String#slice! with String doesn't call to_str on its argument" # Expected TypeError but got: NoMethodError (undefined method `slice!' for "hello")
  fails "String#slice! with String doesn't set $~" # NoMethodError: undefined method `slice!' for "hello"
  fails "String#slice! with String removes and returns the first occurrence of other_str from self" # NoMethodError: undefined method `slice!' for "hello hello"
  fails "String#slice! with String returns a subclass instance when given a subclass instance" # NoMethodError: undefined method `slice!' for "hello"
  fails "String#slice! with String returns nil if self does not contain other" # NoMethodError: undefined method `slice!' for "hello"
  fails "String#slice! with index calls to_int on index" # NoMethodError: undefined method `slice!' for "hello"
  fails "String#slice! with index deletes and return the char at the given position" # NoMethodError: undefined method `slice!' for "hello"
  fails "String#slice! with index returns nil if idx is outside of self" # NoMethodError: undefined method `slice!' for "hello"
  fails "String#slice! with index returns the character given by the character index" # NoMethodError: undefined method `slice!' for "hellö there"
  fails "String#slice! with index, length calls to_int on idx and length" # NoMethodError: undefined method `slice!' for "hello"
  fails "String#slice! with index, length deletes and returns the substring at idx and the given length" # NoMethodError: undefined method `slice!' for "hello"
  fails "String#slice! with index, length returns String instances" # NoMethodError: undefined method `slice!' for "hello"
  fails "String#slice! with index, length returns the substring given by the character offsets" # NoMethodError: undefined method `slice!' for "hellö there"
  fails "String#slice! with index, length treats invalid bytes as single bytes" # NoMethodError: undefined method `slice!' for "aæËb"
  fails "String#sub! with pattern and Hash coerces the hash values with #to_s" # Mock '!' expected to receive to_s("any_args") exactly 1 times but received it 0 times
  fails "String#sub! with pattern and Hash doesn't interpolate special sequences like \\1 for the block's return value" # NoMethodError: undefined method `sub!' for "hello"
  fails "String#sub! with pattern and Hash ignores non-String keys" # NoMethodError: undefined method `sub!' for "hello"
  fails "String#sub! with pattern and Hash removes keys that don't correspond to matches" # NoMethodError: undefined method `sub!' for "hello"
  fails "String#sub! with pattern and Hash returns self with the first occurrence of pattern replaced with the value of the corresponding hash key" # NoMethodError: undefined method `sub!' for "hello"
  fails "String#sub! with pattern and Hash sets $~ to MatchData of first match and nil when there's none for access from outside" # NoMethodError: undefined method `sub!' for "hello."
  fails "String#sub! with pattern and Hash uses a key's value only a single time" # NoMethodError: undefined method `sub!' for "food"
  fails "String#sub! with pattern and Hash uses the hash's default value for missing keys" # NoMethodError: undefined method `sub!' for "food"
  fails "String#sub! with pattern and Hash uses the hash's value set from default_proc for missing keys" # NoMethodError: undefined method `sub!' for "food!"
  fails "String#sub! with pattern and block modifies self in place and returns self" # NoMethodError: undefined method `sub!' for "hello"
  fails "String#sub! with pattern and block raises a RuntimeError if the string is modified while substituting" # Expected RuntimeError but got: NoMethodError (undefined method `sub!' for "hello")
  fails "String#sub! with pattern and block returns nil if no modifications were made" # NoMethodError: undefined method `sub!' for "hello"
  fails "String#sub! with pattern and block sets $~ for access from the block" # NoMethodError: undefined method `sub!' for "hello"
  fails "String#sub! with pattern and without replacement and block raises a ArgumentError" # Expected ArgumentError but got: NoMethodError (undefined method `sub!' for "abca")
  fails "String#sub! with pattern, replacement modifies self in place and returns self" # NoMethodError: undefined method `sub!' for "hello"
  fails "String#sub! with pattern, replacement returns nil if no modifications were made" # NoMethodError: undefined method `sub!' for "hello"
  fails "String#swapcase! full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # NoMethodError: undefined method `swapcase!' for "iS"
  fails "String#swapcase! full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # NoMethodError: undefined method `swapcase!' for "Iß"
  fails "String#swapcase! full Unicode case mapping modifies self in place for all of Unicode with no option" # NoMethodError: undefined method `swapcase!' for "äÖü"
  fails "String#swapcase! full Unicode case mapping updates string metadata" # NoMethodError: undefined method `swapcase!' for "Aßet"
  fails "String#swapcase! full Unicode case mapping works for non-ascii-compatible encodings" # NoMethodError: undefined method `swapcase!' for "äÖü"
  fails "String#swapcase! modifies self in place for ASCII-only case mapping does not swapcase non-ASCII characters" # NoMethodError: undefined method `swapcase!' for "aßet"
  fails "String#swapcase! modifies self in place for ASCII-only case mapping works for non-ascii-compatible encodings" # NoMethodError: undefined method `swapcase!' for "aBc"
  fails "String#swapcase! modifies self in place for full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # NoMethodError: undefined method `swapcase!' for "aiS"
  fails "String#swapcase! modifies self in place for full Unicode case mapping adapted for Turkic languages swaps case of ASCII characters according to Turkic semantics" # NoMethodError: undefined method `swapcase!' for "aiS"
  fails "String#unicode_normalize! raises an Encoding::CompatibilityError if the string is not in an unicode encoding" # Expected CompatibilityError but got: NoMethodError (undefined method `unicode_normalize!' for "à")
  fails "String#upcase! does not allow invalid options" # Expected ArgumentError but got: NoMethodError (undefined method `upcase!' for "abc")
  fails "String#upcase! does not allow the :fold option for upcasing" # Expected ArgumentError but got: NoMethodError (undefined method `upcase!' for "abc")
  fails "String#upcase! full Unicode case mapping updates string metadata for self" # NoMethodError: undefined method `upcase!' for "aßet"
  fails "String#upcase! modifies self in place for ASCII-only case mapping does not upcase non-ASCII characters" # NoMethodError: undefined method `upcase!' for "aßet"
  fails "String#upcase! modifies self in place for full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # NoMethodError: undefined method `upcase!' for "iß"
  fails "String#upcase! modifies self in place for full Unicode case mapping adapted for Lithuanian does not allow any other additional option" # Expected ArgumentError but got: NoMethodError (undefined method `upcase!' for "iß")
  fails "String#upcase! modifies self in place for full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # NoMethodError: undefined method `upcase!' for "i"
  fails "String#upcase! modifies self in place for full Unicode case mapping adapted for Turkic languages does not allow any other additional option" # Expected ArgumentError but got: NoMethodError (undefined method `upcase!' for "i")
  fails "String#upcase! modifies self in place for full Unicode case mapping adapted for Turkic languages upcases ASCII characters according to Turkic semantics" # NoMethodError: undefined method `upcase!' for "i"
  fails "String#upto on sequence of numbers calls the block as Integer#upto" # Expected [] == ["8", "9", "10", "11"] to be truthy but was false
  fails "String#upto when no block is given returns an enumerator" # Expected 677 == 676 to be truthy but was false
end
