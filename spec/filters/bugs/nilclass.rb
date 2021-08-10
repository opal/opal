# NOTE: run bin/format-filters after changing this file
opal_filter "NilClass" do
  fails "NilClass#=~ returns nil matching any object" # Expected false to be nil
end
