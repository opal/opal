# NOTE: run bin/format-filters after changing this file
opal_filter "Process" do
  fails "Process.exec (environment variables) coerces environment argument using to_hash" # NotImplementedError: NotImplementedError
  fails "Process.exec (environment variables) sets environment variables in the child environment" # NotImplementedError: NotImplementedError
  fails "Process.exec (environment variables) unsets environment variables whose value is nil" # NotImplementedError: NotImplementedError
  fails "Process.exec (environment variables) unsets other environment variables when given a true :unsetenv_others option" # NotImplementedError: NotImplementedError
  fails "Process.exec flushes STDERR upon exit when it's not set to sync" # NotImplementedError: NotImplementedError
  fails "Process.exec flushes STDOUT upon exit when it's not set to sync" # NotImplementedError: NotImplementedError
  fails "Process.exec raises Errno::EACCES when passed a directory" # Expected Errno::EACCES but got: Exception (not_availabe is not defined)
  fails "Process.exec raises Errno::EACCES when the file does not have execute permissions" # Expected Errno::EACCES but got: Exception (not_availabe is not defined)
  fails "Process.exec raises Errno::ENOENT for a command which does not exist" # Expected Errno::ENOENT but got: Exception (not_availabe is not defined)
  fails "Process.exec raises Errno::ENOENT for an empty string" # Expected Errno::ENOENT but got: Exception (not_availabe is not defined)
  fails "Process.exec runs the specified command, replacing current process" # NotImplementedError: NotImplementedError
  fails "Process.exec sets the current directory when given the :chdir option" # NotImplementedError: NotImplementedError
  fails "Process.exec with a command array coerces the argument using to_ary" # NotImplementedError: NotImplementedError
  fails "Process.exec with a command array uses the first element as the command name and the second as the argv[0] value" # NotImplementedError: NotImplementedError
  fails "Process.exec with a single argument creates an argument array with shell parsing semantics for whitespace" # NotImplementedError: NotImplementedError
  fails "Process.exec with a single argument subjects the specified command to shell expansion" # NotImplementedError: NotImplementedError
  fails "Process.exec with an options Hash with Integer option keys lets the process after exec have specified file descriptor despite close_on_exec" # NotImplementedError: NotImplementedError
  fails "Process.exec with an options Hash with Integer option keys maps the key to a file descriptor in the child that inherits the file descriptor from the parent specified by the value" # NotImplementedError: NotImplementedError
  fails "Process.exec with an options Hash with Integer option keys sets close_on_exec to false on specified fd even when it fails" # NotImplementedError: NotImplementedError
  fails "Process.exec with multiple arguments does not subject the arguments to shell expansion" # NotImplementedError: NotImplementedError
  fails "Process.setproctitle should set the process title" # Expected "" to include "rubyspec-proctitle-test"
  fails "Process::Constants has the correct constant values on Linux" # NameError: uninitialized constant Process::WNOHANG
end
