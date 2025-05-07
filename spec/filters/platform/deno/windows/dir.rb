# NOTE: run bin/format-filters after changing this file
opal_filter "Dir" do
  fails "Dir.mkdir creates the named directory with the given permissions" # Expected 16822 == 16822 to be falsy but was true
end
