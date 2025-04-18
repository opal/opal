# NOTE: run bin/format-filters after changing this file
opal_filter "Pathname" do
  fails "Pathname#birthtime returns the birth time for self" # Errno::ENOENT: No such file or directory
end
