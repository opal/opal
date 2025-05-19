# NOTE: run bin/format-filters after changing this file
opal_filter "Process" do
  fails "Process.egid= raises Errno::ERPERM if run by a non superuser trying to set the group id from group name" # Expected Errno::EPERM but no exception was raised ("root" was returned)
  fails "Process.egid= raises Errno::ERPERM if run by a non superuser trying to set the root group id" # Expected Errno::EPERM but no exception was raised (0 was returned)
  fails "Process.euid= raises Errno::ERPERM if run by a non superuser trying to set the superuser id from username" # Expected Errno::EPERM but no exception was raised ("root" was returned)
  fails "Process.euid= raises Errno::ERPERM if run by a non superuser trying to set the superuser id" # Expected Errno::EPERM but no exception was raised (0 was returned)
  fails "Process.groups gets an Array of the gids of groups in the supplemental group access list" # Expected [] == [10, 971] to be truthy but was false
  fails "Process.groups= raises Errno::EPERM" # Expected Errno::EPERM but no exception was raised ([0] was returned)
  fails "Process.setproctitle should set the process title" # Expected "" to include "rubyspec-proctitle-test"
  fails "Process.uid= raises Errno::ERPERM if run by a non privileged user trying to set the superuser id" # Expected Errno::EPERM but no exception was raised (0 was returned)
  fails "Process::Constants has the correct constant values on Linux" # NameError: uninitialized constant Process::WNOHANG
end
