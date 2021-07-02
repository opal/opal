# NOTE: run bin/format-filters after changing this file
opal_filter "Pathname" do
  fails "Pathname#/ appends a pathname to self" # NoMethodError: undefined method `/' for /usr
  fails "Pathname#inspect returns a consistent String" # Expected "/tmp" == "#<Pathname:/tmp>" to be truthy but was false
  fails "Pathname#realdirpath returns a Pathname"
  fails "Pathname#realpath returns a Pathname"
  fails "Pathname#relative_path_from raises an error when the base directory has .."
  fails "Pathname#relative_path_from raises an error when the two paths do not share a common prefix"
  fails "Pathname#relative_path_from returns current and pattern when only those patterns are used"
end
