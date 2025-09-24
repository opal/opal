# NOTE: run bin/format-filters after changing this file
opal_filter "Process" do
  fails "Process.exit! exits with the given status" # NotImplementedError: NotImplementedError
  fails "Process.exit! skips at_exit handlers" # NotImplementedError: NotImplementedError
  fails "Process.exit! skips ensure clauses" # NotImplementedError: NotImplementedError
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
  fails "Process.waitpid returns nil when the process has not yet completed and WNOHANG is specified" # NotImplementedError: NotImplementedError
end
