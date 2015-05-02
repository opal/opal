opal_filter "regular_expressions" do
  fails "MatchData#[Symbol] returns the corresponding named match when given a Symbol"
  fails "MatchData#[Symbol] returns the corresponding named match when given a String"
  fails "MatchData#[Symbol] returns the matching version of multiple corresponding named match"
  fails "MatchData#[Symbol] returns the last match when multiple named matches exist with the same name"
  fails "MatchData#[Symbol] returns nil on non-matching named matches"
  fails "MatchData#[Symbol] raises an IndexError if there is no named match corresponding to the Symbol"
  fails "MatchData#[Symbol] raises an IndexError if there is no named match corresponding to the String"
  fails "MatchData#[Symbol] returns matches in the String's encoding"

  fails "MatchData#begin returns the offset of the start of the nth element"
  fails "MatchData#begin returns nil when the nth match isn't found"
  fails "MatchData#begin returns the offset for multi byte strings"
  fails "MatchData#begin returns the offset for multi byte strings with unicode regexp"

  fails "MatchData#end returns the offset of the end of the nth element"
  fails "MatchData#end returns nil when the nth match isn't found"
  fails "MatchData#end returns the offset for multi byte strings"
  fails "MatchData#end returns the offset for multi byte strings with unicode regexp"

  fails "MatchData#names returns an Array"
  fails "MatchData#names sets each element to a String"
  fails "MatchData#names returns the names of the named capture groups"
  fails "MatchData#names returns [] if there were no named captures"
  fails "MatchData#names returns each name only once"
  fails "MatchData#names equals Regexp#names"

  fails "MatchData#offset returns a two element array with the begin and end of the nth match"
  fails "MatchData#offset returns [nil, nil] when the nth match isn't found"
  fails "MatchData#offset returns the offset for multi byte strings"
  fails "MatchData#offset returns the offset for multi byte strings with unicode regexp"

  fails "MatchData#regexp returns the pattern used in the match"

  fails "String#gsub with pattern and replacement replaces \\k named backreferences with the regexp's corresponding capture"
  fails "String#gsub with pattern and replacement doesn't freak out when replacing ^" #Only fails "Text\nFoo".gsub(/^/, ' ').should == " Text\n Foo"
  fails "String#gsub with pattern and replacement supports \\G which matches at the beginning of the remaining (non-matched) string"
  fails "String#gsub with pattern and replacement returns a copy of self with all occurrences of pattern replaced with replacement" #Only fails str.gsub(/\Ah\S+\s*/, "huh? ").should == "huh? homely world. hah!"

  fails "String#index with Regexp supports \\G which matches at the given start offset"

  fails "String#match matches \\G at the start of the string"

  fails "String#scan supports \\G which matches the end of the previous match / string start for first match"

  fails "String#sub with pattern, replacement supports \\G which matches at the beginning of the string"
end
