# NOTE: run bin/format-filters after changing this file
opal_filter "Process" do
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_MONOTONIC_RAW_APPROX" # NameError: uninitialized constant Process::CLOCK_MONOTONIC_RAW_APPROX
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_UPTIME_RAW and CLOCK_UPTIME_RAW_APPROX" # NameError: uninitialized constant Process::CLOCK_UPTIME_RAW
  fails "Process.egid= raises Errno::ERPERM if run by a non superuser trying to set the root group id" # Expected Errno::EPERM but no exception was raised (0 was returned)
  fails "Process.euid= raises Errno::ERPERM if run by a non superuser trying to set the superuser id from username" # Expected Errno::EPERM but no exception was raised ("root" was returned)
  fails "Process.euid= raises Errno::ERPERM if run by a non superuser trying to set the superuser id" # Expected Errno::EPERM but no exception was raised (0 was returned)
  fails "Process.groups gets an Array of the gids of groups in the supplemental group access list" # Expected [] == [12, 33, 61, 79, 80, 81, 98, 100, 204, 250, 395, 398, 399, 400, 701] to be truthy but was false
  fails "Process.groups= raises Errno::EPERM" # Expected Errno::EPERM but no exception was raised ([0] was returned)
  fails "Process.setproctitle should set the process title" # Exception: Cannot add property title, object is not extensible
  fails "Process.uid= raises Errno::ERPERM if run by a non privileged user trying to set the superuser id" # Expected Errno::EPERM but no exception was raised (0 was returned)
  fails "Process::Constants has the correct constant values on BSD-like systems" # NameError: uninitialized constant Process::WUNTRACED
  fails "Process::Constants has the correct constant values on Darwin" # NameError: uninitialized constant Process::RLIM_SAVED_MAX
end
