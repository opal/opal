# NOTE: run bin/format-filters after changing this file
opal_filter "Process" do
  fails "Process.setproctitle should set the process title" # Expected "" to include "rubyspec-proctitle-test"
  fails "Process.waitall takes no arguments" # Expected ArgumentError but got: NotImplementedError (NotImplementedError)
  fails "Process::Constants has the correct constant values on Linux" # NameError: uninitialized constant Process::WNOHANG
end
