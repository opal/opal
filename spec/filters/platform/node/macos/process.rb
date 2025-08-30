# NOTE: run bin/format-filters after changing this file
opal_filter "Process" do
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_MONOTONIC_RAW_APPROX" # NameError: uninitialized constant Process::CLOCK_MONOTONIC_RAW_APPROX
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_UPTIME_RAW and CLOCK_UPTIME_RAW_APPROX" # NameError: uninitialized constant Process::CLOCK_UPTIME_RAW
  fails "Process.groups gets an Array of the gids of groups in the supplemental group access list" # Expected [12, 33, 61, 79, 80, 81, 98, 100, 204, 250, 264, 395, 398, 399, 701] == [12, 33, 61, 79, 80, 81, 98, 100, 204, 250, 264, 395, 398, 399, 400, 701] to be truthy but was false - github actions issue
  fails "Process.setproctitle should set the process title" # Expected "" to include "rubyspec-proctitle-test"
  fails "Process.waitpid returns nil when the process has not yet completed and WNOHANG is specified" # NotImplementedError: NotImplementedError
  fails "Process::Constants has the correct constant values on BSD-like systems" # NameError: uninitialized constant Process::WUNTRACED
  fails "Process::Constants has the correct constant values on Darwin" # NameError: uninitialized constant Process::RLIM_SAVED_MAX
end
