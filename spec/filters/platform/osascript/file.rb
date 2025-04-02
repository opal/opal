# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "File" do
  fails "File.absolute_path accepts a second argument of a directory from which to resolve the path" # Expected "/Users/jan/workspace/opal/corelib/ruby/core/file/absolute_path_spec.rb" == "/Users/jan/workspace/opal/ruby/core/file/absolute_path_spec.rb" to be truthy but was false
  fails "File.absolute_path does not expand '~' to a home directory." # Expected "/Users/jan" == "/Users/jan" to be falsy but was true
  fails "File.absolute_path does not expand '~' when given dir argument" # Expected "/Users/jan" == "/~" to be truthy but was false
  fails "File.basename returns a new unfrozen String" # Expected "foo.rb" not to be identical to "foo.rb"
end
