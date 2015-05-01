opal_filter "MatchData" do
  fails "MatchData#begin returns the offset of the start of the nth element"
  fails "MatchData#begin returns nil when the nth match isn't found"
  fails "MatchData#begin returns the offset for multi byte strings"
  fails "MatchData#begin returns the offset for multi byte strings with unicode regexp"
  fails "MatchData#end returns the offset of the end of the nth element"
  fails "MatchData#end returns nil when the nth match isn't found"
  fails "MatchData#end returns the offset for multi byte strings"
  fails "MatchData#end returns the offset for multi byte strings with unicode regexp"
  fails "MatchData#eql? returns true if both operands have equal target strings, patterns, and match positions"
  fails "MatchData#== returns true if both operands have equal target strings, patterns, and match positions"
end
