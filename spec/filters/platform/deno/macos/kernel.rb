# NOTE: run bin/format-filters after changing this file
opal_filter "Kernel" do
  fails "Kernel#system does not expand shell variables when given multiples arguments" # Expected (STDOUT): "$TEST_SH_EXPANSION\n"           but got: "\n" Backtrace
  fails "Kernel#system executes with `sh` if the command contains shell characters" # Expected (STDOUT): "sh\n"           but got: "/usr/bin/sh\n" Backtrace
  fails "Kernel#system ignores SHELL env var and always uses `sh`" # Expected (STDOUT): "sh\n"           but got: "/usr/bin/sh\n" Backtrace
  fails "Kernel#system returns nil when command execution fails" # Expected nil (NilClass) to be kind of Integer
  fails "Kernel.system does not expand shell variables when given multiples arguments" # Expected (STDOUT): "$TEST_SH_EXPANSION\n"           but got: "\n" Backtrace
  fails "Kernel.system executes with `sh` if the command contains shell characters" # Expected (STDOUT): "sh\n"           but got: "/usr/bin/sh\n" Backtrace
  fails "Kernel.system ignores SHELL env var and always uses `sh`" # Expected (STDOUT): "sh\n"           but got: "/usr/bin/sh\n" Backtrace
  fails "Kernel.system returns nil when command execution fails" # Expected nil (NilClass) to be kind of Integer
end
