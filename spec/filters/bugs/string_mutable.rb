# NOTE: run bin/format-filters after changing this file
# This file contains a list of bugs after the tests are ran in Mutable String mode
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
  fails "String#<< when self and the argument are in different ASCII-compatible encodings raises Encoding::CompatibilityError if neither are ASCII-only" # Exception: Cannot convert object to primitive value
  fails "String#<< when self and the argument are in different ASCII-compatible encodings uses self's encoding if both are ASCII-only" # ArgumentError: unknown encoding name - SHIFT_JIS
  fails "String#<< when self and the argument are in different ASCII-compatible encodings uses the argument's encoding if self is ASCII-only" # Expected #<Encoding:UTF-8> == #<Encoding:ISO-8859-1> to be truthy but was false
  fails "String#<< when self is in an ASCII-incompatible encoding incompatible with the argument's encoding raises Encoding::CompatibilityError if neither are empty" # Exception: Cannot convert object to primitive value
  fails "String#<< when self is in an ASCII-incompatible encoding incompatible with the argument's encoding uses the argument's encoding if self is empty" # Expected #<Encoding:UTF-16LE> == #<Encoding:UTF-8> to be truthy but was false
  fails "String#<< when the argument is in an ASCII-incompatible encoding incompatible with self's encoding raises Encoding::CompatibilityError if neither are empty" # Exception: Cannot convert object to primitive value
  fails "String#<< when the argument is in an ASCII-incompatible encoding incompatible with self's encoding uses the argument's encoding if self is empty" # Expected #<Encoding:UTF-8> == #<Encoding:UTF-16LE> to be truthy but was false
  fails "String#<< with Integer concatenates the argument interpreted as a codepoint" # TypeError: no implicit conversion of Number into String
  fails "String#<< with Integer raises RangeError if the argument is an invalid codepoint for self's encoding" # Expected RangeError but got: TypeError (no implicit conversion of Number into String)
  fails "String#<< with Integer raises RangeError if the argument is negative" # Expected RangeError but got: TypeError (no implicit conversion of Number into String)
  fails "String#concat raises a TypeError if the given argument can't be converted to a String" # Expected TypeError but no exception was raised ("hello " was returned)
  fails "String#concat when self and the argument are in different ASCII-compatible encodings raises Encoding::CompatibilityError if neither are ASCII-only" # Expected CompatibilityError but no exception was raised ("éé" was returned)
  fails "String#concat when self and the argument are in different ASCII-compatible encodings uses self's encoding if both are ASCII-only" # ArgumentError: unknown encoding name - SHIFT_JIS
  fails "String#concat when self and the argument are in different ASCII-compatible encodings uses the argument's encoding if self is ASCII-only" # Expected #<Encoding:UTF-8> == #<Encoding:ISO-8859-1> to be truthy but was false
  fails "String#concat when self is in an ASCII-incompatible encoding incompatible with the argument's encoding raises Encoding::CompatibilityError if neither are empty" # Expected CompatibilityError but no exception was raised ("xy" was returned)
  fails "String#concat when self is in an ASCII-incompatible encoding incompatible with the argument's encoding uses the argument's encoding if self is empty" # Expected #<Encoding:UTF-16LE> == #<Encoding:UTF-8> to be truthy but was false
  fails "String#concat when the argument is in an ASCII-incompatible encoding incompatible with self's encoding raises Encoding::CompatibilityError if neither are empty" # Expected CompatibilityError but no exception was raised ("xy" was returned)
  fails "String#concat when the argument is in an ASCII-incompatible encoding incompatible with self's encoding uses the argument's encoding if self is empty" # Expected #<Encoding:UTF-8> == #<Encoding:UTF-16LE> to be truthy but was false
  fails "String#concat with Integer concatenates the argument interpreted as a codepoint" # Expected "33" == "!" to be truthy but was false
  fails "String#concat with Integer doesn't call to_int on its argument" # Expected TypeError but no exception was raised ("#<MockObject:0x69dda>" was returned)
  fails "String#concat with Integer raises RangeError if the argument is an invalid codepoint for self's encoding" # Expected RangeError but no exception was raised ("256" was returned)
  fails "String#concat with Integer raises RangeError if the argument is negative" # Expected RangeError but no exception was raised ("-200" was returned)
  fails "String#delete_prefix calls to_str on its argument" # Expected "hello" == "o" to be truthy but was false
  fails "String#delete_prefix returns a copy of the string, with the given prefix removed" # Expected "hello" == "o" to be truthy but was false
  fails "String#delete_suffix calls to_str on its argument" # Expected "hello" == "h" to be truthy but was false
  fails "String#delete_suffix returns a copy of the string, with the given suffix removed" # Expected "hello" == "h" to be truthy but was false
  fails "String#each_line does not care if the string is modified while substituting" # NotImplementedError: NotImplementedError
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
  fails "String#encode! when passed no options transcodes a 7-bit String despite no generic converting being available" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed no options transcodes to Encoding.default_internal when set" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed options calls #to_hash to convert the object" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed options does not process transcoding options if not transcoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed options raises an Encoding::ConverterNotFoundError when no conversion is possible despite 'invalid: :replace, undef: :replace'" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed options replaces invalid characters when replacing Emacs-Mule encoded strings" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed options transcodes to Encoding.default_internal when set" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to encoding accepts a String argument" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to encoding calls #to_str to convert the object to an Encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to encoding raises an Encoding::ConverterNotFoundError for an invalid encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to encoding raises an Encoding::ConverterNotFoundError when no conversion is possible" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to encoding transcodes Japanese multibyte characters" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to encoding transcodes a 7-bit String despite no generic converting being available" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to encoding transcodes to the passed encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, from calls #to_str to convert the from object to an Encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, from transcodes between the encodings ignoring the String encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, from, options calls #to_hash to convert the options object" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, from, options calls #to_str to convert the from object to an encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, from, options calls #to_str to convert the to object to an encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, from, options replaces invalid characters in the destination encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, from, options replaces undefined characters in the destination encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, options calls #to_hash to convert the options object" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, options replaces invalid characters in the destination encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! when passed to, options replaces undefined characters in the destination encoding" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#replace carries over the encoding invalidity" # Expected true to be false
  fails "String#replace raises a TypeError if other can't be converted to string" # Expected TypeError but no exception was raised ("123" was returned)
  fails "String#replace replaces the content of self with other" # Exception: Cannot convert object to primitive value
  fails "String#replace replaces the encoding of self with that of other" # Expected #<Encoding:UTF-16LE> == #<Encoding:UTF-8> to be truthy but was false
  fails "String#replace tries to convert other to string using to_str" # Exception: Cannot convert object to primitive value
  fails "String#upto on sequence of numbers calls the block as Integer#upto" # Expected [] == ["8", "9", "10", "11"] to be truthy but was false
  fails "String#upto when no block is given returns an enumerator" # Expected 677 == 676 to be truthy but was false
end
