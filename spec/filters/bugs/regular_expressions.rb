opal_filter "regular_expressions" do
  fails "Regexp.new works by default for subclasses with overridden #initialize"
  fails "Regexp.new given a String raises a RegexpError when passed an incorrect regexp"
  fails "Regexp.new given a String with escaped characters raises a RegexpError if \\x is not followed by any hexadecimal digits"
  fails "Regexp.new given a String with escaped characters accepts '\\C-\\n'"
  fails "Regexp.new given a String with escaped characters accepts '\\C-\\t'"
  fails "Regexp.new given a String with escaped characters accepts '\\C-\\r'"
  fails "Regexp.new given a String with escaped characters accepts '\\C-\\f'"
  fails "Regexp.new given a String with escaped characters accepts '\\C-\\v'"
  fails "Regexp.new given a String with escaped characters accepts '\\C-\\a'"
  fails "Regexp.new given a String with escaped characters accepts '\\C-\\e'"
  fails "Regexp.new given a String with escaped characters accepts '\\c\\n'"
  fails "Regexp.new given a String with escaped characters accepts '\\c\\t'"  
  fails "Regexp.new given a String with escaped characters accepts '\\c\\r'"
  fails "Regexp.new given a String with escaped characters accepts '\\c\\f'"
  fails "Regexp.new given a String with escaped characters accepts '\\c\\v'"
  fails "Regexp.new given a String with escaped characters accepts '\\c\\a'"
  fails "Regexp.new given a String with escaped characters accepts '\\c\\e'"  
  fails "Regexp.new given a String with escaped characters raises a RegexpError if more than six hexadecimal digits are given"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\n'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\t'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\r'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\f'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\v'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\a'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\e'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\C-\\n'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\C-\\t'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\C-\\r'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\C-\\f'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\C-\\v'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\C-\\a'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\C-\\e'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\c\\n'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\c\\t'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\c\\r'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\c\\f'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\c\\v'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\c\\a'"
  fails "Regexp.new given a String with escaped characters accepts '\\M-\\c\\e'"

  fails "Regexp#casefold? returns the value of the case-insensitive flag"
  fails "Regexp.compile requires one argument and creates a new regular expression object"
  fails "Regexp.compile works by default for subclasses with overridden #initialize"
  fails "Regexp.compile requires one argument and creates a new regular expression object"
  fails "Regexp.compile works by default for subclasses with overridden #initialize"
  fails "Regexp.compile given a String uses the String argument as an unescaped literal to construct a Regexp object"
  fails "Regexp.compile given a String raises a RegexpError when passed an incorrect regexp"
  fails "Regexp.compile given a String does not set Regexp options if only given one argument"
  fails "Regexp.compile given a String does not set Regexp options if second argument is nil or false"
  fails "Regexp.compile given a String sets options from second argument if it is one of the Fixnum option constants"
  fails "Regexp.compile given a String accepts a Fixnum of two or more options ORed together as the second argument"
  fails "Regexp.compile given a String treats any non-Fixnum, non-nil, non-false second argument as IGNORECASE"
  fails "Regexp.compile given a String ignores the third argument if it is 'e' or 'euc' (case-insensitive)"
  fails "Regexp.compile given a String ignores the third argument if it is 's' or 'sjis' (case-insensitive)"
  fails "Regexp.compile given a String ignores the third argument if it is 'u' or 'utf8' (case-insensitive)"
  fails "Regexp.compile given a String uses US_ASCII encoding if third argument is 'n' or 'none' (case insensitive) and only ascii characters"
  fails "Regexp.compile given a String uses ASCII_8BIT encoding if third argument is 'n' or 'none' (case insensitive) and non-ascii characters"
  fails "Regexp.compile given a String uses the String argument as an unescaped literal to construct a Regexp object"
  fails "Regexp.compile given a String raises a RegexpError when passed an incorrect regexp"
  fails "Regexp.compile given a String does not set Regexp options if only given one argument"
  fails "Regexp.compile given a String does not set Regexp options if second argument is nil or false"
  fails "Regexp.compile given a String sets options from second argument if it is one of the Fixnum option constants"
  fails "Regexp.compile given a String accepts a Fixnum of two or more options ORed together as the second argument"
  fails "Regexp.compile given a String treats any non-Fixnum, non-nil, non-false second argument as IGNORECASE"
  fails "Regexp.compile given a String ignores the third argument if it is 'e' or 'euc' (case-insensitive)"
  fails "Regexp.compile given a String ignores the third argument if it is 's' or 'sjis' (case-insensitive)"
  fails "Regexp.compile given a String ignores the third argument if it is 'u' or 'utf8' (case-insensitive)"
  fails "Regexp.compile given a String uses US_ASCII encoding if third argument is 'n' or 'none' (case insensitive) and only ascii characters"
  fails "Regexp.compile given a String uses ASCII_8BIT encoding if third argument is 'n' or 'none' (case insensitive) and non-ascii characters"
  fails "Regexp.compile given a String with escaped characters raises a Regexp error if there is a trailing backslash"
  fails "Regexp.compile given a String with escaped characters accepts a backspace followed by a character"
  fails "Regexp.compile given a String with escaped characters accepts a one-digit octal value"
  fails "Regexp.compile given a String with escaped characters accepts a two-digit octal value"
  fails "Regexp.compile given a String with escaped characters accepts a one-digit hexadecimal value"
  fails "Regexp.compile given a String with escaped characters accepts a two-digit hexadecimal value"
  fails "Regexp.compile given a String with escaped characters interprets a digit following a two-digit hexadecimal value as a character"
  fails "Regexp.compile given a String with escaped characters raises a RegexpError if \\x is not followed by any hexadecimal digits"
  fails "Regexp.compile given a String with escaped characters accepts an escaped string interpolation"
  fails "Regexp.compile given a String with escaped characters accepts '\\n'"
  fails "Regexp.compile given a String with escaped characters accepts '\\t'"
  fails "Regexp.compile given a String with escaped characters accepts '\\r'"
  fails "Regexp.compile given a String with escaped characters accepts '\\f'"
  fails "Regexp.compile given a String with escaped characters accepts '\\v'"
  fails "Regexp.compile given a String with escaped characters accepts '\\a'"
  fails "Regexp.compile given a String with escaped characters accepts '\\e'"
  fails "Regexp.compile given a String with escaped characters accepts '\\C-\\n'"
  fails "Regexp.compile given a String with escaped characters accepts '\\C-\\t'"
  fails "Regexp.compile given a String with escaped characters accepts '\\C-\\r'"
  fails "Regexp.compile given a String with escaped characters accepts '\\C-\\f'"
  fails "Regexp.compile given a String with escaped characters accepts '\\C-\\v'"
  fails "Regexp.compile given a String with escaped characters accepts '\\C-\\a'"
  fails "Regexp.compile given a String with escaped characters accepts '\\C-\\e'"
  fails "Regexp.compile given a String with escaped characters accepts '\\c\\n'"
  fails "Regexp.compile given a String with escaped characters accepts '\\c\\t'"
  fails "Regexp.compile given a String with escaped characters accepts '\\c\\r'"
  fails "Regexp.compile given a String with escaped characters accepts '\\c\\f'"
  fails "Regexp.compile given a String with escaped characters accepts '\\c\\v'"
  fails "Regexp.compile given a String with escaped characters accepts '\\c\\a'"
  fails "Regexp.compile given a String with escaped characters accepts '\\c\\e'"
  fails "Regexp.compile given a String with escaped characters accepts multiple consecutive '\\' characters"
  fails "Regexp.compile given a String with escaped characters accepts characters and escaped octal digits"
  fails "Regexp.compile given a String with escaped characters accepts escaped octal digits and characters"
  fails "Regexp.compile given a String with escaped characters accepts characters and escaped hexadecimal digits"
  fails "Regexp.compile given a String with escaped characters accepts escaped hexadecimal digits and characters"
  fails "Regexp.compile given a String with escaped characters accepts escaped hexadecimal and octal digits"
  fails "Regexp.compile given a String with escaped characters accepts \\u{H} for a single Unicode codepoint"
  fails "Regexp.compile given a String with escaped characters accepts \\u{HH} for a single Unicode codepoint"
  fails "Regexp.compile given a String with escaped characters accepts \\u{HHH} for a single Unicode codepoint"
  fails "Regexp.compile given a String with escaped characters accepts \\u{HHHH} for a single Unicode codepoint"
  fails "Regexp.compile given a String with escaped characters accepts \\u{HHHHH} for a single Unicode codepoint"
  fails "Regexp.compile given a String with escaped characters accepts \\u{HHHHHH} for a single Unicode codepoint"
  fails "Regexp.compile given a String with escaped characters accepts characters followed by \\u{HHHH}"
  fails "Regexp.compile given a String with escaped characters accepts \\u{HHHH} followed by characters"
  fails "Regexp.compile given a String with escaped characters accepts escaped hexadecimal digits followed by \\u{HHHH}"
  fails "Regexp.compile given a String with escaped characters accepts escaped octal digits followed by \\u{HHHH}"
  fails "Regexp.compile given a String with escaped characters accepts a combination of escaped octal and hexadecimal digits and \\u{HHHH}"
  fails "Regexp.compile given a String with escaped characters accepts \\uHHHH for a single Unicode codepoint"
  fails "Regexp.compile given a String with escaped characters accepts characters followed by \\uHHHH"
  fails "Regexp.compile given a String with escaped characters accepts \\uHHHH followed by characters"
  fails "Regexp.compile given a String with escaped characters accepts escaped hexadecimal digits followed by \\uHHHH"
  fails "Regexp.compile given a String with escaped characters accepts escaped octal digits followed by \\uHHHH"
  fails "Regexp.compile given a String with escaped characters accepts a combination of escaped octal and hexadecimal digits and \\uHHHH"
  fails "Regexp.compile given a String with escaped characters raises a RegexpError if less than four digits are given for \\uHHHH"
  fails "Regexp.compile given a String with escaped characters raises a RegexpError if the \\u{} escape is empty"
  fails "Regexp.compile given a String with escaped characters raises a RegexpError if more than six hexadecimal digits are given"
  fails "Regexp.compile given a String with escaped characters returns a Regexp with US-ASCII encoding if only 7-bit ASCII characters are present regardless of the input String's encoding"
  fails "Regexp.compile given a String with escaped characters returns a Regexp with source String having US-ASCII encoding if only 7-bit ASCII characters are present regardless of the input String's encoding"
  fails "Regexp.compile given a String with escaped characters returns a Regexp with US-ASCII encoding if UTF-8 escape sequences using only 7-bit ASCII are present"
  fails "Regexp.compile given a String with escaped characters returns a Regexp with source String having US-ASCII encoding if UTF-8 escape sequences using only 7-bit ASCII are present"
  fails "Regexp.compile given a String with escaped characters returns a Regexp with UTF-8 encoding if any UTF-8 escape sequences outside 7-bit ASCII are present"
  fails "Regexp.compile given a String with escaped characters returns a Regexp with source String having UTF-8 encoding if any UTF-8 escape sequences outside 7-bit ASCII are present"
  fails "Regexp.compile given a String with escaped characters returns a Regexp with the input String's encoding"
  fails "Regexp.compile given a String with escaped characters returns a Regexp with source String having the input String's encoding"
  fails "Regexp.compile given a String with escaped characters raises a Regexp error if there is a trailing backslash"
  fails "Regexp.compile given a String with escaped characters accepts a backspace followed by a character"
  fails "Regexp.compile given a String with escaped characters accepts a one-digit octal value"
  fails "Regexp.compile given a String with escaped characters accepts a two-digit octal value"
  fails "Regexp.compile given a String with escaped characters accepts a three-digit octal value"
  fails "Regexp.compile given a String with escaped characters interprets a digit following a three-digit octal value as a character"
  fails "Regexp.compile given a String with escaped characters accepts a one-digit hexadecimal value"
  fails "Regexp.compile given a String with escaped characters accepts a two-digit hexadecimal value"
  fails "Regexp.compile given a String with escaped characters interprets a digit following a two-digit hexadecimal value as a character"
  fails "Regexp.compile given a String with escaped characters raises a RegexpError if \\x is not followed by any hexadecimal digits"
  fails "Regexp.compile given a String with escaped characters accepts an escaped string interpolation"
  fails "Regexp.compile given a String with escaped characters accepts '\\n'"
  fails "Regexp.compile given a String with escaped characters accepts '\\t'"
  fails "Regexp.compile given a String with escaped characters accepts '\\r'"
  fails "Regexp.compile given a String with escaped characters accepts '\\f'"
  fails "Regexp.compile given a String with escaped characters accepts '\\v'"
  fails "Regexp.compile given a String with escaped characters accepts '\\a'"
  fails "Regexp.compile given a String with escaped characters accepts '\\e'"
  fails "Regexp.compile given a String with escaped characters accepts '\\C-\\n'"
  fails "Regexp.compile given a String with escaped characters accepts '\\C-\\t'"
  fails "Regexp.compile given a String with escaped characters accepts '\\C-\\r'"
  fails "Regexp.compile given a String with escaped characters accepts '\\C-\\f'"
  fails "Regexp.compile given a String with escaped characters accepts '\\C-\\v'"
  fails "Regexp.compile given a String with escaped characters accepts '\\C-\\a'"
  fails "Regexp.compile given a String with escaped characters accepts '\\C-\\e'"
  fails "Regexp.compile given a String with escaped characters accepts '\\c\\n'"
  fails "Regexp.compile given a String with escaped characters accepts '\\c\\t'"
  fails "Regexp.compile given a String with escaped characters accepts '\\c\\r'"
  fails "Regexp.compile given a String with escaped characters accepts '\\c\\f'"
  fails "Regexp.compile given a String with escaped characters accepts '\\c\\v'"
  fails "Regexp.compile given a String with escaped characters accepts '\\c\\a'"
  fails "Regexp.compile given a String with escaped characters accepts '\\c\\e'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\n'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\t'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\r'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\f'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\v'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\a'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\e'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\C-\\n'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\C-\\t'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\C-\\r'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\C-\\f'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\C-\\v'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\C-\\a'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\C-\\e'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\c\\n'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\c\\t'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\c\\r'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\c\\f'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\c\\v'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\c\\a'"
  fails "Regexp.compile given a String with escaped characters accepts '\\M-\\c\\e'"
  fails "Regexp.compile given a String with escaped characters accepts multiple consecutive '\\' characters"
  fails "Regexp.compile given a String with escaped characters accepts characters and escaped octal digits"
  fails "Regexp.compile given a String with escaped characters accepts escaped octal digits and characters"
  fails "Regexp.compile given a String with escaped characters accepts characters and escaped hexadecimal digits"
  fails "Regexp.compile given a String with escaped characters accepts escaped hexadecimal digits and characters"
  fails "Regexp.compile given a String with escaped characters accepts escaped hexadecimal and octal digits"
  fails "Regexp.compile given a String with escaped characters accepts \\u{H} for a single Unicode codepoint"
  fails "Regexp.compile given a String with escaped characters accepts \\u{HH} for a single Unicode codepoint"
  fails "Regexp.compile given a String with escaped characters accepts \\u{HHH} for a single Unicode codepoint"
  fails "Regexp.compile given a String with escaped characters accepts \\u{HHHH} for a single Unicode codepoint"
  fails "Regexp.compile given a String with escaped characters accepts \\u{HHHHH} for a single Unicode codepoint"
  fails "Regexp.compile given a String with escaped characters accepts \\u{HHHHHH} for a single Unicode codepoint"
  fails "Regexp.compile given a String with escaped characters accepts characters followed by \\u{HHHH}"
  fails "Regexp.compile given a String with escaped characters accepts \\u{HHHH} followed by characters"
  fails "Regexp.compile given a String with escaped characters accepts escaped hexadecimal digits followed by \\u{HHHH}"
  fails "Regexp.compile given a String with escaped characters accepts escaped octal digits followed by \\u{HHHH}"
  fails "Regexp.compile given a String with escaped characters accepts a combination of escaped octal and hexadecimal digits and \\u{HHHH}"
  fails "Regexp.compile given a String with escaped characters accepts \\uHHHH for a single Unicode codepoint"
  fails "Regexp.compile given a String with escaped characters accepts characters followed by \\uHHHH"
  fails "Regexp.compile given a String with escaped characters accepts \\uHHHH followed by characters"
  fails "Regexp.compile given a String with escaped characters accepts escaped hexadecimal digits followed by \\uHHHH"
  fails "Regexp.compile given a String with escaped characters accepts escaped octal digits followed by \\uHHHH"
  fails "Regexp.compile given a String with escaped characters accepts a combination of escaped octal and hexadecimal digits and \\uHHHH"
  fails "Regexp.compile given a String with escaped characters raises a RegexpError if less than four digits are given for \\uHHHH"
  fails "Regexp.compile given a String with escaped characters raises a RegexpError if the \\u{} escape is empty"
  fails "Regexp.compile given a String with escaped characters raises a RegexpError if more than six hexadecimal digits are given"
  fails "Regexp.compile given a String with escaped characters returns a Regexp with US-ASCII encoding if only 7-bit ASCII characters are present regardless of the input String's encoding"
  fails "Regexp.compile given a String with escaped characters returns a Regexp with source String having US-ASCII encoding if only 7-bit ASCII characters are present regardless of the input String's encoding"
  fails "Regexp.compile given a String with escaped characters returns a Regexp with US-ASCII encoding if UTF-8 escape sequences using only 7-bit ASCII are present"
  fails "Regexp.compile given a String with escaped characters returns a Regexp with source String having US-ASCII encoding if UTF-8 escape sequences using only 7-bit ASCII are present"
  fails "Regexp.compile given a String with escaped characters returns a Regexp with UTF-8 encoding if any UTF-8 escape sequences outside 7-bit ASCII are present"
  fails "Regexp.compile given a String with escaped characters returns a Regexp with source String having UTF-8 encoding if any UTF-8 escape sequences outside 7-bit ASCII are present"
  fails "Regexp.compile given a String with escaped characters returns a Regexp with the input String's encoding"
  fails "Regexp.compile given a String with escaped characters returns a Regexp with source String having the input String's encoding"
  fails "Regexp.compile given a Regexp uses the argument as a literal to construct a Regexp object"
  fails "Regexp.compile given a Regexp preserves any options given in the Regexp literal"
  fails "Regexp.compile given a Regexp does not honour options given as additional arguments"
  fails "Regexp.compile given a Regexp uses the argument as a literal to construct a Regexp object"
  fails "Regexp.compile given a Regexp preserves any options given in the Regexp literal"
  fails "Regexp.compile given a Regexp does not honour options given as additional arguments"
  fails "Regexp#hash is based on the text and options of Regexp"
  fails "Regexp#hash returns the same value for two Regexps differing only in the /n option"
  fails "Regexp#initialize is a private method"
  fails "Regexp#initialize raises a SecurityError on a Regexp literal"
  fails "Regexp#initialize raises a TypeError on an initialized non-literal Regexp"
  fails "Regexp#inspect returns a formatted string that would eval to the same regexp"
  fails "Regexp#inspect returns options in the order 'mixn'"
  fails "Regexp#inspect does not include the 'o' option"
  fails "Regexp#inspect does not include a character set code"
  fails "Regexp#inspect correctly escapes forward slashes /"
  fails "Regexp#inspect escapes 2 slashes in a row properly"
  fails "Regexp#inspect does not over escape"
  fails "Regexp#source returns the original string of the pattern"
  fails "Regexp#to_s displays options if included"
  fails "Regexp#to_s shows non-included options after a - sign"
  fails "Regexp#to_s shows all options as excluded if none are selected"
  fails "Regexp#to_s shows the pattern after the options"
  fails "Regexp#to_s displays groups with options"
  fails "Regexp#to_s displays single group with same options as main regex as the main regex"
  fails "Regexp#to_s deals properly with uncaptured groups"
  fails "Regexp#to_s deals properly with the two types of lookahead groups"
  fails "Regexp#to_s returns a string in (?xxx:yyy) notation"
  fails "Regexp#to_s handles abusive option groups"
  fails "Regexp.try_convert returns the argument if given a Regexp"
  fails "Regexp.try_convert returns nil if given an argument that can't be converted to a Regexp"
  fails "Regexp.try_convert tries to coerce the argument by calling #to_regexp"
end
