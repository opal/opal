# NOTE: run bin/format-filters after changing this file
opal_filter "NilClass" do
  fails "NilClass#=~ returns nil matching any object" # Expected false to be nil
  fails "The predefined global constants NIL is no longer defined" # Expected true == false to be truthy but was false
end
