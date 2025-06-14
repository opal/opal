# NOTE: run bin/format-filters after changing this file
opal_filter "Process" do
  fails "Process.exit! exits with the given status" # NotImplementedError: NotImplementedError
  fails "Process.exit! skips at_exit handlers" # NotImplementedError: NotImplementedError
  fails "Process.exit! skips ensure clauses" # NotImplementedError: NotImplementedError
end
