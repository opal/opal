opal_filter "Encoding" do
  fails "Array#inspect raises if inspected result is not default external encoding"
  fails "Array#inspect use US-ASCII encoding if the default external encoding is not ascii compatible"
  fails "Array#inspect use the default external encoding if it is ascii compatible"
  fails "Array#inspect returns a US-ASCII string for an empty Array"
  fails "Array#inspect with encoding returns a US-ASCII string for an empty Array"
  fails "Array#inspect with encoding use the default external encoding if it is ascii compatible"
  fails "Array#inspect with encoding use US-ASCII encoding if the default external encoding is not ascii compatible"
  fails "Array#inspect with encoding raises if inspected result is not default external encoding"

  fails "Array#join fails for arrays with incompatibly-encoded strings"
  fails "Array#join uses the widest common encoding when other strings are incompatible"
  fails "Array#join uses the first encoding when other strings are compatible"
  fails "Array#join returns a US-ASCII string for an empty Array"

  fails "Array#to_s raises if inspected result is not default external encoding"
  fails "Array#to_s returns a US-ASCII string for an empty Array"
  fails "Array#to_s use US-ASCII encoding if the default external encoding is not ascii compatible"
  fails "Array#to_s use the default external encoding if it is ascii compatible"
  fails "Array#to_s with encoding raises if inspected result is not default external encoding"
  fails "Array#to_s with encoding returns a US-ASCII string for an empty Array"
  fails "Array#to_s with encoding use US-ASCII encoding if the default external encoding is not ascii compatible"
  fails "Array#to_s with encoding use the default external encoding if it is ascii compatible"

  fails "String#== ignores encoding difference of compatible string"
  fails "String#== considers encoding difference of incompatible string"
  fails "String#== considers encoding compatibility"

  fails "String#=== ignores encoding difference of compatible string"
  fails "String#=== considers encoding difference of incompatible string"
  fails "String#=== considers encoding compatibility"

  fails "String#<=> with String returns -1 if self is bytewise less than other"
  fails "String#<=> with String returns 1 if self is bytewise greater than other"
  fails "String#<=> with String returns 0 if self and other contain identical ASCII-compatible bytes in different encodings"
  fails "String#<=> with String returns 0 with identical ASCII-compatible bytes of different encodings"
  fails "String#<=> with String does not return 0 if self and other contain identical non-ASCII-compatible bytes in different encodings"
  fails "String#<=> with String compares the indices of the encodings when the strings have identical non-ASCII-compatible bytes"
  fails "String#<=> with String ignores encoding difference"

  fails "String.allocate returns a fully-formed String"
  fails "String.allocate returns a binary String"

  fails "String#capitalize is locale insensitive (only upcases a-z and only downcases A-Z)"

  fails "String#chars is unicode aware"

  fails "String#count returns the number of occurrences of a multi-byte character"

  fails "String#downcase is locale insensitive (only replaces A-Z)"

  fails "String#each_char is unicode aware"

  fails "String#eql? ignores encoding difference of compatible string"
  fails "String#eql? considers encoding difference of incompatible string"
  fails "String#eql? considers encoding compatibility"

  fails "String#gsub with pattern and block uses the compatible encoding if they are compatible"
  fails "String#gsub with pattern and block raises an Encoding::CompatibilityError if the encodings are not compatible"
  fails "String#gsub with pattern and block replaces the incompatible part properly even if the encodings are not compatible"

  fails "String#initialize with an argument carries over the encoding invalidity"

  fails "String#replace carries over the encoding invalidity"

  fails "String#split with Regexp retains the encoding of the source string"
  fails "String#split with Regexp returns an ArgumentError if an invalid UTF-8 string is supplied"
  fails "String#split with Regexp respects the encoding of the regexp when splitting between characters"
  fails "String#split with Regexp splits a string on each character for a multibyte encoding and empty split"

  fails "String#upcase is locale insensitive (only replaces a-z)"

  fails "The defined? keyword for pseudo-variables returns 'expression' for __ENCODING__"

  # language/magic_comment_spec
  fails "Magic comment can take vim style"
  fails "Magic comment can take Emacs style"
  fails "Magic comment can be after the shebang"
  fails "Magic comment must be the first token of the line"
  fails "Magic comment must be at the first line"
  fails "Magic comment is case-insensitive"
  fails "Magic comment determines __ENCODING__"
end

opal_filter "Regexp.escape" do
  fails "Regexp.escape sets the encoding of the result to US-ASCII if there are only US-ASCII characters present in the input String"
  fails "Regexp.escape sets the encoding of the result to the encoding of the String if any non-US-ASCII characters are present in an input String with valid encoding"
  fails "Regexp.escape sets the encoding of the result to ASCII-8BIT if any non-US-ASCII characters are present in an input String with invalid encoding"
end

opal_filter "Regexp.quote" do
  fails "Regexp.quote sets the encoding of the result to US-ASCII if there are only US-ASCII characters present in the input String"
  fails "Regexp.quote sets the encoding of the result to the encoding of the String if any non-US-ASCII characters are present in an input String with valid encoding"
  fails "Regexp.quote sets the encoding of the result to ASCII-8BIT if any non-US-ASCII characters are present in an input String with invalid encoding"
end
