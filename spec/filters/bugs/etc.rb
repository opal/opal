# NOTE: run bin/format-filters after changing this file
opal_filter "Etc" do
  fails "Etc.confstr raises Errno::EINVAL for unknown configuration variables" # Expected Errno::EINVAL but no exception was raised (nil was returned)
  fails "Etc.confstr returns a String for Etc::CS_PATH" # NameError: uninitialized constant Etc::CS_PATH
  fails "Etc.getlogin returns the name associated with the current login activity" # Exception: logname is not defined
  fails "Etc.group raises a RuntimeError for parallel iteration" # Expected RuntimeError but no exception was raised (nil was returned)
  fails "Etc.sysconf returns the value of POSIX.1 system configuration variable SC_ARG_MAX" # NameError: uninitialized constant Etc::SC_ARG_MAX
  fails "Etc.sysconf returns the value of POSIX.1 system configuration variable SC_CHILD_MAX" # NameError: uninitialized constant Etc::SC_CHILD_MAX
  fails "Etc.sysconf returns the value of POSIX.1 system configuration variable SC_CLK_TCK" # NameError: uninitialized constant Etc::SC_CLK_TCK
  fails "Etc.sysconf returns the value of POSIX.1 system configuration variable SC_HOST_NAME_MAX" # NameError: uninitialized constant Etc::SC_HOST_NAME_MAX
  fails "Etc.sysconf returns the value of POSIX.1 system configuration variable SC_LOGIN_NAME_MAX" # NameError: uninitialized constant Etc::SC_LOGIN_NAME_MAX
  fails "Etc.sysconf returns the value of POSIX.1 system configuration variable SC_NGROUPS_MAX" # NameError: uninitialized constant Etc::SC_NGROUPS_MAX
  fails "Etc.sysconf returns the value of POSIX.1 system configuration variable SC_OPEN_MAX" # NameError: uninitialized constant Etc::SC_OPEN_MAX
  fails "Etc.sysconf returns the value of POSIX.1 system configuration variable SC_PAGESIZE" # NameError: uninitialized constant Etc::SC_PAGESIZE
  fails "Etc.sysconf returns the value of POSIX.1 system configuration variable SC_RE_DUP_MAX" # NameError: uninitialized constant Etc::SC_RE_DUP_MAX
  fails "Etc.sysconf returns the value of POSIX.1 system configuration variable SC_STREAM_MAX" # NameError: uninitialized constant Etc::SC_STREAM_MAX
  fails "Etc.sysconf returns the value of POSIX.1 system configuration variable SC_SYMLOOP_MAX" # NameError: uninitialized constant Etc::SC_SYMLOOP_MAX
  fails "Etc.sysconf returns the value of POSIX.1 system configuration variable SC_TTY_NAME_MAX" # NameError: uninitialized constant Etc::SC_TTY_NAME_MAX
  fails "Etc.sysconf returns the value of POSIX.1 system configuration variable SC_TZNAME_MAX" # NameError: uninitialized constant Etc::SC_TZNAME_MAX
  fails "Etc.sysconf returns the value of POSIX.1 system configuration variable SC_VERSION" # NameError: uninitialized constant Etc::SC_VERSION
end
