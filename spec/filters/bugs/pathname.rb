opal_filter "Pathname" do
  fails "Pathname#relative_path_from raises an error when the two paths do not share a common prefix"
  fails "Pathname#relative_path_from raises an error when the base directory has .."
  fails "Pathname#relative_path_from returns current and pattern when only those patterns are used"
  fails "Pathname#realpath returns a Pathname"
  fails "Pathname#realdirpath returns a Pathname"
end
