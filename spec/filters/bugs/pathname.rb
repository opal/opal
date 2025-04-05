# NOTE: run bin/format-filters after changing this file
opal_filter "Pathname" do
  fails "Pathname#/ appends a pathname to self" # NoMethodError: undefined method `/' for #<Pathname:0xb5bd8 @path="/usr">
  fails "Pathname#inspect returns a consistent String" # Expected "#<Pathname:0x1e50 @path=\"/tmp\">" == "#<Pathname:/tmp>" to be truthy but was false
  fails "Pathname#realdirpath returns a Pathname" # NoMethodError: undefined method `realdirpath' for #<Pathname:0x1380 @path=".">
  fails "Pathname#realpath returns a Pathname" # NoMethodError: undefined method `realpath' for #<Pathname:0xaa902 @path=".">
  fails "Pathname#relative_path_from converts string argument to Pathname" # NoMethodError: undefined method `cleanpath' for "/usr"
  fails "Pathname#relative_path_from raises an error when the base directory has .." # Expected ArgumentError but no exception was raised ("a" was returned)
  fails "Pathname#relative_path_from raises an error when the two paths do not share a common prefix" # Expected ArgumentError but no exception was raised ("../usr" was returned)
  fails "Pathname#relative_path_from returns current and pattern when only those patterns are used" # Expected "." == ".." to be truthy but was false
end
