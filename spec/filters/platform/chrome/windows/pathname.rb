# NOTE: run bin/format-filters after changing this file
opal_filter "Pathname" do
  fails "Pathname#birthtime returns the birth time for self" # NotImplementedError: NotImplementedError
end
