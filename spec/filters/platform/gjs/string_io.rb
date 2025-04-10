# NOTE: run bin/format-filters after changing this file
opal_filter "StringIO" do
  fails "StringIO#each when passed a separator yields each paragraph with two separation characters when passed an empty String as separator" # Expected ["para1\n\npara2\n\n\npara3"]  == ["para1\n\n", "para2\n\n", "para3"]  to be truthy but was false
  fails "StringIO#each when passed chomp returns each line with removed newline characters when called without block" # Expected ["a b \rc d e\n1 2 3 4 5\r\nthe end"]  == ["a b \rc d e", "1 2 3 4 5", "the end"]  to be truthy but was false
  fails "StringIO#each when passed chomp yields each line with removed newline characters to the passed block" # Expected ["a b \rc d e\n1 2 3 4 5\r\nthe end"]  == ["a b \rc d e", "1 2 3 4 5", "the end"]  to be truthy but was false
  fails "StringIO#each when passed limit returns the data read until the limit is met" # Expected ["a b ", "c d ", "e\n1 ", "2 3 ", "4 5"]  == ["a b ", "c d ", "e\n", "1 2 ", "3 4 ", "5"]  to be truthy but was false
  fails "StringIO#each when passed no arguments returns an Enumerator when passed no block" # Expected ["a b c d e\n1 2 3 4 5"]  == ["a b c d e\n", "1 2 3 4 5"]  to be truthy but was false
  fails "StringIO#each when passed no arguments yields each line starting from the current position" # Expected ["c d e\n1 2 3 4 5"]  == ["c d e\n", "1 2 3 4 5"]  to be truthy but was false
  fails "StringIO#each when passed no arguments yields each line to the passed block" # Expected ["a b c d e\n1 2 3 4 5"]  == ["a b c d e\n", "1 2 3 4 5"]  to be truthy but was false
  fails "StringIO#readlines when passed [chomp] returns the data read without a trailing newline character" # Expected ["this>is\nan>example\r\n"]  == ["this>is", "an>example"]  to be truthy but was false
  fails "StringIO#readlines when passed [limit] ignores it when the limit is negative" # Expected ["a b c d e\n1 2 3 4 5"]  == ["a b c d e\n", "1 2 3 4 5"]  to be truthy but was false
  fails "StringIO#readlines when passed [limit] returns the data read until the limit is met" # Expected ["a b ", "c d ", "e\n1 ", "2 3 ", "4 5"]  == ["a b ", "c d ", "e\n", "1 2 ", "3 4 ", "5"]  to be truthy but was false
  fails "StringIO#readlines when passed [separator] returns an Array containing all paragraphs when the passed separator is an empty String" # Expected ["this is\n\nan example"]  == ["this is\n\n", "an example"]  to be truthy but was false
  fails "StringIO#readlines when passed no argument updates self's lineno based on the number of read lines" # Expected 1  to have same value and type as 3
end
