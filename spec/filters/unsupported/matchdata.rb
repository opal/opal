opal_unsupported_filter "MatchData" do
  fails "MatchData#[Symbol] raises an IndexError if there is no named match corresponding to the String"
  fails "MatchData#[Symbol] raises an IndexError if there is no named match corresponding to the Symbol"
  fails "MatchData#[Symbol] returns matches in the String's encoding"
  fails "MatchData#[Symbol] returns nil on non-matching named matches"
  fails "MatchData#[Symbol] returns the corresponding named match when given a String"
  fails "MatchData#[Symbol] returns the corresponding named match when given a Symbol"
  fails "MatchData#[Symbol] returns the last match when multiple named matches exist with the same name"
  fails "MatchData#[Symbol] returns the matching version of multiple corresponding named match"
  fails "MatchData#begin returns nil when the nth match isn't found"
  fails "MatchData#begin returns the offset for multi byte strings with unicode regexp"
  fails "MatchData#begin returns the offset for multi byte strings"
  fails "MatchData#begin returns the offset of the start of the nth element"
  fails "MatchData#begin when passed a String argument return the character offset of the start of the named capture" # Exception: named captures are not supported in javascript: "(?<a>.)(.)(?<b>\d+)(\d)"
  fails "MatchData#begin when passed a String argument returns the character offset for multi byte strings" # Exception: named captures are not supported in javascript: "(?<a>.)(.)(?<b>\d+)(\d)"
  fails "MatchData#begin when passed a String argument returns the character offset for multi-byte names" # Exception: named captures are not supported in javascript: "(?<æ>.)(.)(?<b>\d+)(\d)"
  fails "MatchData#begin when passed a String argument returns the character offset for the farthest match when multiple named captures use the same name" # Exception: named captures are not supported in javascript: "(?<a>.)(.)(?<a>\d+)(\d)"
  fails "MatchData#begin when passed a Symbol argument return the character offset of the start of the named capture" # Exception: named captures are not supported in javascript: "(?<a>.)(.)(?<b>\d+)(\d)"
  fails "MatchData#begin when passed a Symbol argument returns the character offset for multi byte strings" # Exception: named captures are not supported in javascript: "(?<a>.)(.)(?<b>\d+)(\d)"
  fails "MatchData#begin when passed a Symbol argument returns the character offset for multi-byte names" # Exception: named captures are not supported in javascript: "(?<æ>.)(.)(?<b>\d+)(\d)"
  fails "MatchData#begin when passed a Symbol argument returns the character offset for the farthest match when multiple named captures use the same name" # Exception: named captures are not supported in javascript: "(?<a>.)(.)(?<a>\d+)(\d)"
  fails "MatchData#begin when passed an integer argument returns nil when the nth match isn't found" # ArgumentError: MatchData#begin only supports 0th element
  fails "MatchData#begin when passed an integer argument returns the character offset for multi-byte strings" # ArgumentError: MatchData#begin only supports 0th element
  fails "MatchData#begin when passed an integer argument returns the character offset of the start of the nth element" # ArgumentError: MatchData#begin only supports 0th element
  fails "MatchData#begin when passed an integer argument tries to convert the passed argument to an Integer using #to_int" # ArgumentError: MatchData#begin only supports 0th element
  fails "MatchData#begin when passed an integer argument tries to convert the passed argument to an Integer using #to_int" # Mock 'to_int' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "MatchData#end returns nil when the nth match isn't found"
  fails "MatchData#end returns the offset for multi byte strings with unicode regexp"
  fails "MatchData#end returns the offset for multi byte strings"
  fails "MatchData#end returns the offset of the end of the nth element"
  fails "MatchData#end when passed a String argument return the character offset of the start of the named capture" # Exception: named captures are not supported in javascript: "(?<a>.)(.)(?<b>\d+)(\d)"
  fails "MatchData#end when passed a String argument returns the character offset for multi byte strings" # Exception: named captures are not supported in javascript: "(?<a>.)(.)(?<b>\d+)(\d)"
  fails "MatchData#end when passed a String argument returns the character offset for multi-byte names" # Exception: named captures are not supported in javascript: "(?<æ>.)(.)(?<b>\d+)(\d)"
  fails "MatchData#end when passed a String argument returns the character offset for the farthest match when multiple named captures use the same name" # Exception: named captures are not supported in javascript: "(?<a>.)(.)(?<a>\d+)(\d)"
  fails "MatchData#end when passed a Symbol argument return the character offset of the start of the named capture" # Exception: named captures are not supported in javascript: "(?<a>.)(.)(?<b>\d+)(\d)"
  fails "MatchData#end when passed a Symbol argument returns the character offset for multi byte strings" # Exception: named captures are not supported in javascript: "(?<a>.)(.)(?<b>\d+)(\d)"
  fails "MatchData#end when passed a Symbol argument returns the character offset for multi-byte names" # Exception: named captures are not supported in javascript: "(?<æ>.)(.)(?<b>\d+)(\d)"
  fails "MatchData#end when passed a Symbol argument returns the character offset for the farthest match when multiple named captures use the same name" # Exception: named captures are not supported in javascript: "(?<a>.)(.)(?<a>\d+)(\d)"
  fails "MatchData#end when passed an integer argument returns nil when the nth match isn't found" # ArgumentError: MatchData#end only supports 0th element
  fails "MatchData#end when passed an integer argument returns the character offset for multi-byte strings" # ArgumentError: MatchData#end only supports 0th element
  fails "MatchData#end when passed an integer argument returns the character offset of the end of the nth element" # ArgumentError: MatchData#end only supports 0th element
  fails "MatchData#end when passed an integer argument tries to convert the passed argument to an Integer using #to_int" # ArgumentError: MatchData#end only supports 0th element
  fails "MatchData#end when passed an integer argument tries to convert the passed argument to an Integer using #to_int" # Mock 'to_int' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "MatchData#named_captures prefers later captures" # Exception: named captures are not supported in javascript: "^(?<a>.)(?<b>.)(?<b>.)(?<a>.)$"
  fails "MatchData#named_captures returns a Hash that has captured name and the matched string pairs" # Exception: named captures are not supported in javascript: "(?<a>.)(?<b>.)?"
  fails "MatchData#named_captures returns the latest matched capture, even if a later one that does not match exists" # Exception: named captures are not supported in javascript: "^(?<a>.)(?<b>.)(?<b>.)(?<a>.)?$"
  fails "MatchData#names equals Regexp#names"
  fails "MatchData#names returns [] if there were no named captures"
  fails "MatchData#names returns an Array"
  fails "MatchData#names returns each name only once"
  fails "MatchData#names returns the names of the named capture groups"
  fails "MatchData#names sets each element to a String"
  fails "MatchData#offset returns [nil, nil] when the nth match isn't found"
  fails "MatchData#offset returns a two element array with the begin and end of the nth match"
  fails "MatchData#offset returns the offset for multi byte strings with unicode regexp"
  fails "MatchData#offset returns the offset for multi byte strings"
  fails "MatchData#post_match keeps taint status from the source string"
  fails "MatchData#post_match keeps untrusted status from the source string"
  fails "MatchData#pre_match keeps taint status from the source string"
  fails "MatchData#pre_match keeps untrusted status from the source string"
  fails "MatchData#regexp returns the pattern used in the match"
  fails "MatchData#values_at slices captures with the given names" # Exception: named captures are not supported in javascript: "(?<a>.)(?<b>.)(?<c>.)"
  fails "MatchData#values_at takes names and indices" # Exception: named captures are not supported in javascript: "^(?<a>.)(?<b>.)$"
end
