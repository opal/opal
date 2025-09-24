# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Class" do
  fails "Class#initialize is private" # Expected Class to have private method 'initialize' but it does not
end
