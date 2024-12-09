# NOTE: run bin/format-filters after changing this file
opal_filter "String" do
  fails "A singleton class has class String as the superclass of a String instance" # Exception: Cannot create property '$$meta' on string 'blah'
  fails "Ruby String interpolation creates a non-frozen String when # frozen-string-literal: true is used" # Expected "a42c".frozen? to be falsy but was true
  fails "Ruby String interpolation creates a non-frozen String" # Expected "a42c".frozen? to be falsy but was true
  fails "Ruby String interpolation permits an empty expression" # Expected "".frozen? to be falsy but was true
  fails "SimpleDelegator can be marshalled with its instance variables intact" # Exception: Cannot create property '$$meta' on string '__v2__'
  fails "String#% returns a String in the argument's encoding if format encoding is more restrictive" # FrozenError: can't modify frozen String
  fails "String#<=> with String ignores encoding difference" # FrozenError: can't modify frozen String
  fails "String#<=> with String returns 0 when comparing 2 empty strings but one is not ASCII-compatible" # FrozenError: can't modify frozen String
  fails "String#<=> with String returns 0 with identical ASCII-compatible bytes of different encodings" # FrozenError: can't modify frozen String
  fails "String#[] with index, length returns a string with the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#ascii_only? returns false for a non-empty String with non-ASCII-compatible encoding" # FrozenError: can't modify frozen String
  fails "String#ascii_only? returns false for the empty String with a non-ASCII-compatible encoding" # FrozenError: can't modify frozen String
  fails "String#ascii_only? returns false when interpolating non ascii strings" # FrozenError: can't modify frozen String
  fails "String#ascii_only? with ASCII only characters returns true if the encoding is US-ASCII" # FrozenError: can't modify frozen String
  fails "String#ascii_only? with non-ASCII only characters returns false if the encoding is US-ASCII" # FrozenError: can't modify frozen String
  fails "String#b returns a binary encoded string" # FrozenError: can't modify frozen String
  fails "String#byteindex with String handles a substring in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#byteindex with String handles a substring in a superset encoding" # FrozenError: can't modify frozen String
  fails "String#byterindex with String handles a substring in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#byterindex with String handles a substring in a superset encoding" # FrozenError: can't modify frozen String
  fails "String#bytes is unaffected by #force_encoding" # FrozenError: can't modify frozen String
  fails "String#bytesize returns 0 for the empty string" # FrozenError: can't modify frozen String
  fails "String#bytesize works with pseudo-ASCII strings containing UTF-8 characters" # FrozenError: can't modify frozen String
  fails "String#bytesize works with pseudo-ASCII strings containing single UTF-8 characters" # FrozenError: can't modify frozen String
  fails "String#byteslice with index, length returns a string with the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#capitalize returns a String in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#casecmp independent of case returns 0 for empty strings in different encodings" # FrozenError: can't modify frozen String
  fails "String#casecmp? independent of case returns true for empty strings in different encodings" # FrozenError: can't modify frozen String
  fails "String#center with length, padding with width returns a String in the same encoding as the original" # FrozenError: can't modify frozen String
  fails "String#chars returns characters in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#chomp removes the final carriage return, newline from a non-ASCII String when the record separator is changed" # FrozenError: can't modify frozen String
  fails "String#chomp removes the final carriage return, newline from a non-ASCII String" # FrozenError: can't modify frozen String
  fails "String#chomp when passed no argument returns a String in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#chop removes the final carriage return, newline from a non-ASCII String" # FrozenError: can't modify frozen String
  fails "String#chop returns a String in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#chr returns a String in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#clone copies frozen state" # Expected false to be true
  fails "String#delete returns a String in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#delete_prefix returns a String in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#delete_suffix returns a String in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#downcase returns a String in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#dump does not take into account if a string is frozen" # Expected "\"foo\"".frozen? to be falsy but was true
  fails "String#each_char returns characters in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#gsub with pattern and replacement handles a pattern in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#index with String handles a substring in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#index with String handles a substring in a superset encoding" # FrozenError: can't modify frozen String
  fails "String#ljust with length, padding with width, pattern returns a String in the compatible encoding" # FrozenError: can't modify frozen String
  fails "String#rindex with String handles a substring in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#rindex with String handles a substring in a superset encoding" # FrozenError: can't modify frozen String
  fails "String#rjust with length, padding with width, pattern returns a String in the compatible encoding" # FrozenError: can't modify frozen String
  fails "String#slice with index, length returns a string with the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#sub with pattern, replacement handles a pattern in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#valid_encoding? returns true if self is valid in the current encoding and other encodings" # FrozenError: can't modify frozen String
end
