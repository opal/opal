# Source map support currently is only available for Chrome and Nodejs
opal_unsupported_filter "Exception" do
  fails "Exception#backtrace_locations sets each element to a Thread::Backtrace::Location"
  fails "Exception#backtrace contains lines of the same format for each prior position in the stack"
  fails "Exception#backtrace sets each element to a String"
  fails "Invoking a method when the method is not available should omit the method_missing call from the backtrace for NoMethodError"
  fails "Invoking a method when the method is not available should omit the method_missing call from the backtrace for NameError"
end
