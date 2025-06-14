# NOTE: run bin/format-filters after changing this file
opal_filter "Dir" do
  fails "Dir.[] raises an Encoding::CompatibilityError if the argument encoding is not compatible with US-ASCII" # Expected CompatibilityError but no exception was raised (["file_one.ext", "file_two.ext"] was returned)
  fails "Dir.exist? doesn't require the name to have a trailing slash" # NotImplementedError: String#sub! not supported. Mutable String methods are currently not supported in Opal.
  fails "Dir.glob raises an Encoding::CompatibilityError if the argument encoding is not compatible with US-ASCII" # Expected CompatibilityError but no exception was raised (["file_one.ext", "file_two.ext"] was returned)
  fails "Dir.mktmpdir when passed [Object] raises an ArgumentError" # Expected ArgumentError but no exception was raised ("/tmp/symbol20250420--b1gof" was returned)
end
