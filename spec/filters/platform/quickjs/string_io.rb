# NOTE: run bin/format-filters after changing this file
opal_filter "StringIO" do
  fails "StringIO#syswrite when passed [String] transcodes the given string when the external encoding is set and neither is BINARY" # Expected [104, 0, 101, 0, 108, 0, 108, 0, 111, 0] == [0, 104, 0, 101, 0, 108, 0, 108, 0, 111] to be truthy but was false
  fails "StringIO#write when passed [String] transcodes the given string when the external encoding is set and neither is BINARY" # Expected [104, 0, 101, 0, 108, 0, 108, 0, 111, 0] == [0, 104, 0, 101, 0, 108, 0, 108, 0, 111] to be truthy but was false
end
