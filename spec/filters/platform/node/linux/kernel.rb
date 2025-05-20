# NOTE: run bin/format-filters after changing this file
opal_filter "Kernel" do
  fails "Kernel#system does not expand shell variables when given multiples arguments" # Expected (STDOUT): "$TEST_SH_EXPANSION\n"           but got: "\n" Backtrace
  fails "Kernel.system does not expand shell variables when given multiples arguments" # Expected (STDOUT): "$TEST_SH_EXPANSION\n"           but got: "\n" Backtrace
end
