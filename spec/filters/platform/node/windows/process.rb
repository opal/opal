# NOTE: run bin/format-filters after changing this file
opal_filter "Process" do
  fails "Process.getrlimit is not implemented" # Expected true to be false
  fails "Process.setrlimit is not implemented" # Expected true to be false
  fails "Process.spawn raises Errno::EACCES or Errno::ENOEXEC when the file is not an executable file" # Expected SystemCallError but no exception was raised (2424 was returned)
  fails "Process.spawn raises an ArgumentError if given :pgroup option" # Expected ArgumentError but got: NotImplementedError (:pgroup option is not available)
  fails "Process.spawn with a single argument does not create an argument array with shell parsing semantics for whitespace on Windows" # NotImplementedError: NotImplementedError
  fails "Process.spawn with a single argument does not subject the specified command to shell expansion on Windows" # NotImplementedError: NotImplementedError
  fails "Process.waitpid returns nil when the process has not yet completed and WNOHANG is specified" # NotImplementedError: NotImplementedError
  fails "Process::Constants does not define RLIMIT constants" # Expected true to be false
end
