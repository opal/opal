opal_filter "regular_expressions" do
  fails "MatchData#offset returns the offset for multi byte strings with unicode regexp"

  fails "String#sub with pattern, replacement supports \\G which matches at the beginning of the string"

  fails "String#gsub with pattern and replacement replaces \\k named backreferences with the regexp's corresponding capture"
  fails "String#gsub with pattern and replacement doesn't freak out when replacing ^" #Only fails "Text\nFoo".gsub(/^/, ' ').should == " Text\n Foo"
  fails "String#gsub with pattern and replacement supports \\G which matches at the beginning of the remaining (non-matched) string"
  fails "String#gsub with pattern and replacement returns a copy of self with all occurrences of pattern replaced with replacement" #Only fails str.gsub(/\Ah\S+\s*/, "huh? ").should == "huh? homely world. hah!"

  fails "String#scan supports \\G which matches the end of the previous match / string start for first match"

  fails "String#match matches \\G at the start of the string"
end
