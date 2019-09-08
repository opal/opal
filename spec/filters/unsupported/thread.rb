# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Thread" do
  fails "Module#autoload (concurrently) raises a LoadError in each thread if the file does not exist" # NotImplementedError: Thread creation not available
  fails "Module#autoload (concurrently) raises a NameError in each thread if the constant is not set" # NotImplementedError: Thread creation not available
  fails "Module#autoload loads the registered constant even if the constant was already loaded by another thread"
  fails "StandardError is a superclass of ThreadError"
  fails "The return keyword in a Thread raises a LocalJumpError if used to exit a thread"
  fails "The throw keyword clears the current exception"
  fails "The throw keyword raises an ArgumentError if used to exit a thread"
end
