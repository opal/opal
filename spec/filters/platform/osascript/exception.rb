# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Exception" do
  fails "Exception#backtrace contains lines of the same format for each prior position in the stack"
  fails "Exception#backtrace includes the line number of the location immediately prior to where self raised in the second element" # Expected ":in `$new'" =~ /:6(:in )?/ to be truthy but was nil
end
