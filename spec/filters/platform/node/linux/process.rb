# NOTE: run bin/format-filters after changing this file
opal_filter "Process" do
  fails "Process.setproctitle should set the process title" # Expected "" to include "rubyspec-proctitle-test"
end
