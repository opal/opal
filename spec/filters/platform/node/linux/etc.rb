# NOTE: run bin/format-filters after changing this file
opal_filter "Etc" do
  fails "Etc.getlogin returns the name associated with the current login activity" # Expected "runner" == "" to be truthy but was false -- fails on github only
end
