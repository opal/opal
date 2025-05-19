# NOTE: run bin/format-filters after changing this file
opal_filter "Process" do
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_MONOTONIC_RAW_APPROX" # NameError: uninitialized constant Process::CLOCK_MONOTONIC_RAW_APPROX
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_UPTIME_RAW and CLOCK_UPTIME_RAW_APPROX" # NameError: uninitialized constant Process::CLOCK_UPTIME_RAW
  fails "Process.setproctitle should set the process title" # Expected "" to include "rubyspec-proctitle-test"
  fails "Process::Constants has the correct constant values on BSD-like systems" # NameError: uninitialized constant Process::WUNTRACED
  fails "Process::Constants has the correct constant values on Darwin" # NameError: uninitialized constant Process::RLIM_SAVED_MAX
end
