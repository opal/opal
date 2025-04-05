# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "MatchData" do
  fails "MatchData#[Symbol] returns matches in the String's encoding" # ArgumentError: unknown encoding name - euc-jp
  fails "MatchData#[Symbol] returns the last match when multiple named matches exist with the same name" # Exception: Invalid regular expression: /(?<word>hay)(?<word>stack)/: Duplicate capture group name
  fails "MatchData#[Symbol] returns the matching version of multiple corresponding named match" # Exception: Invalid regular expression: /(?:A(?<word>\w+)|B(?<word>\w+))/: Duplicate capture group name
  fails "MatchData#begin when passed a String argument return the character offset of the start of the named capture" # ArgumentError: MatchData#begin only supports 0th element
  fails "MatchData#begin when passed a String argument returns the character offset for multi byte strings" # ArgumentError: MatchData#begin only supports 0th element
  fails "MatchData#begin when passed a String argument returns the character offset for multi-byte names" # ArgumentError: MatchData#begin only supports 0th element
  fails "MatchData#begin when passed a String argument returns the character offset for the farthest match when multiple named captures use the same name" # Exception: Invalid regular expression: /(?<a>.)(.)(?<a>\d+)(\d)/: Duplicate capture group name
  fails "MatchData#begin when passed a Symbol argument return the character offset of the start of the named capture" # ArgumentError: MatchData#begin only supports 0th element
  fails "MatchData#begin when passed a Symbol argument returns the character offset for multi byte strings" # ArgumentError: MatchData#begin only supports 0th element
  fails "MatchData#begin when passed a Symbol argument returns the character offset for multi-byte names" # ArgumentError: MatchData#begin only supports 0th element
  fails "MatchData#begin when passed a Symbol argument returns the character offset for the farthest match when multiple named captures use the same name" # Exception: Invalid regular expression: /(?<a>.)(.)(?<a>\d+)(\d)/: Duplicate capture group name
  fails "MatchData#begin when passed an integer argument returns nil when the nth match isn't found" # ArgumentError: MatchData#begin only supports 0th element
  fails "MatchData#begin when passed an integer argument returns the character offset for multi-byte strings" # ArgumentError: MatchData#begin only supports 0th element
  fails "MatchData#begin when passed an integer argument returns the character offset of the start of the nth element" # ArgumentError: MatchData#begin only supports 0th element
  fails "MatchData#begin when passed an integer argument tries to convert the passed argument to an Integer using #to_int" # ArgumentError: MatchData#begin only supports 0th element
  fails "MatchData#end when passed a String argument return the character offset of the start of the named capture" # ArgumentError: MatchData#end only supports 0th element
  fails "MatchData#end when passed a String argument returns the character offset for multi byte strings" # ArgumentError: MatchData#end only supports 0th element
  fails "MatchData#end when passed a String argument returns the character offset for multi-byte names" # ArgumentError: MatchData#end only supports 0th element
  fails "MatchData#end when passed a String argument returns the character offset for the farthest match when multiple named captures use the same name" # Exception: Invalid regular expression: /(?<a>.)(.)(?<a>\d+)(\d)/: Duplicate capture group name
  fails "MatchData#end when passed a Symbol argument return the character offset of the start of the named capture" # ArgumentError: MatchData#end only supports 0th element
  fails "MatchData#end when passed a Symbol argument returns the character offset for multi byte strings" # ArgumentError: MatchData#end only supports 0th element
  fails "MatchData#end when passed a Symbol argument returns the character offset for multi-byte names" # ArgumentError: MatchData#end only supports 0th element
  fails "MatchData#end when passed a Symbol argument returns the character offset for the farthest match when multiple named captures use the same name" # Exception: Invalid regular expression: /(?<a>.)(.)(?<a>\d+)(\d)/: Duplicate capture group name
  fails "MatchData#end when passed an integer argument returns nil when the nth match isn't found" # ArgumentError: MatchData#end only supports 0th element
  fails "MatchData#end when passed an integer argument returns the character offset for multi-byte strings" # ArgumentError: MatchData#end only supports 0th element
  fails "MatchData#end when passed an integer argument returns the character offset of the end of the nth element" # ArgumentError: MatchData#end only supports 0th element
  fails "MatchData#end when passed an integer argument tries to convert the passed argument to an Integer using #to_int" # ArgumentError: MatchData#end only supports 0th element
  fails "MatchData#named_captures prefers later captures" # Exception: Invalid regular expression: /^(?<a>.)(?<b>.)(?<b>.)(?<a>.)$/: Duplicate capture group name
  fails "MatchData#named_captures returns the latest matched capture, even if a later one that does not match exists" # Exception: Invalid regular expression: /^(?<a>.)(?<b>.)(?<b>.)(?<a>.)?$/: Duplicate capture group name
  fails "MatchData#names equals Regexp#names" # Exception: Invalid regular expression: /(?<hay>hay)(?<dot>.)(?<hay>tack)/: Duplicate capture group name
  fails "MatchData#names returns each name only once" # Exception: Invalid regular expression: /(?<hay>hay)(?<dot>.)(?<hay>tack)/: Duplicate capture group name
  fails "MatchData#offset returns [nil, nil] when the nth match isn't found" # ArgumentError: MatchData#offset only supports 0th element
  fails "MatchData#offset returns a two element array with the begin and end of the nth match" # ArgumentError: MatchData#offset only supports 0th element
  fails "MatchData#offset returns the offset for multi byte strings" # ArgumentError: MatchData#offset only supports 0th element
  fails "MatchData#values_at slices captures with the given names" # TypeError: no implicit conversion of String into Integer
  fails "MatchData#values_at takes names and indices" # TypeError: no implicit conversion of String into Integer
end
