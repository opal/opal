# NOTE: run bin/format-filters after changing this file
opal_filter "Process" do
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_PROF" # NameError: uninitialized constant Process::CLOCK_PROF
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_REALTIME_FAST and CLOCK_REALTIME_PRECISE" # NameError: uninitialized constant Process::CLOCK_REALTIME_FAST
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_SECOND" # NameError: uninitialized constant Process::CLOCK_SECOND
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_UPTIME" # NameError: uninitialized constant Process::CLOCK_UPTIME
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_UPTIME_FAST and CLOCK_UPTIME_PRECISE" # NameError: uninitialized constant Process::CLOCK_UPTIME_FAST
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_VIRTUAL" # NameError: uninitialized constant Process::CLOCK_VIRTUAL
  fails "Process.waitpid returns nil when the process has not yet completed and WNOHANG is specified" # Expected 0 == nil to be truthy but was false
end
