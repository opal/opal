# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Kernel" do
  fails "Kernel#exit! exits with the given status" # NotImplementedError: NotImplementedError
  fails "Kernel#exit! skips at_exit handlers" # NotImplementedError: NotImplementedError
  fails "Kernel#exit! skips ensure clauses" # NotImplementedError: NotImplementedError
  fails "Kernel#p flushes output if receiver is a File" # NotImplementedError: NotImplementedError
  fails "Kernel#p is not affected by setting $\\, $/ or $," # NotImplementedError: NotImplementedError
  fails "Kernel.at_exit allows calling exit inside a handler" # NotImplementedError: NotImplementedError
  fails "Kernel.at_exit calls the nested handler right after the outer one if a handler is nested into another handler" # NotImplementedError: NotImplementedError
  fails "Kernel.at_exit decides the exit status if both at_exit and the main script raise SystemExit" # NotImplementedError: NotImplementedError
  fails "Kernel.at_exit runs after all other code" # NotImplementedError: NotImplementedError
  fails "Kernel.at_exit runs all handlers even if some raise exceptions" # NotImplementedError: NotImplementedError
  fails "Kernel.at_exit runs in reverse order of registration" # NotImplementedError: NotImplementedError
  fails "Kernel.exit! exits with the given status" # NotImplementedError: NotImplementedError
  fails "Kernel.exit! skips at_exit handlers" # NotImplementedError: NotImplementedError
end
