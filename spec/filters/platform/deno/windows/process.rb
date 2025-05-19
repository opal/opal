# NOTE: run bin/format-filters after changing this file
opal_filter "Process" do
  fails "Process.getrlimit is not implemented" # Expected true to be false
  fails "Process.setrlimit is not implemented" # Expected true to be false
end
