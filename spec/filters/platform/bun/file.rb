# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File.expand_path when HOME is not set raises an ArgumentError when passed '~' if HOME == ''" # Expected ArgumentError but no exception was raised ("/home/jan" was returned)
  fails "File.sticky? returns true if the named file has the sticky bit, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#sticky? returns true if the named file has the sticky bit, otherwise false" # Expected false == true to be truthy but was false
end
