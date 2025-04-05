# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File.sticky? returns true if the named file has the sticky bit, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#sticky? returns true if the named file has the sticky bit, otherwise false" # Expected false == true to be truthy but was false
end
