# NOTE: run bin/format-filters after changing this file
opal_filter "String" do
  fails "A singleton class has class String as the superclass of a String instance" # Exception: Cannot create property '$$meta' on string 'blah'
  fails "Ruby String interpolation creates a non-frozen String when # frozen-string-literal: true is used" # Expected "a42c".frozen? to be falsy but was true
  fails "Ruby String interpolation creates a non-frozen String" # Expected "a42c".frozen? to be falsy but was true
  fails "Ruby String interpolation permits an empty expression" # Expected "".frozen? to be falsy but was true
  fails "SimpleDelegator can be marshalled with its instance variables intact" # Exception: Cannot create property '$$meta' on string '__v2__'
  fails "String#% returns a String in the argument's encoding if format encoding is more restrictive" # FrozenError: can't modify frozen String
  fails "String#<=> with String ignores encoding difference" # FrozenError: can't modify frozen String
  fails "String#<=> with String returns 0 with identical ASCII-compatible bytes of different encodings" # FrozenError: can't modify frozen String
  fails "String#ascii_only? returns false for a non-empty String with non-ASCII-compatible encoding" # FrozenError: can't modify frozen String
  fails "String#ascii_only? returns false for the empty String with a non-ASCII-compatible encoding" # FrozenError: can't modify frozen String
  fails "String#ascii_only? returns false when interpolating non ascii strings" # FrozenError: can't modify frozen String
  fails "String#ascii_only? with ASCII only characters returns true if the encoding is US-ASCII" # FrozenError: can't modify frozen String
  fails "String#ascii_only? with non-ASCII only characters returns false if the encoding is US-ASCII" # FrozenError: can't modify frozen String
  fails "String#b returns a binary encoded string" # FrozenError: can't modify frozen String
  fails "String#bytes is unaffected by #force_encoding" # FrozenError: can't modify frozen String
  fails "String#bytesize returns 0 for the empty string" # FrozenError: can't modify frozen String
  fails "String#bytesize works with pseudo-ASCII strings containing UTF-8 characters" # FrozenError: can't modify frozen String
  fails "String#bytesize works with pseudo-ASCII strings containing single UTF-8 characters" # FrozenError: can't modify frozen String
  fails "String#clone copies frozen state" # Expected false to be true
  fails "String#gsub with pattern and replacement handles a pattern in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#index with String handles a substring in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#index with String handles a substring in a superset encoding" # FrozenError: can't modify frozen String
  fails "String#rindex with String handles a substring in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#rindex with String handles a substring in a superset encoding" # FrozenError: can't modify frozen String
  fails "String#sub with pattern, replacement handles a pattern in a subset encoding" # FrozenError: can't modify frozen String
  fails "String#valid_encoding? returns true if self is valid in the current encoding and other encodings" # FrozenError: can't modify frozen String
end
