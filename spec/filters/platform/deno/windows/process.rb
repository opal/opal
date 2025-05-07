# NOTE: run bin/format-filters after changing this file
opal_filter "Process" do
  fails "Process.exec (environment variables) coerces environment argument using to_hash" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rdeno C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Process.exec (environment variables) sets environment variables in the child environment" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rdeno C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Process.exec (environment variables) unsets environment variables whose value is nil" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rdeno C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Process.exec (environment variables) unsets other environment variables when given a true :unsetenv_others option" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rdeno C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Process.exec raises Errno::EACCES or Errno::ENOEXEC when the file is not an executable file" # Expected SystemCallError but got: ArgumentError ([Process.argv] wrong number of arguments (given 0, expected 1))
  fails "Process.exec raises Errno::EACCES when passed a directory" # Expected Errno::EACCES but got: ArgumentError ([Process.argv] wrong number of arguments (given 0, expected 1))
  fails "Process.exec raises Errno::ENOENT for a command which does not exist" # Expected Errno::ENOENT but got: ArgumentError ([Process.argv] wrong number of arguments (given 0, expected 1))
  fails "Process.exec raises Errno::ENOENT for an empty string" # Expected Errno::ENOENT but got: ArgumentError ([Process.argv] wrong number of arguments (given 0, expected 1))
  fails "Process.exec runs the specified command, replacing current process" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rdeno C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Process.exec sets the current directory when given the :chdir option" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rdeno C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Process.exec with a command array coerces the argument using to_ary" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rdeno C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Process.exec with a command array uses the first element as the command name and the second as the argv[0] value" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rdeno C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Process.exec with a single argument does not create an argument array with shell parsing semantics for whitespace on Windows" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rdeno C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Process.exec with a single argument does not subject the specified command to shell expansion on Windows" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rdeno C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Process.exec with multiple arguments does not subject the arguments to shell expansion" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rdeno C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Process.getrlimit is not implemented" # Expected true to be false
  fails "Process.setrlimit is not implemented" # Expected true to be false
end
