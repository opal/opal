# NOTE: run bin/format-filters after changing this file
opal_filter "Kernel" do
  fails "Kernel#` returns the standard output of the executed sub-process" # Expected  "disc world\r " ==  "disc world " to be truthy but was false
  fails "Kernel#system does expand shell variables when given multiples arguments" # Expected (STDOUT): "foo\n"           but got: "foo\r\n" Backtrace
  fails "Kernel#system does not write to stderr when command execution fails" # Expected (STDERR): ""           but got: "'sad' is not recognized as an internal or external command,\r\noperable program or batch file.\r\n" Backtrace
  fails "Kernel#system executes the specified command in a subprocess" # Expected (STDOUT): "a\n"           but got: "a\r\n" Backtrace
  fails "Kernel#system expands shell variables when given a single string argument" # Expected (STDOUT): "foo\n"           but got: "foo\r\n" Backtrace
  fails "Kernel#system raises Errno::ENOENT when `exception: true` is given and the specified command does not exist" # Expected Errno::ENOENT but got: RuntimeError (Command failed with exit 1: feature_14386)
  fails "Kernel#system returns nil when command execution fails" # Expected false to be nil
  fails "Kernel#system runs commands starting with any number of @ using shell" # Expected "false" == "nil" to be truthy but was false
  fails "Kernel.` tries to convert the given argument to String using #to_str" # Expected  "test\r " ==  "test " to be truthy but was false
  fails "Kernel.system does expand shell variables when given multiples arguments" # Expected (STDOUT): "foo\n"           but got: "foo\r\n" Backtrace
  fails "Kernel.system does not write to stderr when command execution fails" # Expected (STDERR): ""           but got: "'sad' is not recognized as an internal or external command,\r\noperable program or batch file.\r\n" Backtrace
  fails "Kernel.system executes the specified command in a subprocess" # Expected (STDOUT): "a\n"           but got: "a\r\n" Backtrace
  fails "Kernel.system expands shell variables when given a single string argument" # Expected (STDOUT): "foo\n"           but got: "foo\r\n" Backtrace
  fails "Kernel.system raises Errno::ENOENT when `exception: true` is given and the specified command does not exist" # Expected Errno::ENOENT but got: RuntimeError (Command failed with exit 1: feature_14386)
  fails "Kernel.system returns nil when command execution fails" # Expected false to be nil
  fails "Kernel.system runs commands starting with any number of @ using shell" # Expected "false" == "nil" to be truthy but was false
end
