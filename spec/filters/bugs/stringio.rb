# NOTE: run bin/format-filters after changing this file
opal_filter "StringIO" do
  fails "StringIO#each when passed chomp returns each line with removed separator when called without block" # Expected ["a b \n" + "c d e|", "1 2 3 4 5\n" + "|", "the end"] == ["a b \n" + "c d e", "1 2 3 4 5\n", "the end"] to be truthy but was false
  fails "StringIO#each when passed chomp yields each line with removed separator to the passed block" # Expected ["a b \n" + "c d e|", "1 2 3 4 5\n" + "|", "the end"] == ["a b \n" + "c d e", "1 2 3 4 5\n", "the end"] to be truthy but was false
  fails "StringIO#each when passed limit returns the data read until the limit is met" # NoMethodError: undefined method `[]' for nil
  fails "StringIO#each_line when passed limit returns the data read until the limit is met" # NoMethodError: undefined method `[]' for nil
end
