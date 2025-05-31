# NOTE: run bin/format-filters after changing this file
opal_filter "Exception" do
  fails "Exception#backtrace contains lines of the same format for each prior position in the stack"
  fails "Exception#backtrace returns an Array that can be updated" # Expected nil == "backtrace first" to be truthy but was false
  fails "Exception#backtrace returns the same array after duping" # Expected [] to be identical to []
  fails "Exception#backtrace sets each element to a String"
  fails "Exception#backtrace_locations sets each element to a Thread::Backtrace::Location"
  fails "Invoking a method when the method is not available should omit the method_missing call from the backtrace for NameError"
  fails "Invoking a method when the method is not available should omit the method_missing call from the backtrace for NoMethodError"
end
