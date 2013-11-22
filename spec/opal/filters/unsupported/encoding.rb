opal_filter "Encoding" do
  fails "Array#inspect raises if inspected result is not default external encoding"
  fails "Array#inspect use US-ASCII encoding if the default external encoding is not ascii compatible"
  fails "Array#inspect use the default external encoding if it is ascii compatible"
  fails "Array#inspect returns a US-ASCII string for an empty Array"

  fails "Array#join fails for arrays with incompatibly-encoded strings"
  fails "Array#join uses the widest common encoding when other strings are incompatible"
  fails "Array#join uses the first encoding when other strings are compatible"
  fails "Array#join returns a US-ASCII string for an empty Array"

  fails "Array#to_s raises if inspected result is not default external encoding"
  fails "Array#to_s use US-ASCII encoding if the default external encoding is not ascii compatible"
  fails "Array#to_s use the default external encoding if it is ascii compatible"
  fails "Array#to_s returns a US-ASCII string for an empty Array"

  fails "String#<=> with String returns -1 if self is bytewise less than other"
  fails "String#<=> with String returns 1 if self is bytewise greater than other"
  fails "String#<=> with String returns 0 if self and other contain identical ASCII-compatible bytes in different encodings"
  fails "String#<=> with String does not return 0 if self and other contain identical non-ASCII-compatible bytes in different encodings"

  fails "String.allocate returns a fully-formed String"
  fails "String.allocate returns a binary String"

  fails "String#capitalize is locale insensitive (only upcases a-z and only downcases A-Z)"

  fails "String#chars is unicode aware"

  fails "String#downcase is locale insensitive (only replaces A-Z)"

  fails "String#each_char is unicode aware"

  fails "String#gsub with pattern and block uses the compatible encoding if they are compatible"
  fails "String#gsub with pattern and block raises an Encoding::CompatibilityError if the encodings are not compatible"
  fails "String#gsub with pattern and block replaces the incompatible part properly even if the encodings are not compatible"

  fails "String#split with Regexp retains the encoding of the source string"
  fails "String#split with Regexp returns an ArgumentError if an invalid UTF-8 string is supplied"

  fails "String#upcase is locale insensitive (only replaces a-z)"
end
