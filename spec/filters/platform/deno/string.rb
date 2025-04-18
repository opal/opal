# NOTE: run bin/format-filters after changing this file
opal_filter "String" do
  fails "A singleton class has class String as the superclass of a String instance" # FrozenError: can't modify frozen String: 'blah'
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
  fails "String#center with length, padding with width returns a String in the same encoding as the original" # FrozenError: can't modify frozen String
  fails "String#chars returns characters in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#each_char returns characters in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#each_grapheme_cluster returns characters in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#encode when passed to encoding round trips a String" # FrozenError: can't modify frozen String
  fails "String#encoding for Strings with \\u escapes returns the given encoding if #force_encoding has been called" # FrozenError: can't modify frozen String
  fails "String#encoding returns the given encoding if #force_encoding has been called" # FrozenError: can't modify frozen String
  fails "String#force_encoding accepts a String as the name of an Encoding" # FrozenError: can't modify frozen String
  fails "String#force_encoding accepts an Encoding instance" # FrozenError: can't modify frozen String
  fails "String#force_encoding with a special encoding name accepts valid special encoding names" # FrozenError: can't modify frozen String
  fails "String#grapheme_clusters returns characters in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#gsub with pattern and replacement handles a pattern in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#include? with String returns true if both strings are empty" # FrozenError: can't modify frozen String
  fails "String#include? with String returns true if the RHS is empty" # FrozenError: can't modify frozen String
  fails "String#index with String handles a substring in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#index with String handles a substring in a superset encoding" # FrozenError: can't modify frozen String
  fails "String#ljust with length, padding with width returns a String in the same encoding as the original" # FrozenError: can't modify frozen String
  fails "String#partition with String handles a pattern in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#rindex with String handles a substring in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#rindex with String handles a substring in a superset encoding" # FrozenError: can't modify frozen String
  fails "String#rjust with length, padding with width returns a String in the same encoding as the original" # FrozenError: can't modify frozen String
  fails "String#rpartition with String handles a pattern in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#slice with index, length returns a string with the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#sub with pattern, replacement handles a pattern in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#valid_encoding? returns true if self is valid in the current encoding and other encodings" # FrozenError: can't modify frozen String
end
