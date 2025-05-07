# NOTE: run bin/format-filters after changing this file
opal_filter "Kernel" do
  fails "Kernel#exec runs the specified command, replacing current process" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rbun /Users/jan/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Kernel#fork returns nil for the child process" # Expected File.exist? "/home/jan/workspace/opal/tmp/rubyspec_temp/i_exist" to be truthy but was false
  fails "Kernel#fork returns status non-zero" # Expected false == 42 to be truthy but was false
  fails "Kernel#fork returns status zero" # Expected false == 0 to be truthy but was false
  fails "Kernel#system does not expand shell variables when given multiples arguments" # Expected (STDOUT): "$TEST_SH_EXPANSION\n"           but got: "foo\n" Backtrace
  fails "Kernel.exec runs the specified command, replacing current process" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rbun /Users/jan/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Kernel.fork returns nil for the child process" # Expected File.exist? "/home/jan/workspace/opal/tmp/rubyspec_temp/i_exist" to be truthy but was false
  fails "Kernel.fork returns status non-zero" # Expected false == 42 to be truthy but was false
  fails "Kernel.fork returns status zero" # Expected false == 0 to be truthy but was false
  fails "Kernel.fork runs a block in a child process" # Expected File.exist? "/home/jan/workspace/opal/tmp/rubyspec_temp/i_exist" to be truthy but was false
  fails "Kernel.system does not expand shell variables when given multiples arguments" # Expected (STDOUT): "$TEST_SH_EXPANSION\n"           but got: "foo\n" Backtrace
end
