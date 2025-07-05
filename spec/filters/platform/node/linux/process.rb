# NOTE: run bin/format-filters after changing this file
opal_filter "Process" do
  fails "Process.setpriority sets the scheduling priority for a specified process group" # NotImplementedError: NotImplementedError
  fails "Process.setproctitle should set the process title" # Expected "" to include "rubyspec-proctitle-test"
  fails "Process.setrlimit when passed a String coerces 'MSGQUEUE' into RLIMIT_MSGQUEUE" # NotImplementedError: NotImplementedError
  fails "Process.setrlimit when passed a String coerces 'NICE' into RLIMIT_NICE" # NotImplementedError: NotImplementedError
  fails "Process.setrlimit when passed a String coerces 'RTPRIO' into RLIMIT_RTPRIO" # NotImplementedError: NotImplementedError
  fails "Process.setrlimit when passed a String coerces 'RTTIME' into RLIMIT_RTTIME" # NotImplementedError: NotImplementedError
  fails "Process.setrlimit when passed a String coerces 'SIGPENDING' into RLIMIT_SIGPENDING" # NotImplementedError: NotImplementedError
  fails "Process.setrlimit when passed a Symbol coerces :MSGQUEUE into RLIMIT_MSGQUEUE" # NotImplementedError: NotImplementedError
  fails "Process.setrlimit when passed a Symbol coerces :NICE into RLIMIT_NICE" # NotImplementedError: NotImplementedError
  fails "Process.setrlimit when passed a Symbol coerces :RTPRIO into RLIMIT_RTPRIO" # NotImplementedError: NotImplementedError
  fails "Process.setrlimit when passed a Symbol coerces :RTTIME into RLIMIT_RTTIME" # NotImplementedError: NotImplementedError
  fails "Process.setrlimit when passed a Symbol coerces :SIGPENDING into RLIMIT_SIGPENDING" # NotImplementedError: NotImplementedError
  fails "Process.spawn inside Dir.chdir does not create extra process without chdir" # NotImplementedError: NotImplementedError
  fails "Process.spawn inside Dir.chdir kills extra chdir processes" # NotImplementedError: NotImplementedError
  fails "Process.waitpid returns nil when the process has not yet completed and WNOHANG is specified" # NotImplementedError: NotImplementedError
  fails "Process::Constants has the correct constant values on Linux" # Expected nil == 0 to be truthy but was false
end
