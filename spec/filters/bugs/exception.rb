# NOTE: run bin/format-filters after changing this file
opal_filter "Exception" do
  fails "An Exception reaching the top level is printed on STDERR" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x590>
  fails "An Exception reaching the top level with a custom backtrace is printed on STDERR" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x590>
  fails "Errno::EAGAIN is the same class as Errno::EWOULDBLOCK if they represent the same errno value"
  fails "Errno::EINVAL.new accepts an optional custom message and location"
  fails "Errno::EINVAL.new accepts an optional custom message"
  fails "Errno::EINVAL.new can be called with no arguments"
  fails "Errno::EMFILE can be subclassed"
  fails "Errno::ENOTSUP is defined" # Expected Errno to have constant 'ENOTSUP' but it does not
  fails "Errno::ENOTSUP is the same class as Errno::EOPNOTSUPP if they represent the same errno value" # NameError: uninitialized constant Errno::ENOTSUP
  fails "Exception has the right class hierarchy" # NameError: uninitialized constant FiberError
  fails "Exception is a superclass of Interrupt"
  fails "Exception is a superclass of SystemStackError"
  fails "Exception#== returns true if both exceptions have the same class, no message, and no backtrace"
  fails "Exception#== returns true if both exceptions have the same class, the same message, and no backtrace"
  fails "Exception#== returns true if both exceptions have the same class, the same message, and the same backtrace"
  fails "Exception#== returns true if one exception is the dup'd copy of the other"
  fails "Exception#== returns true if the two objects subclass Exception and have the same message and backtrace"
  fails "Exception#backtrace captures the backtrace for an exception into $!" # Expected "RuntimeError: " =~ /backtrace_spec/ to be truthy but was nil
  fails "Exception#backtrace captures the backtrace for an exception into $@" # NoMethodError: undefined method `first' for nil
  fails "Exception#backtrace includes the filename of the location immediately prior to where self raised in the second element"
  fails "Exception#backtrace includes the filename of the location where self raised in the first element"
  fails "Exception#backtrace includes the line number of the location immediately prior to where self raised in the second element"
  fails "Exception#backtrace includes the line number of the location where self raised in the first element"
  fails "Exception#backtrace includes the name of the method from where self raised in the first element"
  fails "Exception#backtrace produces a backtrace for an exception captured using $!" # Expected "RuntimeError" to match /backtrace_spec/
  fails "Exception#backtrace returns an Array that can be updated" # Expected "RuntimeError" to equal "backtrace first"
  fails "Exception#backtrace returns nil if no backtrace was set"
  fails "Exception#backtrace returns the same array after duping"
  fails "Exception#backtrace_locations produces a backtrace for an exception captured using $!" # NoMethodError: undefined method `backtrace_locations' for #<RuntimeError: RuntimeError>
  fails "Exception#backtrace_locations returns an Array that can be updated" # NoMethodError: undefined method `backtrace_locations' for #<RuntimeError: RuntimeError>
  fails "Exception#backtrace_locations returns an Array" # NoMethodError: undefined method `backtrace_locations' for #<RuntimeError: RuntimeError>
  fails "Exception#backtrace_locations returns nil if no backtrace was set" # NoMethodError: undefined method `backtrace_locations' for #<RuntimeError: RuntimeError>
  fails "Exception#backtrace_locations sets each element to a Thread::Backtrace::Location" # NoMethodError: undefined method `backtrace_locations' for #<RuntimeError: RuntimeError>
  fails "Exception#cause is not set to the exception itself when it is re-raised" # NoMethodError: undefined method `cause' for #<RuntimeError: RuntimeError>
  fails "Exception#cause is set for internal errors caused by user errors" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
  fails "Exception#cause is set for user errors caused by internal errors" # Expected RuntimeError but no exception was raised (Infinity was returned)
  fails "Exception#cause returns the active exception when an exception is raised"
  fails "Exception#dup does copy the backtrace" # Expected [] to equal ["InitializeException: my exception", "    at TMP_13 (...)"]
  fails "Exception#dup does copy the cause" # NoMethodError: undefined method `cause' for #<RuntimeError: the consequence>
  fails "Exception#exception captures an exception into $!" # Expected "RuntimeError" == "" to be truthy but was false
  fails "Exception#full_message returns formatted string of exception using the same format that is used to print an uncaught exceptions to stderr" # NoMethodError: undefined method `full_message' for #<RuntimeError: Some runtime error>
  fails "Exception#full_message shows the caller if the exception has no backtrace"
  fails "Exception#full_message shows the exception class at the end of the first line of the message when the message contains multiple lines" # NoMethodError: undefined method `full_message' for #<RuntimeError: first line second line>
  fails "Exception#full_message supports :highlight option and adds escape sequences to highlight some strings" # NoMethodError: undefined method `full_message' for #<RuntimeError: Some runtime error>
  fails "Exception#full_message supports :order option and places the error message and the backtrace at the top or the bottom" # NoMethodError: undefined method `full_message' for #<RuntimeError: Some runtime error>
  fails "Exception#set_backtrace raises a TypeError when passed a Symbol"
  fails "Exception#set_backtrace raises a TypeError when the Array contains a Symbol"
  fails "Exception#to_s calls #to_s on the message" # Mock 'message' expected to receive 'to_s' exactly 1 times but received it 2 times
  fails "IOError is a superclass of EOFError"
  fails "Interrupt is a subclass of SignalException" # Expected Exception to equal SignalException
  fails "Interrupt.new returns an instance of interrupt with no message given" # NoMethodError: undefined method `signo' for #<Interrupt: Interrupt>:Interrupt
  fails "Interrupt.new takes an optional message argument" # NoMethodError: undefined method `signo' for #<Interrupt: message>:Interrupt
  fails "LocalJumpError#exit_value returns the value given to return" # Expected LocalJumpError but got: Exception (unexpected return)
  fails "LocalJumpError#reason returns 'return' for a return" # Expected LocalJumpError but got: Exception (unexpected return)
  fails "NameError#dup copies the name and receiver" # NoMethodError: undefined method `receiver' for #<NoMethodError: undefined method `foo' for #<MSpecEnv:0x262>>
  fails "NameError#name returns a class variable name as a symbol"
  fails "NameError#receiver returns a class when an undefined class variable is called in a subclass' namespace"
  fails "NameError#receiver returns a class when an undefined constant is called"
  fails "NameError#receiver returns the Object class when an undefined class variable is called"
  fails "NameError#receiver returns the Object class when an undefined constant is called without namespace"
  fails "NameError#receiver returns the object that raised the exception"
  fails "NameError#receiver returns the receiver when raised from #class_variable_get"
  fails "NameError#receiver returns the receiver when raised from #instance_variable_get"
  fails "NameError#to_s raises its own message for an undefined variable" # Expected "undefined method `not_defined' for #<MSpecEnv:0x54e>" =~ /undefined local variable or method `not_defined'/ to be truthy but was nil
  fails "NoMethodError#dup copies the name, arguments and receiver" # NoMethodError: undefined method `receiver' for #<NoMethodError: undefined method `foo' for #<Object:0x230>>
  fails "SignalException can be rescued" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x278>
  fails "SignalException cannot be trapped with Signal.trap" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x278>
  fails "SignalException runs after at_exit" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x278>
  fails "SignalException self-signals for USR1" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x278>
  fails "SignalException#signm returns the signal name" # Expected SignalException but got: NoMethodError (undefined method `kill' for Process)
  fails "SignalException#signo returns the signal number" # Expected SignalException but got: NoMethodError (undefined method `kill' for Process)
  fails "SignalException.new raises an exception for an optional argument with a signal name"
  fails "SignalException.new raises an exception with an invalid signal name"
  fails "SignalException.new raises an exception with an invalid signal number"
  fails "SignalException.new takes a signal name with SIG prefix as the first argument"
  fails "SignalException.new takes a signal name without SIG prefix as the first argument"
  fails "SignalException.new takes a signal number as the first argument"
  fails "SignalException.new takes a signal symbol with SIG prefix as the first argument"
  fails "SignalException.new takes a signal symbol without SIG prefix as the first argument"
  fails "SignalException.new takes an optional message argument with a signal number"
  fails "StopIteration#result returns the method-returned-object from an Enumerator"
  fails "SystemCallError#backtrace is nil if not raised" # Expected ["SystemCallError: message",  "  from ruby/core/exception/system_call_error_spec.rb:141:5:in `new'",  "  from corelib/basic_object.rb:119:1:in `$instance_exec'",  "  from corelib/runtime.js:1729:5:in `Opal.send2'",  "  from corelib/runtime.js:1719:5:in `Opal.send'",  "  from mspec/runner/mspec.rb:114:7:in `instance_exec'",  "  from corelib/runtime.js:1729:5:in `Opal.send2'",  "  from corelib/runtime.js:1719:5:in `Opal.send'",  "  from mspec/runner/context.rb:176:34:in `protect'",  "  from corelib/runtime.js:1518:5:in `Opal.yieldX'",  "  from corelib/enumerable.rb:27:16:in `$$3'"] == nil to be truthy but was false
  fails "SystemCallError#dup copies the errno" # NoMethodError: undefined method `errno' for #<SystemCallError: message>
  fails "SystemCallError#errno returns nil when no errno given"
  fails "SystemCallError#errno returns the errno given as optional argument to new"
  fails "SystemCallError#message returns the default message when no message is given"
  fails "SystemCallError.=== returns false if errnos different" # NoMethodError: undefined method `+' for Errno
  fails "SystemCallError.=== returns true if errnos same" # Expected false == true to be truthy but was false
  fails "SystemCallError.new accepts an optional custom message preceding the errno"
  fails "SystemCallError.new accepts an optional third argument specifying the location"
  fails "SystemCallError.new accepts single Fixnum argument as errno"
  fails "SystemCallError.new accepts single Integer argument as errno" # NoMethodError: undefined method `errno' for #<SystemCallError: -16777216>
  fails "SystemCallError.new coerces location if it is not a String" # Expected "foo" =~ /@ not_a_string - foo/ to be truthy but was nil
  fails "SystemCallError.new constructs the appropriate Errno class"
  fails "SystemCallError.new converts to Integer if errno is a Complex convertible to Integer" # Expected #<SystemCallError: foo> == #<SystemCallError: foo> to be truthy but was false
  fails "SystemCallError.new converts to Integer if errno is a Float" # Expected #<SystemCallError: foo> == #<SystemCallError: foo> to be truthy but was false
  fails "SystemCallError.new raises RangeError if errno is a Complex not convertible to Integer" # Expected RangeError (/can't convert/) but no exception was raised (#<SystemCallError: foo> was returned)
  fails "SystemCallError.new raises TypeError if errno is not an Integer" # Expected TypeError (/no implicit conversion of String into Integer/) but no exception was raised (#<SystemCallError: foo> was returned)
  fails "SystemCallError.new raises TypeError if message is not a String" # Expected TypeError (/no implicit conversion of Symbol into String/) but no exception was raised (#<SystemCallError: foo> was returned)
  fails "SystemCallError.new requires at least one argument"
  fails "SystemExit sets the exit status and exits silently when raised when subclassed" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x542>
  fails "SystemExit sets the exit status and exits silently when raised" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x542>
  fails "SystemStackError is a subclass of Exception"
  fails "UncaughtThrowError#tag returns the object thrown" # NoMethodError: undefined method `tag' for #<UncaughtThrowError: uncaught throw "abc">:UncaughtThrowError
  fails "rescueing Interrupt raises an Interrupt when sent a signal SIGINT" # NoMethodError: undefined method `kill' for Process
  fails "rescueing SignalException raises a SignalException when sent a signal"
  fails_badly "SystemExit#status returns the exit status"
  fails_badly "SystemExit#success? returns false if the process exited unsuccessfully"
  fails_badly "SystemExit#success? returns true if the process exited successfully"
end
