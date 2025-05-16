# NOTE: run bin/format-filters after changing this file
opal_filter "Process" do
  fails "Process.exit! exits with the given status" # NotImplementedError: NotImplementedError
  fails "Process.exit! skips at_exit handlers" # NotImplementedError: NotImplementedError
  fails "Process.exit! skips ensure clauses" # NotImplementedError: NotImplementedError
  fails "Process::Constants has the correct constant values on Linux" # NameError: uninitialized constant Process::WUNTRACED
end
