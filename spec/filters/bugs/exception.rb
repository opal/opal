# NOTE: run bin/format-filters after changing this file
opal_filter "Exception" do
  fails "Errno::EAGAIN is the same class as Errno::EWOULDBLOCK if they represent the same errno value"
  fails "Errno::EINVAL.new accepts an optional custom message and location"
  fails "Errno::EINVAL.new accepts an optional custom message"
  fails "Errno::EINVAL.new can be called with no arguments"
  fails "Errno::EMFILE can be subclassed"
  fails "Exception is a superclass of Interrupt"
  fails "Exception is a superclass of SystemStackError"
  fails "Exception#== returns true if both exceptions have the same class, no message, and no backtrace"
  fails "Exception#== returns true if both exceptions have the same class, the same message, and no backtrace"
  fails "Exception#== returns true if both exceptions have the same class, the same message, and the same backtrace"
  fails "Exception#== returns true if one exception is the dup'd copy of the other"
  fails "Exception#== returns true if the two objects subclass Exception and have the same message and backtrace"
  fails "Exception#backtrace contains lines of the same format for each prior position in the stack"
  fails "Exception#backtrace includes the filename of the location immediately prior to where self raised in the second element"
  fails "Exception#backtrace includes the filename of the location where self raised in the first element"
  fails "Exception#backtrace includes the line number of the location immediately prior to where self raised in the second element"
  fails "Exception#backtrace includes the line number of the location where self raised in the first element"
  fails "Exception#backtrace includes the name of the method from where self raised in the first element"
  fails "Exception#backtrace produces a backtrace for an exception captured using $!" # Expected "RuntimeError" to match /backtrace_spec/
  fails "Exception#backtrace returns an Array that can be updated" # Expected "RuntimeError" to equal "backtrace first"
  fails "Exception#backtrace returns nil if no backtrace was set"
  fails "Exception#backtrace_locations produces a backtrace for an exception captured using $!" # NoMethodError: undefined method `backtrace_locations' for #<RuntimeError: RuntimeError>
  fails "Exception#backtrace_locations returns an Array that can be updated" # NoMethodError: undefined method `backtrace_locations' for #<RuntimeError: RuntimeError>
  fails "Exception#backtrace_locations returns an Array" # NoMethodError: undefined method `backtrace_locations' for #<RuntimeError: RuntimeError>
  fails "Exception#backtrace_locations returns nil if no backtrace was set" # NoMethodError: undefined method `backtrace_locations' for #<RuntimeError: RuntimeError>
  fails "Exception#backtrace_locations sets each element to a Thread::Backtrace::Location" # NoMethodError: undefined method `backtrace_locations' for #<RuntimeError: RuntimeError>
  fails "Exception#cause is set for internal errors caused by user errors" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
  fails "Exception#cause is set for user errors caused by internal errors" # Expected RuntimeError but no exception was raised (Infinity was returned)
  fails "Exception#cause returns the active exception when an exception is raised"
  fails "Exception#dup does copy the backtrace" # Expected [] to equal ["InitializeException: my exception", "    at TMP_13 (...)"]
  fails "Exception#dup does copy the cause" # NoMethodError: undefined method `cause' for #<RuntimeError: the consequence>
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
  fails "NameError#name returns a class variable name as a symbol"
  fails "NameError#receiver returns a class when an undefined class variable is called in a subclass' namespace"
  fails "NameError#receiver returns a class when an undefined constant is called"
  fails "NameError#receiver returns the Object class when an undefined class variable is called"
  fails "NameError#receiver returns the Object class when an undefined constant is called without namespace"
  fails "NameError#receiver returns the object that raised the exception"
  fails "NameError#receiver returns the receiver when raised from #class_variable_get"
  fails "NameError#receiver returns the receiver when raised from #instance_variable_get"
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
  fails "SystemCallError#errno returns nil when no errno given"
  fails "SystemCallError#errno returns the errno given as optional argument to new"
  fails "SystemCallError#message returns the default message when no message is given"
  fails "SystemCallError.new accepts an optional custom message preceding the errno"
  fails "SystemCallError.new accepts an optional third argument specifying the location"
  fails "SystemCallError.new accepts single Fixnum argument as errno"
  fails "SystemCallError.new constructs the appropriate Errno class"
  fails "SystemCallError.new requires at least one argument"
  fails "SystemStackError is a subclass of Exception"
  fails "UncaughtThrowError#tag returns the object thrown" # NoMethodError: undefined method `tag' for #<UncaughtThrowError: uncaught throw "abc">:UncaughtThrowError
  fails "rescueing Interrupt raises an Interrupt when sent a signal SIGINT" # NoMethodError: undefined method `kill' for Process
  fails "rescueing SignalException raises a SignalException when sent a signal"
end
