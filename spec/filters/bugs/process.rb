# NOTE: run bin/format-filters after changing this file
opal_filter "Process" do
  fails "Process#last_status returns nil if no child process has been ever executed in the current thread" # NotImplementedError: Thread creation not available
  fails "Process#last_status returns the status of the last executed child process in the current thread" # NotImplementedError: NotImplementedError
  fails "Process.argv0 is the path given as the main script and the same as __FILE__" # NotImplementedError: NotImplementedError
  fails "Process.clock_getres with :GETRUSAGE_BASED_CLOCK_PROCESS_CPUTIME_ID reports 1 microsecond" # NotImplementedError: NotImplementedError
  fails "Process.clock_getres with :GETTIMEOFDAY_BASED_CLOCK_REALTIME reports 1 microsecond" # NotImplementedError: NotImplementedError
  fails "Process.clock_getres with :TIME_BASED_CLOCK_REALTIME reports 1 second" # NotImplementedError: NotImplementedError
  fails "Process.clock_getres with Process::CLOCK_MONOTONIC reports at least 10 millisecond" # NotImplementedError: NotImplementedError
  fails "Process.clock_getres with Process::CLOCK_REALTIME reports at least 10 millisecond" # NotImplementedError: NotImplementedError
  fails "Process.clock_gettime supports the platform clocks mentioned in the documentation CLOCK_MONOTONIC_COARSE" # NameError: uninitialized constant Process::CLOCK_MONOTONIC_COARSE
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
  fails "Process.detach produces the exit Process::Status as the thread value" # NotImplementedError: NotImplementedError
  fails "Process.detach provides a #pid method on the returned thread which returns the PID" # NotImplementedError: NotImplementedError
  fails "Process.detach raises TypeError when #to_int returns non-Integer value" # Expected TypeError (can't convert MockObject to Integer (MockObject#to_int gives Symbol)) but got: NotImplementedError (NotImplementedError)
  fails "Process.detach raises TypeError when pid argument does not have #to_int method" # Expected TypeError (no implicit conversion of Object into Integer) but got: NotImplementedError (NotImplementedError)
  fails "Process.detach reaps the child process's status automatically" # NotImplementedError: NotImplementedError
  fails "Process.detach returns a thread" # NotImplementedError: NotImplementedError
  fails "Process.detach sets the :pid thread-local to the PID" # NotImplementedError: NotImplementedError
  fails "Process.detach tolerates not existing child process pid" # NameError: uninitialized constant Errno::ESRCH
  fails "Process.exit raises the SystemExit in the main thread if it reaches the top-level handler of another thread" # NotImplementedError: Thread creation not available
  fails "Process.exit! exits when called from a fiber" # Expected exit status is 21 but actual is 1 for command ruby_exe("bundle exec opal /home/jan/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Process.exit! exits when called from a thread" # Expected exit status is 21 but actual is 1 for command ruby_exe("bundle exec opal /home/jan/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Process.exit! overrides the original exception and exit status when called from #at_exit" # Expected exit status is 21 but actual is 1 for command ruby_exe("bundle exec opal /home/jan/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
  fails "Process.exit! skips ensure clauses" # Expected "" ==  "before " to be truthy but was false
  fails "Process.getpgid coerces the argument to an Integer" # NoMethodError: undefined method `arguments' for #<MockIntObject:0x144 @value=39456 @calls=0>
  fails "Process.getpgid returns the process group ID for the calling process id when passed 0" # NotImplementedError: NotImplementedError
  fails "Process.getpgid returns the process group ID for the given process id" # NotImplementedError: NotImplementedError
  fails "Process.getpriority coerces arguments to Integers" # NameError: uninitialized constant Process::PRIO_PROCESS
  fails "Process.getpriority gets the scheduling priority for a specified process group" # NameError: uninitialized constant Process::PRIO_PGRP
  fails "Process.getpriority gets the scheduling priority for a specified process" # NameError: uninitialized constant Process::PRIO_PROCESS
  fails "Process.getpriority gets the scheduling priority for a specified user" # NameError: uninitialized constant Process::PRIO_USER
  fails "Process.getrlimit returns a two-element Array of Integers" # NameError: uninitialized constant Process::RLIMIT_CORE
  fails "Process.getrlimit when passed a String coerces the short name into the full RLIMIT_ prefixed name" # No behavior expectation was found in the example
  fails "Process.getrlimit when passed a String raises ArgumentError when passed an unknown resource" # Expected ArgumentError but got: NotImplementedError (NotImplementedError)
  fails "Process.getrlimit when passed a Symbol coerces the short name into the full RLIMIT_ prefixed name" # No behavior expectation was found in the example
  fails "Process.getrlimit when passed a Symbol raises ArgumentError when passed an unknown resource" # Expected ArgumentError but got: NotImplementedError (NotImplementedError)
  fails "Process.getrlimit when passed an Object calls #to_int to convert to an Integer" # NameError: uninitialized constant Process::RLIMIT_CORE
  fails "Process.getrlimit when passed an Object raises a TypeError if #to_int does not return an Integer" # NameError: uninitialized constant Process::RLIMIT_CORE
  fails "Process.getrlimit when passed on Object calls #to_int if #to_str does not return a String" # NameError: uninitialized constant Process::RLIMIT_CORE
  fails "Process.getrlimit when passed on Object calls #to_str to convert to a String" # NameError: uninitialized constant Process::RLIMIT_CORE
  fails "Process.initgroups initializes the supplemental group access list" # Expected Errno::EPERM but got: NotImplementedError (NotImplementedError)
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
  fails "Process.maxgroups returns the maximum number of gids allowed in the supplemental group access list" # NotImplementedError: NotImplementedError
  fails "Process.maxgroups sets the maximum number of gids allowed in the supplemental group access list" # NotImplementedError: NotImplementedError
  fails "Process.ppid returns the process id of the parent of this process" # NotImplementedError: NotImplementedError
  fails "Process.setpgid sets the process group id of the specified process" # NotImplementedError: NotImplementedError
  fails "Process.setpgrp and Process.getpgrp sets and gets the process group ID of the calling process" # NotImplementedError: NotImplementedError
  fails "Process.setpriority sets the scheduling priority for a specified process group" # NameError: uninitialized constant Process::PRIO_PGRP
  fails "Process.setpriority sets the scheduling priority for a specified process" # NameError: uninitialized constant Process::PRIO_PROCESS
  fails "Process.setrlimit when passed a String coerces 'AS' into RLIMIT_AS" # NameError: uninitialized constant Process::RLIMIT_AS
  fails "Process.setrlimit when passed a String coerces 'CORE' into RLIMIT_CORE" # NameError: uninitialized constant Process::RLIMIT_CORE
  fails "Process.setrlimit when passed a String coerces 'CPU' into RLIMIT_CPU" # NameError: uninitialized constant Process::RLIMIT_CPU
  fails "Process.setrlimit when passed a String coerces 'DATA' into RLIMIT_DATA" # NameError: uninitialized constant Process::RLIMIT_DATA
  fails "Process.setrlimit when passed a String coerces 'FSIZE' into RLIMIT_FSIZE" # NameError: uninitialized constant Process::RLIMIT_FSIZE
  fails "Process.setrlimit when passed a String coerces 'MEMLOCK' into RLIMIT_MEMLOCK" # NameError: uninitialized constant Process::RLIMIT_MEMLOCK
  fails "Process.setrlimit when passed a String coerces 'MSGQUEUE' into RLIMIT_MSGQUEUE" # NameError: uninitialized constant Process::RLIMIT_MSGQUEUE
  fails "Process.setrlimit when passed a String coerces 'NICE' into RLIMIT_NICE" # NameError: uninitialized constant Process::RLIMIT_NICE
  fails "Process.setrlimit when passed a String coerces 'NOFILE' into RLIMIT_NOFILE" # NameError: uninitialized constant Process::RLIMIT_NOFILE
  fails "Process.setrlimit when passed a String coerces 'NPROC' into RLIMIT_NPROC" # NameError: uninitialized constant Process::RLIMIT_NPROC
  fails "Process.setrlimit when passed a String coerces 'RSS' into RLIMIT_RSS" # NameError: uninitialized constant Process::RLIMIT_RSS
  fails "Process.setrlimit when passed a String coerces 'RTPRIO' into RLIMIT_RTPRIO" # NameError: uninitialized constant Process::RLIMIT_RTPRIO
  fails "Process.setrlimit when passed a String coerces 'SIGPENDING' into RLIMIT_SIGPENDING" # NameError: uninitialized constant Process::RLIMIT_SIGPENDING
  fails "Process.setrlimit when passed a String coerces 'STACK' into RLIMIT_STACK" # NameError: uninitialized constant Process::RLIMIT_STACK
  fails "Process.setrlimit when passed a String raises ArgumentError when passed an unknown resource" # Expected ArgumentError but got: NotImplementedError (NotImplementedError)
  fails "Process.setrlimit when passed a Symbol coerces :AS into RLIMIT_AS" # NameError: uninitialized constant Process::RLIMIT_AS
  fails "Process.setrlimit when passed a Symbol coerces :CORE into RLIMIT_CORE" # NameError: uninitialized constant Process::RLIMIT_CORE
  fails "Process.setrlimit when passed a Symbol coerces :CPU into RLIMIT_CPU" # NameError: uninitialized constant Process::RLIMIT_CPU
  fails "Process.setrlimit when passed a Symbol coerces :DATA into RLIMIT_DATA" # NameError: uninitialized constant Process::RLIMIT_DATA
  fails "Process.setrlimit when passed a Symbol coerces :FSIZE into RLIMIT_FSIZE" # NameError: uninitialized constant Process::RLIMIT_FSIZE
  fails "Process.setrlimit when passed a Symbol coerces :MEMLOCK into RLIMIT_MEMLOCK" # NameError: uninitialized constant Process::RLIMIT_MEMLOCK
  fails "Process.setrlimit when passed a Symbol coerces :MSGQUEUE into RLIMIT_MSGQUEUE" # NameError: uninitialized constant Process::RLIMIT_MSGQUEUE
  fails "Process.setrlimit when passed a Symbol coerces :NICE into RLIMIT_NICE" # NameError: uninitialized constant Process::RLIMIT_NICE
  fails "Process.setrlimit when passed a Symbol coerces :NOFILE into RLIMIT_NOFILE" # NameError: uninitialized constant Process::RLIMIT_NOFILE
  fails "Process.setrlimit when passed a Symbol coerces :NPROC into RLIMIT_NPROC" # NameError: uninitialized constant Process::RLIMIT_NPROC
  fails "Process.setrlimit when passed a Symbol coerces :RSS into RLIMIT_RSS" # NameError: uninitialized constant Process::RLIMIT_RSS
  fails "Process.setrlimit when passed a Symbol coerces :RTPRIO into RLIMIT_RTPRIO" # NameError: uninitialized constant Process::RLIMIT_RTPRIO
  fails "Process.setrlimit when passed a Symbol coerces :SIGPENDING into RLIMIT_SIGPENDING" # NameError: uninitialized constant Process::RLIMIT_SIGPENDING
  fails "Process.setrlimit when passed a Symbol coerces :STACK into RLIMIT_STACK" # NameError: uninitialized constant Process::RLIMIT_STACK
  fails "Process.setrlimit when passed a Symbol raises ArgumentError when passed an unknown resource" # Expected ArgumentError but got: NotImplementedError (NotImplementedError)
  fails "Process.setrlimit when passed an Object calls #to_int to convert resource to an Integer" # NameError: uninitialized constant Process::RLIMIT_CORE
  fails "Process.setrlimit when passed an Object calls #to_int to convert the hard limit to an Integer" # NameError: uninitialized constant Process::RLIMIT_CORE
  fails "Process.setrlimit when passed an Object calls #to_int to convert the soft limit to an Integer" # NameError: uninitialized constant Process::RLIMIT_CORE
  fails "Process.setrlimit when passed an Object raises a TypeError if #to_int for resource does not return an Integer" # NameError: uninitialized constant Process::RLIMIT_CORE
  fails "Process.setrlimit when passed on Object calls #to_int if #to_str does not return a String" # NameError: uninitialized constant Process::RLIMIT_CORE
  fails "Process.setrlimit when passed on Object calls #to_str to convert to a String" # NameError: uninitialized constant Process::RLIMIT_CORE
  fails "Process.setsid establishes this process as a new session and process group leader" # NotImplementedError: NotImplementedError
  fails "Process.uid= raises Errno::ERPERM if run by a non privileged user trying to set the superuser id from username" # Expected Errno::EPERM but got: TypeError (no implicit conversion of String into Integer)
  fails "Process.waitall returns an array of pid/status pairs" # Expected nil (NilClass) to be kind of Array
  fails "Process.waitall returns an empty array when there are no children" # Expected nil == [] to be truthy but was false
  fails "Process.waitall waits for all children" # Expected Errno::ESRCH but no exception was raised (1 was returned)
  fails "Process.waitpid returns nil when the process has not yet completed and WNOHANG is specified" # NameError: uninitialized constant Process::WNOHANG
end
