# NOTE: run bin/format-filters after changing this file
opal_filter "StringIO" do
  fails "StringIO#each when passed a separator yields each paragraph with two separation characters when passed an empty String as separator" # Expected ["para1\n\npara2\n\n\npara3"]  == ["para1\n\n", "para2\n\n", "para3"]  to be truthy but was false
  fails "StringIO#each when passed chomp returns each line with removed newline characters when called without block" # Expected ["a b \rc d e\n1 2 3 4 5\r\nthe end"]  == ["a b \rc d e", "1 2 3 4 5", "the end"]  to be truthy but was false
  fails "StringIO#each when passed chomp yields each line with removed newline characters to the passed block" # Expected ["a b \rc d e\n1 2 3 4 5\r\nthe end"]  == ["a b \rc d e", "1 2 3 4 5", "the end"]  to be truthy but was false
  fails "StringIO#each when passed limit returns the data read until the limit is met" # Expected ["a b ", "c d ", "e\n1 ", "2 3 ", "4 5"]  == ["a b ", "c d ", "e\n", "1 2 ", "3 4 ", "5"]  to be truthy but was false
  fails "StringIO#each when passed no arguments returns an Enumerator when passed no block" # Expected ["a b c d e\n1 2 3 4 5"]  == ["a b c d e\n", "1 2 3 4 5"]  to be truthy but was false
  fails "StringIO#each when passed no arguments yields each line starting from the current position" # Expected ["c d e\n1 2 3 4 5"]  == ["c d e\n", "1 2 3 4 5"]  to be truthy but was false
  fails "StringIO#each when passed no arguments yields each line to the passed block" # Expected ["a b c d e\n1 2 3 4 5"]  == ["a b c d e\n", "1 2 3 4 5"]  to be truthy but was false
  fails "StringIO#gets when passed [chomp] returns the data read without a trailing newline character" # Expected  "this>is>an>example " == "this>is>an>example"  to be truthy but was false
  fails "StringIO#gets when passed [separator] returns the next paragraph when the passed separator is an empty String" # Expected  "this is  an example" ==  "this is  " to be truthy but was false
  fails "StringIO#gets when passed no argument returns the data read till the next occurrence of $/ or till eof" # Expected  "this is an example for StringIO#gets" ==  "this is " to be truthy but was false
  fails "StringIO#gets when passed no argument sets $_ to the read content" # Expected  "this is an example for StringIO#gets" ==  "this is " to be truthy but was false
  fails "StringIO#gets when passed no argument updates self's lineno" # Expected 1  to have same value and type as 2
  fails "StringIO#gets when passed no argument updates self's position" # Expected 36  to have same value and type as 8
  fails "StringIO#lineno returns the number of lines read" # Expected 1  to have same value and type as 3
  fails "StringIO#lineno= sets the current line number, but has no impact on the position" # Expected  "this is an example" ==  "this " to be truthy but was false
  fails "StringIO#readline when passed [chomp] returns the data read without a trailing newline character" # Expected  "this>is>an>example " == "this>is>an>example"  to be truthy but was false
  fails "StringIO#readline when passed [separator] returns the next paragraph when the passed separator is an empty String" # Expected  "this is  an example" ==  "this is  " to be truthy but was false
  fails "StringIO#readline when passed no argument returns the data read till the next occurrence of $/ or till eof" # Expected  "this is an example for StringIO#readline" ==  "this is " to be truthy but was false
  fails "StringIO#readline when passed no argument sets $_ to the read content" # Expected  "this is an example for StringIO#readline" ==  "this is " to be truthy but was false
  fails "StringIO#readline when passed no argument updates self's lineno" # EOFError: end of file reached
  fails "StringIO#readline when passed no argument updates self's position" # Expected 40  to have same value and type as 8
end
