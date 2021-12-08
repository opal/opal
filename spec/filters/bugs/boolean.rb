# NOTE: run bin/format-filters after changing this file
opal_filter "Boolean" do
  fails "The predefined global constants FALSE is no longer defined" # Expected true == false to be truthy but was false
  fails "The predefined global constants TRUE is no longer defined" # Expected true == false to be truthy but was false
end
