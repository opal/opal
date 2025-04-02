# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File.expand_path when HOME is set does not return a frozen string" # Expected "/rubyspec_home".frozen? to be falsy but was true
  fails "File.extname returns unfrozen strings" # Expected true == false to be truthy but was false
end
