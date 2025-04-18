# NOTE: run bin/format-filters after changing this file
opal_filter "Dir" do
  fails "Dir.[] raises an Encoding::CompatibilityError if the argument encoding is not compatible with US-ASCII" # Expected CompatibilityError but no exception was raised (["file_one.ext", "file_two.ext"] was returned)
  fails "Dir.exist? doesn't require the name to have a trailing slash" # NotImplementedError: String#sub! not supported. Mutable String methods are currently not supported in Opal.
  fails "Dir.glob raises an Encoding::CompatibilityError if the argument encoding is not compatible with US-ASCII" # Expected CompatibilityError but no exception was raised (["file_one.ext", "file_two.ext"] was returned)
  fails "Dir.home raises an ArgumentError if the named user doesn't exist" # Expected ArgumentError but no exception was raised ("/rubyspec_home" was returned)
  fails "Dir.home when called without arguments retrieves the directory from HOME, USERPROFILE, HOMEDRIVE/HOMEPATH and the WinAPI in that order" # Expected "C:/Users/Administrator" == "C:/rubyspec/home1" to be truthy but was false
end
