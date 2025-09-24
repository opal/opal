# NOTE: run bin/format-filters after changing this file
opal_filter "Pathname" do
  fails "Pathname#realdirpath returns a Pathname" # NotImplementedError: NotImplementedError
  fails "Pathname#realpath returns a Pathname" # NotImplementedError: NotImplementedError
end
