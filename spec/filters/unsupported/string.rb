# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "String" do
  fails "BasicObject#__id__ returns a different value for two String literals"
  fails "Module#const_defined? returns true when passed a constant name with EUC-JP characters"
  fails "String#% supports negative bignums with %u or %d"
  fails "String#-@ deduplicates frozen strings" # May fail randomly outside of "use strict"
  fails "String#-@ returns a frozen copy if the String is not frozen" # May fail randomly outside of "use strict"
  fails "String#<< concatenates the given argument to self and returns self"
  fails "String#<< converts the given argument to a String using to_str"
  fails "String#<< raises a RuntimeError when self is frozen"
  fails "String#<< raises a TypeError if the given argument can't be converted to a String"
  fails "String#<< returns a String when given a subclass instance"
  fails "String#<< returns an instance of same class when called on a subclass"
  fails "String#<< when self and the argument are in different ASCII-compatible encodings raises Encoding::CompatibilityError if neither are ASCII-only"
  fails "String#<< when self and the argument are in different ASCII-compatible encodings uses self's encoding if both are ASCII-only"
  fails "String#<< when self and the argument are in different ASCII-compatible encodings uses self's encoding if the argument is ASCII-only"
  fails "String#<< when self and the argument are in different ASCII-compatible encodings uses the argument's encoding if self is ASCII-only"
  fails "String#<< when self is ASCII-8BIT and argument is US-ASCII uses ASCII-8BIT encoding"
  fails "String#<< when self is in an ASCII-incompatible encoding incompatible with the argument's encoding raises Encoding::CompatibilityError if neither are empty"
  fails "String#<< when self is in an ASCII-incompatible encoding incompatible with the argument's encoding uses self's encoding if both are empty"
  fails "String#<< when self is in an ASCII-incompatible encoding incompatible with the argument's encoding uses self's encoding if the argument is empty"
  fails "String#<< when self is in an ASCII-incompatible encoding incompatible with the argument's encoding uses the argument's encoding if self is empty"
  fails "String#<< when the argument is in an ASCII-incompatible encoding incompatible with self's encoding raises Encoding::CompatibilityError if neither are empty"
  fails "String#<< when the argument is in an ASCII-incompatible encoding incompatible with self's encoding uses self's encoding if both are empty"
  fails "String#<< when the argument is in an ASCII-incompatible encoding incompatible with self's encoding uses self's encoding if the argument is empty"
  fails "String#<< when the argument is in an ASCII-incompatible encoding incompatible with self's encoding uses the argument's encoding if self is empty"
  fails "String#<< with Integer concatenates the argument interpreted as a codepoint" # NotImplementedError: String#<< not supported. Mutable String methods are not supported in Opal.
  fails "String#<< with Integer doesn't call to_int on its argument"
  fails "String#<< with Integer raises RangeError if the argument is an invalid codepoint for self's encoding"
  fails "String#<< with Integer raises RangeError if the argument is negative"
  fails "String#<< with Integer raises a RuntimeError when self is frozen"
  fails "String#<< with Integer returns a ASCII-8BIT string if self is US-ASCII and the argument is between 128-255 (inclusive)"
  fails "String#[] with Symbol raises TypeError"
  fails "String#[]= with Fixnum index allows assignment to the zero'th element of an empty String"
  fails "String#[]= with Fixnum index calls #to_str to convert other to a String"
  fails "String#[]= with Fixnum index calls to_int on index"
  fails "String#[]= with Fixnum index raises IndexError if the string index doesn't match a position in the string"
  fails "String#[]= with Fixnum index raises a RuntimeError when self is frozen"
  fails "String#[]= with Fixnum index raises a TypeError if other_str can't be converted to a String"
  fails "String#[]= with Fixnum index raises an IndexError without changing self if idx is outside of self"
  fails "String#[]= with Fixnum index replaces the char at idx with other_str"
  fails "String#[]= with Fixnum index, count appends other_str to the end of the string if idx == the length of the string"
  fails "String#[]= with Fixnum index, count calls #to_int to convert the index and count objects"
  fails "String#[]= with Fixnum index, count calls #to_str to convert the replacement object"
  fails "String#[]= with Fixnum index, count counts negative idx values from end of the string"
  fails "String#[]= with Fixnum index, count deletes characters if other_str is an empty string"
  fails "String#[]= with Fixnum index, count deletes characters up to the maximum length of the existing string"
  fails "String#[]= with Fixnum index, count overwrites and deletes characters if count is more than the length of other_str"
  fails "String#[]= with Fixnum index, count raises a TypeError if #to_int for count does not return an Integer"
  fails "String#[]= with Fixnum index, count raises a TypeError if #to_int for index does not return an Integer"
  fails "String#[]= with Fixnum index, count raises a TypeError if other_str is a type other than String"
  fails "String#[]= with Fixnum index, count raises a TypeError of #to_str does not return a String"
  fails "String#[]= with Fixnum index, count raises an IndexError if count < 0"
  fails "String#[]= with Fixnum index, count raises an IndexError if |idx| is greater than the length of the string"
  fails "String#[]= with Fixnum index, count starts at idx and overwrites count characters before inserting the rest of other_str"
  fails "String#[]= with Integer index allows assignment to the zero'th element of an empty String" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index calls #to_int to convert the index" # Mock 'string element set' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "String#[]= with Integer index calls #to_str to convert other to a String" # Mock '-test-' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "String#[]= with Integer index calls to_int on index" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index encodes the String in an encoding compatible with the replacement" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index raises IndexError if the string index doesn't match a position in the string" # Expected IndexError but got: NotImplementedError (String#[]= not supported. Mutable String methods are not supported in Opal.)
  fails "String#[]= with Integer index raises a FrozenError when self is frozen" # Expected FrozenError but got: NotImplementedError (String#[]= not supported. Mutable String methods are not supported in Opal.)
  fails "String#[]= with Integer index raises a TypeError if #to_int does not return an Integer" # Expected TypeError but got: NotImplementedError (String#[]= not supported. Mutable String methods are not supported in Opal.)
  fails "String#[]= with Integer index raises a TypeError if other_str can't be converted to a String" # Expected TypeError but got: NotImplementedError (String#[]= not supported. Mutable String methods are not supported in Opal.)
  fails "String#[]= with Integer index raises a TypeError if passed an Integer replacement" # Expected TypeError but got: NotImplementedError (String#[]= not supported. Mutable String methods are not supported in Opal.)
  fails "String#[]= with Integer index raises an Encoding::CompatibilityError if the replacement encoding is incompatible" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#[]= with Integer index raises an IndexError if #to_int returns a value out of range" # Expected IndexError but got: NotImplementedError (String#[]= not supported. Mutable String methods are not supported in Opal.)
  fails "String#[]= with Integer index raises an IndexError if the index is greater than character size" # Expected IndexError but got: NotImplementedError (String#[]= not supported. Mutable String methods are not supported in Opal.)
  fails "String#[]= with Integer index raises an IndexError without changing self if idx is outside of self" # Expected IndexError but got: NotImplementedError (String#[]= not supported. Mutable String methods are not supported in Opal.)
  fails "String#[]= with Integer index replaces a character with a multibyte character" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index replaces a multibyte character with a character" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index replaces a multibyte character with a multibyte character" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index replaces the char at idx with other_str" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index, count appends other_str to the end of the string if idx == the length of the string" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index, count calls #to_int to convert the index and count objects" # Mock 'string element set index' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "String#[]= with Integer index, count calls #to_str to convert the replacement object" # Mock 'string element set replacement' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "String#[]= with Integer index, count counts negative idx values from end of the string" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index, count deletes a multibyte character" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index, count deletes characters if other_str is an empty string" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index, count deletes characters up to the maximum length of the existing string" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index, count encodes the String in an encoding compatible with the replacement" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index, count inserts a multibyte character" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index, count overwrites and deletes characters if count is more than the length of other_str" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index, count raises a TypeError if #to_int for count does not return an Integer" # Expected TypeError but got: NotImplementedError (String#[]= not supported. Mutable String methods are not supported in Opal.)
  fails "String#[]= with Integer index, count raises a TypeError if #to_int for index does not return an Integer" # Expected TypeError but got: NotImplementedError (String#[]= not supported. Mutable String methods are not supported in Opal.)
  fails "String#[]= with Integer index, count raises a TypeError if other_str is a type other than String" # Expected TypeError but got: NotImplementedError (String#[]= not supported. Mutable String methods are not supported in Opal.)
  fails "String#[]= with Integer index, count raises a TypeError of #to_str does not return a String" # Expected TypeError but got: NotImplementedError (String#[]= not supported. Mutable String methods are not supported in Opal.)
  fails "String#[]= with Integer index, count raises an Encoding::CompatibilityError if the replacement encoding is incompatible" # NameError: uninitialized constant Encoding::EUC_JP
  fails "String#[]= with Integer index, count raises an IndexError if count < 0" # Expected IndexError but got: NotImplementedError (String#[]= not supported. Mutable String methods are not supported in Opal.)
  fails "String#[]= with Integer index, count raises an IndexError if the character index is out of range of a multibyte String" # Expected IndexError but got: NotImplementedError (String#[]= not supported. Mutable String methods are not supported in Opal.)
  fails "String#[]= with Integer index, count raises an IndexError if |idx| is greater than the length of the string" # Expected IndexError but got: NotImplementedError (String#[]= not supported. Mutable String methods are not supported in Opal.)
  fails "String#[]= with Integer index, count replaces characters with a multibyte character" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index, count replaces multibyte characters with characters" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index, count replaces multibyte characters with multibyte characters" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Integer index, count starts at idx and overwrites count characters before inserting the rest of other_str" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with String index raises an IndexError if the search String is not found"
  fails "String#[]= with String index replaces characters with no characters"
  fails "String#[]= with String index replaces fewer characters with more characters"
  fails "String#[]= with String index replaces more characters with fewer characters"
  fails "String#[]= with a Range index raises a RangeError if negative Range begin is out of range"
  fails "String#[]= with a Range index raises a RangeError if positive Range begin is greater than String size"
  fails "String#[]= with a Range index replaces a partial string"
  fails "String#[]= with a Range index replaces the contents with a longer String"
  fails "String#[]= with a Range index replaces the contents with a shorter String"
  fails "String#[]= with a Range index treats a negative out-of-range Range end with a negative Range begin as a zero count"
  fails "String#[]= with a Range index treats a negative out-of-range Range end with a positive Range begin as a zero count"
  fails "String#[]= with a Range index uses the Range end as an index rather than a count"
  fails "String#[]= with a Range index with an empty replacement does not replace a character with a zero exclude-end range"
  fails "String#[]= with a Range index with an empty replacement does not replace a character with a zero-index, zero exclude-end range"
  fails "String#[]= with a Range index with an empty replacement replaces a character with a zero non-exclude-end range"
  fails "String#[]= with a Range index with an empty replacement replaces a character with zero-index, zero non-exclude-end range"
  fails "String#[]= with a Regexp index calls #to_str to convert the replacement"
  fails "String#[]= with a Regexp index checks the match before calling #to_str to convert the replacement"
  fails "String#[]= with a Regexp index raises IndexError if the regexp index doesn't match a position in the string"
  fails "String#[]= with a Regexp index replaces the matched text with the rhs"
  fails "String#[]= with a Regexp index with 3 arguments allows the specified capture to be negative and count from the end"
  fails "String#[]= with a Regexp index with 3 arguments calls #to_int to convert the second object"
  fails "String#[]= with a Regexp index with 3 arguments checks the match index before calling #to_str to convert the replacement"
  fails "String#[]= with a Regexp index with 3 arguments raises IndexError if the specified capture isn't available"
  fails "String#[]= with a Regexp index with 3 arguments raises a TypeError if #to_int does not return a Fixnum"
  fails "String#[]= with a Regexp index with 3 arguments raises a TypeError if #to_int does not return an Integer" # Expected TypeError but got: NotImplementedError (String#[]= not supported. Mutable String methods are not supported in Opal.)
  fails "String#[]= with a Regexp index with 3 arguments uses the 2nd of 3 arguments as which capture should be replaced"
  fails "String#[]= with a Regexp index with 3 arguments when the optional capture does not match raises an IndexError before setting the replacement"
  fails "String#capitalize! capitalizes self in place for all of Unicode" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#capitalize! capitalizes self in place"
  fails "String#capitalize! does not allow invalid options" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#capitalize! does not allow the :fold option for upcasing" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#capitalize! full Unicode case mapping modifies self in place for all of Unicode with no option" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#capitalize! full Unicode case mapping only capitalizes the first resulting character when upcasing a character produces a multi-character sequence" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#capitalize! full Unicode case mapping updates string metadata" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#capitalize! full Unicode case mapping works for non-ascii-compatible encodings" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#capitalize! modifies self in place for ASCII-only case mapping does not capitalize non-ASCII characters" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#capitalize! modifies self in place for ASCII-only case mapping works for non-ascii-compatible encodings" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#capitalize! modifies self in place for full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#capitalize! modifies self in place for full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#capitalize! modifies self in place for full Unicode case mapping adapted for Lithuanian does not allow any other additional option" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#capitalize! modifies self in place for full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#capitalize! modifies self in place for full Unicode case mapping adapted for Turkic languages capitalizes ASCII characters according to Turkic semantics" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#capitalize! modifies self in place for full Unicode case mapping adapted for Turkic languages does not allow any other additional option" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#capitalize! modifies self in place for non-ascii-compatible encodings" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#capitalize! raises a RuntimeError when self is frozen"
  fails "String#capitalize! returns nil when no changes are made"
  fails "String#chomp! raises a RuntimeError on a frozen instance when it is modified"
  fails "String#chomp! raises a RuntimeError on a frozen instance when it would not be modified"
  fails "String#chomp! removes the final carriage return, newline from a multibyte String" # NotImplementedError: String#chomp! not supported. Mutable String methods are not supported in Opal.
  fails "String#chomp! removes the final carriage return, newline from a non-ASCII String when the record separator is changed" # ArgumentError: unknown encoding name - utf-32be
  fails "String#chomp! removes the final carriage return, newline from a non-ASCII String" # ArgumentError: unknown encoding name - utf-32be
  fails "String#chomp! returns nil when the String is not modified" # NotImplementedError: String#chomp! not supported. Mutable String methods are not supported in Opal.
  fails "String#chomp! when passed '' does not remove a final carriage return"
  fails "String#chomp! when passed '' removes a final carriage return, newline"
  fails "String#chomp! when passed '' removes a final newline"
  fails "String#chomp! when passed '' removes more than one trailing carriage return, newline pairs"
  fails "String#chomp! when passed '' removes more than one trailing newlines"
  fails "String#chomp! when passed '' returns nil when self is empty"
  fails "String#chomp! when passed '\\n' removes one trailing carriage return"
  fails "String#chomp! when passed '\\n' removes one trailing carriage return, newline pair" # NotImplementedError: String#chomp! not supported. Mutable String methods are not supported in Opal.
  fails "String#chomp! when passed '\\n' removes one trailing newline"
  fails "String#chomp! when passed '\\n' returns nil when self is empty"
  fails "String#chomp! when passed a String removes the trailing characters if they match the argument"
  fails "String#chomp! when passed a String returns nil if the argument does not match the trailing characters"
  fails "String#chomp! when passed a String returns nil when self is empty"
  fails "String#chomp! when passed an Object calls #to_str to convert to a String"
  fails "String#chomp! when passed an Object raises a TypeError if #to_str does not return a String"
  fails "String#chomp! when passed nil returns nil when self is empty"
  fails "String#chomp! when passed nil returns nil"
  fails "String#chomp! when passed no argument modifies self"
  fails "String#chomp! when passed no argument removes one trailing carriage return"
  fails "String#chomp! when passed no argument removes one trailing carriage return, newline pair" # NotImplementedError: String#chomp! not supported. Mutable String methods are not supported in Opal.
  fails "String#chomp! when passed no argument removes one trailing newline"
  fails "String#chomp! when passed no argument removes trailing characters that match $/ when it has been assigned a value"
  fails "String#chomp! when passed no argument returns nil if self is not modified"
  fails "String#chomp! when passed no argument returns nil when self is empty"
  fails "String#chomp! when passed no argument returns subclass instances when called on a subclass"
  fails "String#chop removes the final carriage return, newline from a non-ASCII String"
  fails "String#chop returns a new string when applied to an empty string"
  fails "String#chop! does not remove more than the final carriage return, newline"
  fails "String#chop! raises a RuntimeError on a frozen instance that is modified"
  fails "String#chop! raises a RuntimeError on a frozen instance that would not be modified"
  fails "String#chop! removes a multi-byte character" # NotImplementedError: String#chop! not supported. Mutable String methods are not supported in Opal.
  fails "String#chop! removes the carriage return, newline if they are the only characters" # NotImplementedError: String#chop! not supported. Mutable String methods are not supported in Opal.
  fails "String#chop! removes the final carriage return"
  fails "String#chop! removes the final carriage return, newline from a multibyte String" # NotImplementedError: String#chop! not supported. Mutable String methods are not supported in Opal.
  fails "String#chop! removes the final carriage return, newline from a non-ASCII String" # ArgumentError: unknown encoding name - utf-32be
  fails "String#chop! removes the final carriage return, newline"
  fails "String#chop! removes the final character"
  fails "String#chop! removes the final newline"
  fails "String#chop! returns nil when called on an empty string"
  fails "String#chop! returns self if modifications were made"
  fails "String#clear preserves its encoding" # NameError: uninitialized constant Encoding::SHIFT_JIS
  fails "String#clear raises a RuntimeError if self is frozen" # NoMethodError: undefined method `clear' for "Jolene":String
  fails "String#clear returns self after emptying it" # NoMethodError: undefined method `clear' for "Jolene":String
  fails "String#clear sets self equal to the empty String" # NoMethodError: undefined method `clear' for "Jolene":String
  fails "String#clear works with multibyte Strings" # NoMethodError: undefined method `clear' for "靥ࡶ":String
  fails "String#clone copies instance variables" # Strings are immutable, so they can't have ivars
  fails "String#clone does not modify the original string when changing cloned string" # string can't be modified
  fails "String#concat concatenates the given argument to self and returns self"
  fails "String#concat concatenates the initial value when given arguments contain 2 self"
  fails "String#concat converts the given argument to a String using to_str"
  fails "String#concat raises a RuntimeError when self is frozen"
  fails "String#concat raises a TypeError if the given argument can't be converted to a String"
  fails "String#concat returns a String when given a subclass instance"
  fails "String#concat returns an instance of same class when called on a subclass"
  fails "String#concat returns self when given no arguments"
  fails "String#concat takes multiple arguments"
  fails "String#concat when self and the argument are in different ASCII-compatible encodings raises Encoding::CompatibilityError if neither are ASCII-only"
  fails "String#concat when self and the argument are in different ASCII-compatible encodings uses self's encoding if both are ASCII-only"
  fails "String#concat when self and the argument are in different ASCII-compatible encodings uses self's encoding if the argument is ASCII-only"
  fails "String#concat when self and the argument are in different ASCII-compatible encodings uses the argument's encoding if self is ASCII-only"
  fails "String#concat when self is ASCII-8BIT and argument is US-ASCII uses ASCII-8BIT encoding"
  fails "String#concat when self is in an ASCII-incompatible encoding incompatible with the argument's encoding raises Encoding::CompatibilityError if neither are empty"
  fails "String#concat when self is in an ASCII-incompatible encoding incompatible with the argument's encoding uses self's encoding if both are empty"
  fails "String#concat when self is in an ASCII-incompatible encoding incompatible with the argument's encoding uses self's encoding if the argument is empty"
  fails "String#concat when self is in an ASCII-incompatible encoding incompatible with the argument's encoding uses the argument's encoding if self is empty"
  fails "String#concat when the argument is in an ASCII-incompatible encoding incompatible with self's encoding raises Encoding::CompatibilityError if neither are empty"
  fails "String#concat when the argument is in an ASCII-incompatible encoding incompatible with self's encoding uses self's encoding if both are empty"
  fails "String#concat when the argument is in an ASCII-incompatible encoding incompatible with self's encoding uses self's encoding if the argument is empty"
  fails "String#concat when the argument is in an ASCII-incompatible encoding incompatible with self's encoding uses the argument's encoding if self is empty"
  fails "String#concat with Integer concatenates the argument interpreted as a codepoint" # NoMethodError: undefined method `concat' for ""
  fails "String#concat with Integer doesn't call to_int on its argument"
  fails "String#concat with Integer raises RangeError if the argument is an invalid codepoint for self's encoding"
  fails "String#concat with Integer raises RangeError if the argument is negative"
  fails "String#concat with Integer raises a RuntimeError when self is frozen"
  fails "String#concat with Integer returns a ASCII-8BIT string if self is US-ASCII and the argument is between 128-255 (inclusive)"
  fails "String#count returns the number of occurrences of a multi-byte character"
  fails "String#delete! modifies self in place and returns self"
  fails "String#delete! raises a RuntimeError when self is frozen"
  fails "String#delete! returns nil if no modifications were made"
  fails "String#delete_prefix returns a copy of the string, when the prefix isn't found" # Fails because "string".equal?("string") is always true
  fails "String#delete_prefix! calls to_str on its argument"
  fails "String#delete_prefix! doesn't set $~"
  fails "String#delete_prefix! removes the found prefix"
  fails "String#delete_prefix! returns nil if no change is made"
  fails "String#delete_suffix returns a copy of the string, when the suffix isn't found" # Fails because "string".equal?("string") is always true
  fails "String#delete_suffix! calls to_str on its argument"
  fails "String#delete_suffix! doesn't set $~"
  fails "String#delete_suffix! removes the found prefix"
  fails "String#delete_suffix! returns nil if no change is made"
  fails "String#downcase is locale insensitive (only replaces A-Z)"
  fails "String#downcase! ASCII-only case mapping does not downcase non-ASCII characters" # NotImplementedError: String#downcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#downcase! ASCII-only case mapping works for non-ascii-compatible encodings" # NotImplementedError: String#downcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#downcase! case folding case folds special characters" # NotImplementedError: String#downcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#downcase! does not allow invalid options" # NotImplementedError: String#downcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#downcase! full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # NotImplementedError: String#downcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#downcase! full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # NotImplementedError: String#downcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#downcase! full Unicode case mapping adapted for Lithuanian does not allow any other additional option" # NotImplementedError: String#downcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#downcase! full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # NotImplementedError: String#downcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#downcase! full Unicode case mapping adapted for Turkic languages does not allow any other additional option" # NotImplementedError: String#downcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#downcase! full Unicode case mapping adapted for Turkic languages downcases characters according to Turkic semantics" # NotImplementedError: String#downcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#downcase! full Unicode case mapping modifies self in place for all of Unicode with no option" # NotImplementedError: String#downcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#downcase! full Unicode case mapping updates string metadata" # NotImplementedError: String#downcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#downcase! modifies self in place for all of Unicode" # NotImplementedError: String#downcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#downcase! modifies self in place for non-ascii-compatible encodings" # NotImplementedError: String#downcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#downcase! modifies self in place"
  fails "String#downcase! raises a RuntimeError when self is frozen"
  fails "String#downcase! returns nil if no modifications were made"
  fails "String#downcase! sets the result String encoding to the source String encoding" # Expected #<Encoding:UTF-16LE> to be identical to #<Encoding:UTF-8>
  fails "String#dup copies instance variables" # Strings are immutable, so they can't have ivars
  fails "String#dup does not copy singleton methods" # TypeError: can't define singleton
  fails "String#dup does not modify the original string when changing dupped string"
  fails "String#each_char is unicode aware"
  fails "String#each_line does not care if the string is modified while substituting"
  fails "String#each_line raises a TypeError when the separator is a symbol"
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
  fails "String#encode! raises a RuntimeError when called on a frozen String when it's a no-op" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! raises a RuntimeError when called on a frozen String" # NoMethodError: undefined method `default_internal' for Encoding
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
  fails "String#gsub! with pattern and Hash coerces the hash values with #to_s"
  fails "String#gsub! with pattern and Hash doesn't interpolate special sequences like \\1 for the block's return value"
  fails "String#gsub! with pattern and Hash ignores keys that don't correspond to matches"
  fails "String#gsub! with pattern and Hash ignores non-String keys"
  fails "String#gsub! with pattern and Hash replaces self with an empty string if the pattern matches but the hash specifies no replacements"
  fails "String#gsub! with pattern and Hash returns self with all occurrences of pattern replaced with the value of the corresponding hash key"
  fails "String#gsub! with pattern and Hash sets $~ to MatchData of last match and nil when there's none for access from outside"
  fails "String#gsub! with pattern and Hash uses a key's value as many times as needed"
  fails "String#gsub! with pattern and Hash uses the hash's default value for missing keys"
  fails "String#gsub! with pattern and Hash uses the hash's value set from default_proc for missing keys"
  fails "String#gsub! with pattern and block modifies self in place and returns self"
  fails "String#gsub! with pattern and block raises a RuntimeError when self is frozen"
  fails "String#gsub! with pattern and block raises an ArgumentError if encoding is not valid"
  fails "String#gsub! with pattern and block raises an Encoding::CompatibilityError if the encodings are not compatible"
  fails "String#gsub! with pattern and block replaces the incompatible part properly even if the encodings are not compatible"
  fails "String#gsub! with pattern and block returns nil if no modifications were made"
  fails "String#gsub! with pattern and block uses the compatible encoding if they are compatible"
  fails "String#gsub! with pattern and replacement modifies self in place and returns self"
  fails "String#gsub! with pattern and replacement modifies self in place with multi-byte characters and returns self"
  fails "String#gsub! with pattern and replacement raises a RuntimeError when self is frozen"
  fails "String#gsub! with pattern and replacement returns nil if no modifications were made"
  fails "String#gsub! with pattern and without replacement and block returned Enumerator size should return nil"
  fails "String#gsub! with pattern and without replacement and block returns an enumerator"
  fails "String#index raises a TypeError if passed a Symbol"
  fails "String#index with Regexp supports \\G which matches at the given start offset"
  fails "String#initialize is a private method"
  fails "String#initialize with an argument carries over the encoding invalidity"
  fails "String#initialize with an argument raises a RuntimeError on a frozen instance that is modified"
  fails "String#initialize with an argument raises a RuntimeError on a frozen instance when self-replacing"
  fails "String#initialize with an argument raises a TypeError if other can't be converted to string"
  fails "String#initialize with an argument replaces the content of self with other"
  fails "String#initialize with an argument replaces the encoding of self with that of other"
  fails "String#initialize with an argument returns self"
  fails "String#initialize with an argument tries to convert other to string using to_str"
  fails "String#insert with index, other converts index to an integer using to_int"
  fails "String#insert with index, other converts other to a string using to_str"
  fails "String#insert with index, other inserts after the given character on an negative count"
  fails "String#insert with index, other inserts other before the character at the given index"
  fails "String#insert with index, other modifies self in place"
  fails "String#insert with index, other raises a RuntimeError if self is frozen"
  fails "String#insert with index, other raises a TypeError if other can't be converted to string"
  fails "String#insert with index, other raises an IndexError if the index is beyond string"
  fails "String#lines does not care if the string is modified while substituting"
  fails "String#lines raises a TypeError when the separator is a symbol"
  fails "String#lstrip! modifies self in place and returns self"
  fails "String#lstrip! raises a RuntimeError on a frozen instance that is modified"
  fails "String#lstrip! raises a RuntimeError on a frozen instance that would not be modified"
  fails "String#lstrip! returns nil if no modifications were made"
  fails "String#match matches \\G at the start of the string"
  fails "String#next! is equivalent to succ, but modifies self in place (still returns self)"
  fails "String#next! raises a RuntimeError if self is frozen"
  fails "String#prepend converts the given argument to a String using to_str"
  fails "String#prepend prepends the given argument to self and returns self"
  fails "String#prepend prepends the initial value when given arguments contain 2 self"
  fails "String#prepend raises a RuntimeError when self if frozen"
  fails "String#prepend raises a RuntimeError when self is frozen" # NoMethodError: undefined method `prepend' for "hello":String
  fails "String#prepend raises a TypeError if the given argument can't be converted to a String"
  fails "String#prepend returns self when given no arguments"
  fails "String#prepend takes multiple arguments"
  fails "String#prepend works when given a subclass instance"
  fails "String#replace carries over the encoding invalidity"
  fails "String#replace raises a RuntimeError on a frozen instance that is modified"
  fails "String#replace raises a RuntimeError on a frozen instance when self-replacing"
  fails "String#replace raises a TypeError if other can't be converted to string"
  fails "String#replace replaces the content of self with other"
  fails "String#replace replaces the encoding of self with that of other"
  fails "String#replace returns self"
  fails "String#replace tries to convert other to string using to_str"
  fails "String#reverse! raises a RuntimeError on a frozen instance that is modified"
  fails "String#reverse! raises a RuntimeError on a frozen instance that would not be modified"
  fails "String#reverse! reverses a string with multi byte characters" # NotImplementedError: String#reverse! not supported. Mutable String methods are not supported in Opal.
  fails "String#reverse! reverses self in place and always returns self"
  fails "String#rindex with Regexp supports \\G which matches at the given start offset"
  fails "String#rstrip! modifies self in place and returns self"
  fails "String#rstrip! modifies self removing trailing NULL bytes and whitespace"
  fails "String#rstrip! raises a RuntimeError on a frozen instance that is modified"
  fails "String#rstrip! raises a RuntimeError on a frozen instance that would not be modified"
  fails "String#rstrip! returns nil if no modifications were made"
  fails "String#scan supports \\G which matches the end of the previous match / string start for first match"
  fails "String#setbyte allows changing bytes in multi-byte characters"
  fails "String#setbyte calls #to_int to convert the index"
  fails "String#setbyte calls to_int to convert the value"
  fails "String#setbyte can invalidate a String's encoding"
  fails "String#setbyte changes the byte at the given index to the new byte"
  fails "String#setbyte does not modify the original string when using String.new"
  fails "String#setbyte modifies the receiver"
  fails "String#setbyte raises a RuntimeError if self is frozen"
  fails "String#setbyte raises a TypeError unless the second argument is an Integer"
  fails "String#setbyte raises an IndexError if the index is greater than the String bytesize"
  fails "String#setbyte raises an IndexError if the negative index is greater magnitude than the String bytesize" # NoMethodError: undefined method `setbyte' for "???"
  fails "String#setbyte regards a negative index as counting from the end of the String"
  fails "String#setbyte returns an Integer"
  fails "String#setbyte sets a byte at an index greater than String size"
  fails "String#slice with Symbol raises TypeError"
  fails "String#slice! Range calls to_int on range arguments"
  fails "String#slice! Range deletes and return the substring given by the offsets of the range"
  fails "String#slice! Range raises a RuntimeError on a frozen instance that is modified"
  fails "String#slice! Range raises a RuntimeError on a frozen instance that would not be modified"
  fails "String#slice! Range returns String instances" # NotImplementedError: String#slice! not supported. Mutable String methods are not supported in Opal.
  fails "String#slice! Range returns nil if the given range is out of self"
  fails "String#slice! Range returns subclass instances"
  fails "String#slice! Range returns the substring given by the character offsets of the range" # NotImplementedError: String#slice! not supported. Mutable String methods are not supported in Opal.
  fails "String#slice! Range works with Range subclasses"
  fails "String#slice! with Regexp deletes and returns the first match from self"
  fails "String#slice! with Regexp raises a RuntimeError on a frozen instance that is modified"
  fails "String#slice! with Regexp raises a RuntimeError on a frozen instance that would not be modified"
  fails "String#slice! with Regexp returns String instances" # NotImplementedError: String#slice! not supported. Mutable String methods are not supported in Opal.
  fails "String#slice! with Regexp returns nil if there was no match"
  fails "String#slice! with Regexp returns subclass instances"
  fails "String#slice! with Regexp returns the matching portion of self with a multi byte character" # NotImplementedError: String#slice! not supported. Mutable String methods are not supported in Opal.
  fails "String#slice! with Regexp sets $~ to MatchData when there is a match and nil when there's none"
  fails "String#slice! with Regexp, index accepts a Float for capture index"
  fails "String#slice! with Regexp, index calls #to_int to convert an Object to capture index"
  fails "String#slice! with Regexp, index deletes and returns the capture for idx from self"
  fails "String#slice! with Regexp, index raises a RuntimeError if self is frozen"
  fails "String#slice! with Regexp, index returns String instances" # NotImplementedError: String#slice! not supported. Mutable String methods are not supported in Opal.
  fails "String#slice! with Regexp, index returns nil if there is no capture for idx"
  fails "String#slice! with Regexp, index returns nil if there was no match"
  fails "String#slice! with Regexp, index returns subclass instances"
  fails "String#slice! with Regexp, index returns the encoding aware capture for the given index" # NotImplementedError: String#slice! not supported. Mutable String methods are not supported in Opal.
  fails "String#slice! with Regexp, index sets $~ to MatchData when there is a match and nil when there's none"
  fails "String#slice! with String doesn't call to_str on its argument"
  fails "String#slice! with String doesn't set $~"
  fails "String#slice! with String raises a RuntimeError if self is frozen"
  fails "String#slice! with String removes and returns the first occurrence of other_str from self"
  fails "String#slice! with String returns a subclass instance when given a subclass instance"
  fails "String#slice! with String returns nil if self does not contain other"
  fails "String#slice! with index calls to_int on index"
  fails "String#slice! with index deletes and return the char at the given position"
  fails "String#slice! with index raises a RuntimeError if self is frozen"
  fails "String#slice! with index returns nil if idx is outside of self"
  fails "String#slice! with index returns the character given by the character index" # NotImplementedError: String#slice! not supported. Mutable String methods are not supported in Opal.
  fails "String#slice! with index, length calls to_int on idx and length"
  fails "String#slice! with index, length deletes and returns the substring at idx and the given length"
  fails "String#slice! with index, length raises a RuntimeError if self is frozen"
  fails "String#slice! with index, length returns String instances" # NotImplementedError: String#slice! not supported. Mutable String methods are not supported in Opal.
  fails "String#slice! with index, length returns nil if the length is negative"
  fails "String#slice! with index, length returns subclass instances"
  fails "String#slice! with index, length returns the substring given by the character offsets" # NotImplementedError: String#slice! not supported. Mutable String methods are not supported in Opal.
  fails "String#slice! with index, length treats invalid bytes as single bytes" # NoMethodError: undefined method `pack' for [230, 203]:Array
  fails "String#squeeze! modifies self in place and returns self"
  fails "String#squeeze! raises a RuntimeError when self is frozen"
  fails "String#squeeze! raises an ArgumentError when the parameter is out of sequence"
  fails "String#squeeze! returns nil if no modifications were made"
  fails "String#strip! modifies self in place and returns self"
  fails "String#strip! modifies self removing trailing NULL bytes and whitespace"
  fails "String#strip! raises a RuntimeError on a frozen instance that is modified"
  fails "String#strip! raises a RuntimeError on a frozen instance that would not be modified"
  fails "String#strip! returns nil if no modifications where made"
  fails "String#sub with pattern and Hash ignores non-String keys" # Expected "tazoo" == "taboo" to be truthy but was false
  fails "String#sub with pattern and block doesn't raise a RuntimeError if the string is modified while substituting" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
  fails "String#sub with pattern, replacement raises a TypeError when pattern is a Symbol"
  fails "String#sub! with pattern and Hash coerces the hash values with #to_s"
  fails "String#sub! with pattern and Hash doesn't interpolate special sequences like \\1 for the block's return value"
  fails "String#sub! with pattern and Hash ignores non-String keys"
  fails "String#sub! with pattern and Hash removes keys that don't correspond to matches"
  fails "String#sub! with pattern and Hash returns self with the first occurrence of pattern replaced with the value of the corresponding hash key"
  fails "String#sub! with pattern and Hash sets $~ to MatchData of first match and nil when there's none for access from outside"
  fails "String#sub! with pattern and Hash uses a key's value only a single time"
  fails "String#sub! with pattern and Hash uses the hash's default value for missing keys"
  fails "String#sub! with pattern and Hash uses the hash's value set from default_proc for missing keys"
  fails "String#sub! with pattern and block modifies self in place and returns self"
  fails "String#sub! with pattern and block raises a RuntimeError if the string is modified while substituting"
  fails "String#sub! with pattern and block raises a RuntimeError when self is frozen"
  fails "String#sub! with pattern and block returns nil if no modifications were made"
  fails "String#sub! with pattern and block sets $~ for access from the block"
  fails "String#sub! with pattern and without replacement and block raises a ArgumentError"
  fails "String#sub! with pattern, replacement modifies self in place and returns self"
  fails "String#sub! with pattern, replacement raises a RuntimeError when self is frozen"
  fails "String#sub! with pattern, replacement returns nil if no modifications were made"
  fails "String#succ! is equivalent to succ, but modifies self in place (still returns self)"
  fails "String#succ! raises a RuntimeError if self is frozen"
  fails "String#swapcase! does not allow invalid options" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#swapcase! does not allow the :fold option for upcasing" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#swapcase! full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#swapcase! full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#swapcase! full Unicode case mapping adapted for Lithuanian does not allow any other additional option" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#swapcase! full Unicode case mapping modifies self in place for all of Unicode with no option" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#swapcase! full Unicode case mapping updates string metadata" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#swapcase! full Unicode case mapping works for non-ascii-compatible encodings" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#swapcase! modifies self in place for ASCII-only case mapping does not swapcase non-ASCII characters" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#swapcase! modifies self in place for ASCII-only case mapping works for non-ascii-compatible encodings" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#swapcase! modifies self in place for all of Unicode" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#swapcase! modifies self in place for full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#swapcase! modifies self in place for full Unicode case mapping adapted for Turkic languages does not allow any other additional option" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#swapcase! modifies self in place for full Unicode case mapping adapted for Turkic languages swaps case of ASCII characters according to Turkic semantics" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#swapcase! modifies self in place for non-ascii-compatible encodings" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#swapcase! modifies self in place"
  fails "String#swapcase! raises a RuntimeError when self is frozen"
  fails "String#swapcase! returns nil if no modifications were made"
  fails "String#to_i with bases parses a String in base 10" # Expected "1.2345678901234567e+99" == "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" to be truthy but was false
  fails "String#to_i with bases parses a String in base 11" # Expected "1234567890a1234720000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890a1234567890a1234567890a1234567890a1234567890a1234567890a1234567890a1234567890a1234567890a" to be truthy but was false
  fails "String#to_i with bases parses a String in base 12" # Expected "1234567890ab121800000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890ab1234567890ab1234567890ab1234567890ab1234567890ab1234567890ab1234567890ab1234567890ab" to be truthy but was false
  fails "String#to_i with bases parses a String in base 13" # Expected "1234567890abc110000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abc1234567890abc1234567890abc1234567890abc1234567890abc1234567890abc1234567890abc" to be truthy but was false
  fails "String#to_i with bases parses a String in base 14" # Expected "1234567890abcdc00000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcd1234567890abcd1234567890abcd1234567890abcd1234567890abcd1234567890abcd1234567890abcd" to be truthy but was false
  fails "String#to_i with bases parses a String in base 15" # Expected "1234567890abcd9000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcde1234567890abcde1234567890abcde1234567890abcde1234567890abcde1234567890abcde" to be truthy but was false
  fails "String#to_i with bases parses a String in base 16" # Expected "1234567890abce0000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef" to be truthy but was false
  fails "String#to_i with bases parses a String in base 17" # Expected "1234567890abcg00000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefg1234567890abcdefg1234567890abcdefg1234567890abcdefg1234567890abcdefg" to be truthy but was false
  fails "String#to_i with bases parses a String in base 18" # Expected "1234567890abc40000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefgh1234567890abcdefgh1234567890abcdefgh1234567890abcdefgh1234567890abcdefgh" to be truthy but was false
  fails "String#to_i with bases parses a String in base 19" # Expected "1234567890abcc000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghi1234567890abcdefghi1234567890abcdefghi1234567890abcdefghi1234567890abcdefghi" to be truthy but was false
  fails "String#to_i with bases parses a String in base 2" # Expected "1010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000" == "1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010" to be truthy but was false
  fails "String#to_i with bases parses a String in base 20" # Expected "1234567890abcg00000000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij1234567890abcdefghij" to be truthy but was false
  fails "String#to_i with bases parses a String in base 21" # Expected "1234567890abad0000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijk1234567890abcdefghijk1234567890abcdefghijk1234567890abcdefghijk" to be truthy but was false
  fails "String#to_i with bases parses a String in base 22" # Expected "1234567890abg000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijkl1234567890abcdefghijkl1234567890abcdefghijkl1234567890abcdefghijkl" to be truthy but was false
  fails "String#to_i with bases parses a String in base 23" # Expected "1234567890abk0000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklm1234567890abcdefghijklm1234567890abcdefghijklm1234567890abcdefghijklm" to be truthy but was false
  fails "String#to_i with bases parses a String in base 24" # Expected "1234567890acg00000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmn1234567890abcdefghijklmn1234567890abcdefghijklmn1234567890abcdefghijklmn" to be truthy but was false
  fails "String#to_i with bases parses a String in base 25" # Expected "1234567890ae3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmno1234567890abcdefghijklmno1234567890abcdefghijklmno1234567890abcdefghijklmno" to be truthy but was false
  fails "String#to_i with bases parses a String in base 26" # Expected "1234567890aba00000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnop1234567890abcdefghijklmnop1234567890abcdefghijklmnop" to be truthy but was false
  fails "String#to_i with bases parses a String in base 27" # Expected "1234567890aen00000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopq1234567890abcdefghijklmnopq1234567890abcdefghijklmnopq" to be truthy but was false
  fails "String#to_i with bases parses a String in base 28" # Expected "1234567890a6o00000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqr1234567890abcdefghijklmnopqr1234567890abcdefghijklmnopqr" to be truthy but was false
  fails "String#to_i with bases parses a String in base 29" # Expected "1234567890ab000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqrs1234567890abcdefghijklmnopqrs1234567890abcdefghijklmnopqrs" to be truthy but was false
  fails "String#to_i with bases parses a String in base 3" # Expected "120120120120120120120120120120121200000000000000000000000000000000000000000000000000000000000000000" == "120120120120120120120120120120120120120120120120120120120120120120120120120120120120120120120120120" to be truthy but was false
  fails "String#to_i with bases parses a String in base 30" # Expected "1234567890a8000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqrst1234567890abcdefghijklmnopqrst1234567890abcdefghijklmnopqrst" to be truthy but was false
  fails "String#to_i with bases parses a String in base 31" # Expected "1234567890a7000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqrstu1234567890abcdefghijklmnopqrstu1234567890abcdefghijklmnopqrstu" to be truthy but was false
  fails "String#to_i with bases parses a String in base 32" # Expected "1234567890a8000000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqrstuv1234567890abcdefghijklmnopqrstuv1234567890abcdefghijklmnopqrstuv" to be truthy but was false
  fails "String#to_i with bases parses a String in base 33" # Expected "1234567890ah000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqrstuvw1234567890abcdefghijklmnopqrstuvw1234567890abcdefghijklmnopqrstuvw" to be truthy but was false
  fails "String#to_i with bases parses a String in base 34" # Expected "1234567890a400000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqrstuvwx1234567890abcdefghijklmnopqrstuvwx" to be truthy but was false
  fails "String#to_i with bases parses a String in base 35" # Expected "12345678908x0000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqrstuvwxy1234567890abcdefghijklmnopqrstuvwxy" to be truthy but was false
  fails "String#to_i with bases parses a String in base 36" # Expected "1234567890ao000000000000000000000000000000000000000000000000000000000000" == "1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz" to be truthy but was false
  fails "String#to_i with bases parses a String in base 4" # Expected "1230123012301230123012301230000000000000000000000000000000000000000000000000000000000000000000000000" == "1230123012301230123012301230123012301230123012301230123012301230123012301230123012301230123012301230" to be truthy but was false
  fails "String#to_i with bases parses a String in base 5" # Expected "1234012340123401234012100000000000000000000000000000000000000000000000000000000000000000000000000000" == "1234012340123401234012340123401234012340123401234012340123401234012340123401234012340123401234012340" to be truthy but was false
  fails "String#to_i with bases parses a String in base 6" # Expected "123450123450123450122400000000000000000000000000000000000000000000000000000000000000000000000000" == "123450123450123450123450123450123450123450123450123450123450123450123450123450123450123450123450" to be truthy but was false
  fails "String#to_i with bases parses a String in base 7" # Expected "12345601234560123501000000000000000000000000000000000000000000000000000000000000000000000000000000" == "12345601234560123456012345601234560123456012345601234560123456012345601234560123456012345601234560" to be truthy but was false
  fails "String#to_i with bases parses a String in base 8" # Expected "123456701234567012400000000000000000000000000000000000000000000000000000000000000000000000000000" == "123456701234567012345670123456701234567012345670123456701234567012345670123456701234567012345670" to be truthy but was false
  fails "String#to_i with bases parses a String in base 9" # Expected "123456780123456780000000000000000000000000000000000000000000000000000000000000000000000000000000000" == "123456780123456780123456780123456780123456780123456780123456780123456780123456780123456780123456780" to be truthy but was false  
  fails "String#tr! does not modify self if from_str is empty"
  fails "String#tr! modifies self in place"
  fails "String#tr! raises a RuntimeError if self is frozen"
  fails "String#tr! returns nil if no modification was made"
  fails "String#tr_s! does not modify self if from_str is empty"
  fails "String#tr_s! modifies self in place"
  fails "String#tr_s! raises a RuntimeError if self is frozen"
  fails "String#tr_s! returns nil if no modification was made"
  fails "String#unicode_normalize! modifies original string (nfc)"
  fails "String#unicode_normalize! modifies self in place (nfd)"
  fails "String#unicode_normalize! modifies self in place (nfkc)"
  fails "String#unicode_normalize! modifies self in place (nfkd)"
  fails "String#unicode_normalize! normalizes code points and modifies the receiving string"
  fails "String#unicode_normalize! raises an ArgumentError if the specified form is invalid"
  fails "String#unicode_normalize! raises an Encoding::CompatibilityError if the string is not in an unicode encoding"
  fails "String#upcase! does not allow invalid options" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#upcase! does not allow the :fold option for upcasing" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#upcase! full Unicode case mapping modifies self in place for all of Unicode with no option" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#upcase! full Unicode case mapping updates string metadata for self" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#upcase! full Unicode case mapping works for non-ascii-compatible encodings" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#upcase! modifies self in place for ASCII-only case mapping does not upcase non-ASCII characters" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#upcase! modifies self in place for ASCII-only case mapping works for non-ascii-compatible encodings" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#upcase! modifies self in place for all of Unicode" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#upcase! modifies self in place for full Unicode case mapping adapted for Lithuanian allows Turkic as an extra option (and applies Turkic semantics)" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#upcase! modifies self in place for full Unicode case mapping adapted for Lithuanian currently works the same as full Unicode case mapping" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#upcase! modifies self in place for full Unicode case mapping adapted for Lithuanian does not allow any other additional option" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#upcase! modifies self in place for full Unicode case mapping adapted for Turkic languages allows Lithuanian as an extra option" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#upcase! modifies self in place for full Unicode case mapping adapted for Turkic languages does not allow any other additional option" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#upcase! modifies self in place for full Unicode case mapping adapted for Turkic languages upcases ASCII characters according to Turkic semantics" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#upcase! modifies self in place for non-ascii-compatible encodings" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#upcase! modifies self in place"
  fails "String#upcase! raises a RuntimeError when self is frozen"
  fails "String#upcase! returns nil if no modifications were made"
  fails "String#upto does not work with symbols"
  fails "String.allocate returns a binary String"
  fails "String.allocate returns a fully-formed String"
  fails "String.new returns a binary String"
  fails "String.new returns a fully-formed String"
  fails "String.new returns a new string given a string argument"
end
