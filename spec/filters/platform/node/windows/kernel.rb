# NOTE: run bin/format-filters after changing this file
opal_filter "Kernel" do
  fails "Kernel#` raises an Errno::ENOENT if the command is not executable" # Expected Errno::ENOENT but no exception was raised ("" was returned)
  fails "Kernel#` returns the standard output of the executed sub-process" # Expected  "disc world\r " ==  "disc world " to be truthy but was false
  fails "Kernel#exec runs the specified command, replacing current process" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rnode C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Kernel#system does expand shell variables when given multiples arguments" # Expected (STDOUT): "foo\n"           but got: "\"foo\"\r\n" Backtrace
  fails "Kernel#system executes the specified command in a subprocess" # Expected (STDOUT): "a\n"           but got: "a\r\n" Backtrace
  fails "Kernel#system expands shell variables when given a single string argument" # Expected (STDOUT): "foo\n"           but got: "foo\r\n" Backtrace
  fails "Kernel#system returns nil when command execution fails" # Expected false to be nil
  fails "Kernel#system runs commands starting with any number of @ using shell" # Expected "false" == "nil" to be truthy but was false
  fails "Kernel.` tries to convert the given argument to String using #to_str" # Expected  "test\r " ==  "test " to be truthy but was false
  fails "Kernel.system does expand shell variables when given multiples arguments" # Expected (STDOUT): "foo\n"           but got: "\"foo\"\r\n" Backtrace
  fails "Kernel.system executes the specified command in a subprocess" # Expected (STDOUT): "a\n"           but got: "a\r\n" Backtrace
  fails "Kernel.system expands shell variables when given a single string argument" # Expected (STDOUT): "foo\n"           but got: "foo\r\n" Backtrace
  fails "Kernel.system returns nil when command execution fails" # Expected false to be nil
  fails "Kernel.system runs commands starting with any number of @ using shell" # Expected "false" == "nil" to be truthy but was false
end
