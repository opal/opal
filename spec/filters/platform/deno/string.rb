# NOTE: run bin/format-filters after changing this file
opal_filter "String" do
  fails "A singleton class has class String as the superclass of a String instance" # Exception: Cannot create property '$$meta' on string 'blah'
  fails "Ruby String interpolation creates a non-frozen String when # frozen-string-literal: true is used" # Expected "a42c".frozen? to be falsy but was true
  fails "Ruby String interpolation creates a non-frozen String" # Expected "a42c".frozen? to be falsy but was true
  fails "SimpleDelegator can be marshalled with its instance variables intact" # Exception: Cannot create property '$$meta' on string '__v2__'
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
  fails "String#dump returns a string with non-printing ASCII characters replaced by \\x notation" # FrozenError: can't modify frozen String
  fails "String#each_char returns characters in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#each_grapheme_cluster returns characters in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#each_line returns Strings in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#encode when passed no options encodes an ascii substring of a binary string to UTF-8" # FrozenError: can't modify frozen String
  fails "String#encode when passed to encoding round trips a String" # FrozenError: can't modify frozen String
  fails "String#encoding for Strings with \\u escapes returns the given encoding if #force_encoding has been called" # FrozenError: can't modify frozen String
  fails "String#encoding returns the given encoding if #force_encoding has been called" # FrozenError: can't modify frozen String
  fails "String#force_encoding accepts a String as the name of an Encoding" # FrozenError: can't modify frozen String
  fails "String#force_encoding accepts an Encoding instance" # FrozenError: can't modify frozen String
  fails "String#grapheme_clusters returns characters in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#gsub with pattern and replacement handles a pattern in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#include? with String returns true if both strings are empty" # FrozenError: can't modify frozen String
  fails "String#include? with String returns true if the RHS is empty" # FrozenError: can't modify frozen String
  fails "String#index with String handles a substring in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#index with String handles a substring in a superset encoding" # FrozenError: can't modify frozen String
  fails "String#lines returns Strings in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#ljust with length, padding with width returns a String in the same encoding as the original" # FrozenError: can't modify frozen String
  fails "String#ljust with length, padding with width, pattern returns a String in the compatible encoding" # FrozenError: can't modify frozen String
  fails "String#next adds an additional character (just left to the last increased one) if there is a carry and no character left to increase" # FrozenError: can't modify frozen String
  fails "String#next increases non-alphanumerics (via ascii rules) if there are no alphanumerics" # FrozenError: can't modify frozen String
  fails "String#next increases the next best alphanumeric (jumping over non-alphanumerics) if there is a carry" # FrozenError: can't modify frozen String
  fails "String#next increases the next best character if there is a carry for non-alphanumerics" # FrozenError: can't modify frozen String
  fails "String#next returns a String in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#next returns the successor by increasing the rightmost alphanumeric (digit => digit, letter => letter with same case)" # FrozenError: can't modify frozen String
  fails "String#partition with String handles a pattern in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#partition with String returns before- and after- parts in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#partition with String returns the matching part in the separator's encoding" # FrozenError: can't modify frozen String
  fails "String#reverse returns a String in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#rindex with String handles a substring in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#rindex with String handles a substring in a superset encoding" # FrozenError: can't modify frozen String
  fails "String#rjust with length, padding with width returns a String in the same encoding as the original" # FrozenError: can't modify frozen String
  fails "String#rjust with length, padding with width, pattern returns a String in the compatible encoding" # FrozenError: can't modify frozen String
  fails "String#rpartition with String handles a pattern in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#rpartition with String returns before- and after- parts in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#rpartition with String returns the matching part in the separator's encoding" # FrozenError: can't modify frozen String
  fails "String#rstrip returns a String in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#scan returns Strings in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#scrub with a default replacement returns a copy of self when the input encoding is BINARY" # FrozenError: can't modify frozen String
  fails "String#slice with index, length returns a string with the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#split with Regexp returns Strings in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#split with String returns Strings in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#squeeze negates sets starting with ^" # FrozenError: can't modify frozen String
  fails "String#squeeze only squeezes chars that are in the intersection of all sets given" # FrozenError: can't modify frozen String
  fails "String#squeeze returns a String in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#squeeze returns new string where runs of the same character are replaced by a single character when no args are given" # FrozenError: can't modify frozen String
  fails "String#squeeze squeezes all chars in a sequence" # FrozenError: can't modify frozen String
  fails "String#squeeze tries to convert each set arg to a string using to_str" # FrozenError: can't modify frozen String
  fails "String#strip returns a String in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#sub with pattern, replacement handles a pattern in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#succ adds an additional character (just left to the last increased one) if there is a carry and no character left to increase" # FrozenError: can't modify frozen String
  fails "String#succ increases non-alphanumerics (via ascii rules) if there are no alphanumerics" # FrozenError: can't modify frozen String
  fails "String#succ increases the next best alphanumeric (jumping over non-alphanumerics) if there is a carry" # FrozenError: can't modify frozen String
  fails "String#succ increases the next best character if there is a carry for non-alphanumerics" # FrozenError: can't modify frozen String
  fails "String#succ returns a String in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#succ returns the successor by increasing the rightmost alphanumeric (digit => digit, letter => letter with same case)" # FrozenError: can't modify frozen String
  fails "String#swapcase returns a String in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#upcase returns a String in the same encoding as self" # FrozenError: can't modify frozen String
  fails "String#valid_encoding? returns false if self is valid in one encoding, but invalid in the one it's tagged with" # FrozenError: can't modify frozen String
  fails "String#valid_encoding? returns true if self is valid in the current encoding and other encodings" # FrozenError: can't modify frozen String
end
