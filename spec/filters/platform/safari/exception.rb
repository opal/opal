# Source map support currently is only available for Chrome and Nodejs
opal_unsupported_filter "Exception" do
  fails "Exception#backtrace contains lines of the same format for each prior position in the stack"
  fails "Exception#backtrace_locations sets each element to a Thread::Backtrace::Location"
  fails "Exception#backtrace returns an Array that can be updated"
  fails "Exception#backtrace returns the same array after duping"
  fails "Exception#backtrace sets each element to a String"
end
