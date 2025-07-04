# NOTE: run bin/format-filters after changing this file
opal_filter "Process" do
  fails "Process#last_status returns nil if no child process has been ever executed in the current thread" # NotImplementedError: Thread creation not available
  fails "Process.argv0 is the path given as the main script and the same as __FILE__" # Expected  "/tmp/opal-system-runner20250702-4867-3jqae6 fixtures/argv0.rb " ==  "fixtures/argv0.rb fixtures/argv0.rb OK" to be truthy but was false
  fails "Process.clock_getres with :GETRUSAGE_BASED_CLOCK_PROCESS_CPUTIME_ID reports 1 microsecond" # NotImplementedError: NotImplementedError
  fails "Process.clock_getres with :GETTIMEOFDAY_BASED_CLOCK_REALTIME reports 1 microsecond" # NotImplementedError: NotImplementedError
  fails "Process.clock_getres with :TIME_BASED_CLOCK_REALTIME reports 1 second" # NotImplementedError: NotImplementedError
  fails "Process.clock_getres with Process::CLOCK_MONOTONIC reports at least 10 millisecond" # NotImplementedError: NotImplementedError
  fails "Process.clock_getres with Process::CLOCK_REALTIME reports at least 10 millisecond" # NotImplementedError: NotImplementedError
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_MONOTONIC_COARSE" # NameError: uninitialized constant Process::CLOCK_MONOTONIC_COARSE
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_MONOTONIC_FAST and CLOCK_MONOTONIC_PRECISE" # NameError: uninitialized constant Process::CLOCK_MONOTONIC_FAST
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_MONOTONIC_RAW" # NameError: uninitialized constant Process::CLOCK_MONOTONIC_RAW
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_PROCESS_CPUTIME_ID" # NameError: uninitialized constant Process::CLOCK_PROCESS_CPUTIME_ID
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_REALTIME_COARSE" # NameError: uninitialized constant Process::CLOCK_REALTIME_COARSE
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_THREAD_CPUTIME_ID" # NameError: uninitialized constant Process::CLOCK_THREAD_CPUTIME_ID
  fails "Process.daemon changes directory to the root directory if the first argument is false" # NotImplementedError: NotImplementedError
  fails "Process.daemon changes directory to the root directory if the first argument is nil" # NotImplementedError: NotImplementedError
  fails "Process.daemon changes directory to the root directory if the first argument is not given" # NotImplementedError: NotImplementedError
  fails "Process.daemon does not change to the root directory if the first argument is true" # NotImplementedError: NotImplementedError
  fails "Process.daemon does not run existing at_exit handlers when daemonizing" # NotImplementedError: NotImplementedError
  fails "Process.daemon has a different PID after daemonizing" # NotImplementedError: NotImplementedError
  fails "Process.daemon has a different process group after daemonizing" # NotImplementedError: NotImplementedError
  fails "Process.daemon returns 0" # NotImplementedError: NotImplementedError
  fails "Process.daemon runs at_exit handlers when the daemon exits" # NotImplementedError: NotImplementedError
  fails "Process.daemon when the second argument is false does not close open files" # NotImplementedError: NotImplementedError
  fails "Process.daemon when the second argument is false redirects stderr to /dev/null" # NotImplementedError: NotImplementedError
  fails "Process.daemon when the second argument is false redirects stdin to /dev/null" # NotImplementedError: NotImplementedError
  fails "Process.daemon when the second argument is false redirects stdout to /dev/null" # NotImplementedError: NotImplementedError
  fails "Process.daemon when the second argument is nil does not close open files" # NotImplementedError: NotImplementedError
  fails "Process.daemon when the second argument is nil redirects stderr to /dev/null" # NotImplementedError: NotImplementedError
  fails "Process.daemon when the second argument is nil redirects stdin to /dev/null" # NotImplementedError: NotImplementedError
  fails "Process.daemon when the second argument is nil redirects stdout to /dev/null" # NotImplementedError: NotImplementedError
  fails "Process.daemon when the second argument is not given does not close open files" # NotImplementedError: NotImplementedError
  fails "Process.daemon when the second argument is not given redirects stderr to /dev/null" # NotImplementedError: NotImplementedError
  fails "Process.daemon when the second argument is not given redirects stdin to /dev/null" # NotImplementedError: NotImplementedError
  fails "Process.daemon when the second argument is not given redirects stdout to /dev/null" # NotImplementedError: NotImplementedError
  fails "Process.daemon when the second argument is true does not close open files" # NotImplementedError: NotImplementedError
  fails "Process.daemon when the second argument is true does not redirect stderr to /dev/null" # NotImplementedError: NotImplementedError
  fails "Process.daemon when the second argument is true does not redirect stdin to /dev/null" # NotImplementedError: NotImplementedError
  fails "Process.daemon when the second argument is true does not redirect stdout to /dev/null" # NotImplementedError: NotImplementedError
  fails "Process.detach calls #to_int to implicitly convert non-Integer pid to Integer" # Mock 'mock-enumerable' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "Process.detach raises TypeError when #to_int returns non-Integer value" # Expected TypeError (can't convert MockObject to Integer (MockObject#to_int gives Symbol)) but got: NotImplementedError (NotImplementedError)
  fails "Process.detach raises TypeError when pid argument does not have #to_int method" # Expected TypeError (no implicit conversion of Object into Integer) but got: NotImplementedError (NotImplementedError)
  fails "Process.detach tolerates not existing child process pid" # NameError: uninitialized constant Errno::ESRCH
  fails "Process.exit raises the SystemExit in the main thread if it reaches the top-level handler of another thread" # NotImplementedError: Thread creation not available
  fails "Process.exit! exits when called from a fiber" # Expected exit status is 21 but actual is 1 for command ruby_exe("bundle exec opal /home/jan/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Process.exit! exits when called from a thread" # Expected exit status is 21 but actual is 1 for command ruby_exe("bundle exec opal /home/jan/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Process.exit! overrides the original exception and exit status when called from #at_exit" # Expected exit status is 21 but actual is 1 for command ruby_exe("bundle exec opal /home/jan/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Process.kill accepts a String as signal name" # NotImplementedError: Thread creation not available
  fails "Process.kill accepts a Symbol as a signal name" # NotImplementedError: Thread creation not available
  fails "Process.kill accepts a signal name with the 'SIG' prefix" # NotImplementedError: Thread creation not available
  fails "Process.kill accepts a signal name without the 'SIG' prefix" # NotImplementedError: Thread creation not available
  fails "Process.kill accepts an Integer as a signal value" # NotImplementedError: Thread creation not available
  fails "Process.kill calls #to_int to coerce the pid to an Integer" # NotImplementedError: Thread creation not available
  fails "Process.kill raises Errno::ESRCH if the process does not exist" # NotImplementedError: NotImplementedError
  fails "Process.kill returns the number of processes signaled" # NotImplementedError: Thread creation not available
  fails "Process.kill signals multiple processes" # NotImplementedError: Thread creation not available
  fails "Process.kill signals the process group if the PID is zero" # NotImplementedError: Thread creation not available
  fails "Process.kill signals the process group if the full signal name starts with a minus sign" # NotImplementedError: Thread creation not available
  fails "Process.kill signals the process group if the short signal name starts with a minus sign" # NotImplementedError: Thread creation not available
  fails "Process.kill signals the process group if the signal number is negative" # NotImplementedError: Thread creation not available
  fails "Process.ppid returns the process id of the parent of this process" # Expected  "4441 " ==  "4268 " to be truthy but was false
  fails "Process.setpriority sets the scheduling priority for a specified process" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rnode ruby/core/process/fixtures/setpriority.rb process") Output:
  fails "Process.spawn closes STDERR in the child if :err => :close" # Expected (1830): "out\nrescued\n"         but got: "out\n" Backtrace
  fails "Process.spawn defaults :close_others to false" # Expected "" ==  "inherited " to be truthy but was false
  fails "Process.spawn joins a new process group if pgroup: 0" # NotImplementedError: pgroup options is not available
  fails "Process.spawn joins a new process group if pgroup: true" # NotImplementedError: pgroup options is not available
  fails "Process.spawn joins the current process if pgroup: false" # NotImplementedError: pgroup options is not available
  fails "Process.spawn joins the current process if pgroup: nil" # NotImplementedError: pgroup options is not available
  fails "Process.spawn joins the specified process group if pgroup: pgid" # NotImplementedError: pgroup option is not available
  fails "Process.spawn raises a TypeError if given a symbol as :pgroup option" # Expected TypeError but no exception was raised (56826 was returned)
  fails "Process.spawn raises an ArgumentError when passed a string key in options" # Expected ArgumentError but no exception was raised (56902 was returned)
  fails "Process.spawn raises an Errno::EACCES or Errno::EISDIR when passed a directory" # Expected SystemCallError but no exception was raised (61901 was returned)
  fails "Process.spawn raises an Errno::EACCES when the file does not have execute permissions" # Expected Errno::EACCES but no exception was raised (61900 was returned)
  fails "Process.spawn raises an Errno::ENOENT if the command does not exist" # Expected Errno::ENOENT but no exception was raised (61482 was returned)
  fails "Process.spawn redirects STDERR to child STDOUT if :err => [:child, :out]" # Expected (1302): "glark\n"         but got: "" Backtrace
  fails "Process.spawn redirects STDOUT to the given file if out: [String name, String mode]" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open '/home/jan/workspace/opal/tmp/rubyspec_temp/process_spawn.txt'
  fails "Process.spawn redirects default file descriptor to itself" # NotImplementedError: limited redirection
  fails "Process.spawn redirects non-default file descriptor to itself" # NotImplementedError: limited redirection
  fails "Process.spawn sets the umask if given the :umask option" # Expected (STDOUT): "146"           but got: "18" Backtrace
  fails "Process.spawn uses the current umask by default" # Expected (STDOUT): "9"           but got: "18" Backtrace
  fails "Process.spawn when passed close_others: false closes file descriptors >= 3 in the child process because they are set close_on_exec by default" # NotImplementedError: close_others option is not available
  fails "Process.spawn when passed close_others: false does not close STDERR" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rnode /home/jan/workspace/opal/tmp/rubyspec_temp/rubyexe.rb 2> /home/jan/workspace/opal/tmp/rubyspec_temp/process_spawn.txt") Output:
  fails "Process.spawn when passed close_others: false does not close STDIN" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rnode /home/jan/workspace/opal/tmp/rubyspec_temp/rubyexe.rb < ruby/core/process/fixtures/in.txt > /home/jan/workspace/opal/tmp/rubyspec_temp/process_spawn.txt") Output:
  fails "Process.spawn when passed close_others: false does not close STDOUT" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rnode /home/jan/workspace/opal/tmp/rubyspec_temp/rubyexe.rb > /home/jan/workspace/opal/tmp/rubyspec_temp/process_spawn.txt") Output:
  fails "Process.spawn when passed close_others: false does not close file descriptors >= 3 in the child process if fds are set close_on_exec=false" # NotImplementedError: close_others option is not available
  fails "Process.spawn when passed close_others: true closes file descriptors >= 3 in the child process even if fds are set close_on_exec=false" # NotImplementedError: close_others option is not available
  fails "Process.spawn when passed close_others: true does not close STDERR" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rnode /home/jan/workspace/opal/tmp/rubyspec_temp/rubyexe.rb 2> /home/jan/workspace/opal/tmp/rubyspec_temp/process_spawn.txt") Output:
  fails "Process.spawn when passed close_others: true does not close STDIN" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rnode /home/jan/workspace/opal/tmp/rubyspec_temp/rubyexe.rb < ruby/core/process/fixtures/in.txt > /home/jan/workspace/opal/tmp/rubyspec_temp/process_spawn.txt") Output:
  fails "Process.spawn when passed close_others: true does not close STDOUT" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rnode /home/jan/workspace/opal/tmp/rubyspec_temp/rubyexe.rb > /home/jan/workspace/opal/tmp/rubyspec_temp/process_spawn.txt") Output:
  fails "Process.spawn with Integer option keys maps the key to a file descriptor in the child that inherits the file descriptor from the parent specified by the value" # NotImplementedError: only limited redirection possible for fd 0, 1, 2
  fails "Process.spawn with a command array raises a TypeError if an element in the Array does not respond to #to_str" # Expected TypeError but no exception was raised (55701 was returned)
  fails "Process.spawn with a single argument raises a TypeError if the argument does not respond to #to_str" # Expected TypeError but no exception was raised (55284 was returned)
  fails "Process.spawn with multiple arguments raises a TypeError if an argument does not respond to #to_str" # Expected TypeError but no exception was raised (42716 was returned)
  fails_badly "Process.detach produces the exit Process::Status as the thread value" # NotImplementedError: NotImplementedError
  fails_badly "Process.detach provides a #pid method on the returned thread which returns the PID" # NotImplementedError: NotImplementedError
  fails_badly "Process.detach reaps the child process's status automatically" # NotImplementedError: NotImplementedError
  fails_badly "Process.detach returns a thread" # NotImplementedError: NotImplementedError
  fails_badly "Process.detach sets the :pid thread-local to the PID" # NotImplementedError: NotImplementedError
end
