# NOTE: run bin/format-filters after changing this file
opal_filter "Exception" do
  fails "An Exception reaching the top level is printed on STDERR" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x66584>
  fails "An Exception reaching the top level the Exception#cause is printed to STDERR with backtraces" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x66584>
  fails "An Exception reaching the top level with a custom backtrace is printed on STDERR" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x66584>
  fails "Errno::EAGAIN is the same class as Errno::EWOULDBLOCK if they represent the same errno value" # NameError: uninitialized constant Errno::EAGAIN
  fails "Errno::EINVAL.new accepts an optional custom message and location" # ArgumentError: [EINVAL.new] wrong number of arguments(2 for -1)
  fails "Errno::EINVAL.new accepts an optional custom message" # NoMethodError: undefined method `errno' for #<Errno::EINVAL: Invalid argument - custom message>
  fails "Errno::EINVAL.new can be called with no arguments" # NoMethodError: undefined method `errno' for #<Errno::EINVAL: Invalid argument>
  fails "Errno::ENOTSUP is defined" # Expected Errno to have constant 'ENOTSUP' but it does not
  fails "Errno::ENOTSUP is the same class as Errno::EOPNOTSUPP if they represent the same errno value" # NameError: uninitialized constant Errno::ENOTSUP
  fails "Exception#== returns true if both exceptions have the same class, no message, and no backtrace" # Expected #<RuntimeError: RuntimeError> == #<RuntimeError: RuntimeError> to be truthy but was false
  fails "Exception#== returns true if both exceptions have the same class, the same message, and no backtrace" # Expected #<TypeError: message> == #<TypeError: message> to be truthy but was false
  fails "Exception#== returns true if both exceptions have the same class, the same message, and the same backtrace" # Expected #<TypeError: message> == #<TypeError: message> to be truthy but was false
  fails "Exception#== returns true if one exception is the dup'd copy of the other" # Expected #<ArgumentError: ArgumentError> == #<ArgumentError: ArgumentError> to be truthy but was false
  fails "Exception#== returns true if the two objects subclass Exception and have the same message and backtrace" # Expected #<ExceptionSpecs::UnExceptional: ExceptionSpecs::UnExceptional> == #<ExceptionSpecs::UnExceptional: ExceptionSpecs::UnExceptional> to be truthy but was false
  fails "Exception#backtrace captures the backtrace for an exception into $!" # Expected "<internal:corelib/kernel.rb>:536:23:in `new'" =~ /backtrace_spec/ to be truthy but was nil
  fails "Exception#backtrace captures the backtrace for an exception into $@" # Expected "<internal:corelib/kernel.rb>:536:23:in `new'" =~ /backtrace_spec/ to be truthy but was nil
  fails "Exception#backtrace includes the filename of the location immediately prior to where self raised in the second element" # Expected "ruby/core/exception/fixtures/common.rb:7:9:in `raise'" =~ /backtrace_spec\.rb/ to be truthy but was nil
  fails "Exception#backtrace includes the filename of the location where self raised in the first element" # Expected "<internal:corelib/kernel.rb>:536:23:in `new'" =~ /common\.rb/ to be truthy but was nil
  fails "Exception#backtrace includes the line number of the location immediately prior to where self raised in the second element" # Expected "ruby/core/exception/fixtures/common.rb:7:9:in `raise'" =~ /:6(:in )?/ to be truthy but was nil
  fails "Exception#backtrace includes the line number of the location where self raised in the first element" # Expected "<internal:corelib/kernel.rb>:536:23:in `new'" =~ /:7:in / to be truthy but was nil
  fails "Exception#backtrace includes the name of the method from where self raised in the first element" # Expected "<internal:corelib/kernel.rb>:536:23:in `new'" =~ /in `backtrace'/ to be truthy but was nil
  fails "Exception#backtrace returns nil if no backtrace was set" # Expected ["ruby/core/exception/backtrace_spec.rb:10:5:in `new'", "<internal:corelib/basic_object.rb>:119:1:in `instance_exec'", "<internal:corelib/runtime.js>:1780:5:in `Opal.send2'", "<internal:corelib/runtime.js>:1770:5:in `Opal.send'", "mspec/runner/mspec.rb:114:7:in `instance_exec'", "<internal:corelib/runtime.js>:1780:5:in `Opal.send2'", "<internal:corelib/runtime.js>:1770:5:in `Opal.send'", "mspec/runner/context.rb:176:34:in `protect'", "<internal:corelib/runtime.js>:1569:5:in `Opal.yieldX'", "<internal:corelib/enumerable.rb>:27:16:in `$$3'"] to be nil
  fails "Exception#backtrace_locations produces a backtrace for an exception captured using $!" # Expected "<internal:corelib/kernel.rb>" =~ /backtrace_locations_spec/ to be truthy but was nil
  fails "Exception#backtrace_locations returns nil if no backtrace was set" # Expected ["ruby/core/exception/backtrace_locations_spec.rb:10:5:in `new'", "<internal:corelib/basic_object.rb>:119:1:in `instance_exec'", "<internal:corelib/runtime.js>:1780:5:in `Opal.send2'", "<internal:corelib/runtime.js>:1770:5:in `Opal.send'", "mspec/runner/mspec.rb:114:7:in `instance_exec'", "<internal:corelib/runtime.js>:1780:5:in `Opal.send2'", "<internal:corelib/runtime.js>:1770:5:in `Opal.send'", "mspec/runner/context.rb:176:34:in `protect'", "<internal:corelib/runtime.js>:1569:5:in `Opal.yieldX'", "<internal:corelib/enumerable.rb>:27:16:in `$$3'"] to be nil
  fails "Exception#cause is set for internal errors caused by user errors" # Expected ZeroDivisionError but no exception was raised (Infinity was returned)
  fails "Exception#cause is set for user errors caused by internal errors" # Expected RuntimeError but no exception was raised (Infinity was returned)
  fails "Exception#exception captures an exception into $!" # Expected "RuntimeError" == "" to be truthy but was false
  fails "Exception#full_message contains all the chain of exceptions" # Expected  "<internal:corelib/kernel.rb>:539:23:in `new': \e[1mlast exception (\e[1;4mRuntimeError\e[1m)\e[m \tfrom ruby/core/exception/full_message_spec.rb:81:11:in `raise' \tfrom <internal:corelib/basic_object.rb>:119:1:in `instance_exec' \tfrom <internal:corelib/runtime.js>:1780:5:in `Opal.send2' \tfrom <internal:corelib/runtime.js>:1770:5:in `Opal.send' \tfrom mspec/runner/mspec.rb:114:7:in `instance_exec' \tfrom <internal:corelib/runtime.js>:1780:5:in `Opal.send2' \tfrom <internal:corelib/runtime.js>:1770:5:in `Opal.send' \tfrom mspec/runner/context.rb:176:34:in `protect' \tfrom <internal:corelib/runtime.js>:1569:5:in `Opal.yieldX' <internal:corelib/kernel.rb>:539:23:in `new': \e[1morigin exception (\e[1;4mRuntimeError\e[1m)\e[m \tfrom ruby/core/exception/full_message_spec.rb:76:13:in `raise' \tfrom <internal:corelib/basic_object.rb>:119:1:in `instance_exec' \tfrom <internal:corelib/runtime.js>:1780:5:in `Opal.send2' \tfrom <internal:corelib/runtime.js>:1770:5:in `Opal.send' \tfrom mspec/runner/mspec.rb:114:7:in `instance_exec' \tfrom <internal:corelib/runtime.js>:1780:5:in `Opal.send2' \tfrom <internal:corelib/runtime.js>:1770:5:in `Opal.send' \tfrom mspec/runner/context.rb:176:34:in `protect' \tfrom <internal:corelib/runtime.js>:1569:5:in `Opal.yieldX' " to include "intermediate exception"
  fails "Exception#full_message shows the caller if the exception has no backtrace" # Expected ["ruby/core/exception/full_message_spec.rb:37:11:in `new'",  "<internal:corelib/basic_object.rb>:119:1:in `instance_exec'",  "<internal:corelib/runtime.js>:1780:5:in `Opal.send2'",  "<internal:corelib/runtime.js>:1770:5:in `Opal.send'",  "mspec/runner/mspec.rb:114:7:in `instance_exec'",  "<internal:corelib/runtime.js>:1780:5:in `Opal.send2'",  "<internal:corelib/runtime.js>:1770:5:in `Opal.send'",  "mspec/runner/context.rb:176:34:in `protect'",  "<internal:corelib/runtime.js>:1569:5:in `Opal.yieldX'",  "<internal:corelib/enumerable.rb>:27:16:in `$$3'"] == nil to be truthy but was false
  fails "Exception#full_message shows the exception class at the end of the first line of the message when the message contains multiple lines" # Expected  "<internal:corelib/kernel.rb>:539:23:in `new': first line " to include "ruby/core/exception/full_message_spec.rb:46:in `"
  fails "Exception#full_message supports :order option and places the error message and the backtrace at the top or the bottom" # Expected  "a.rb:1: Some runtime error (RuntimeError) \tfrom b.rb:2 " =~ /a.rb:1.*b.rb:2/m to be truthy but was nil
  fails "Exception#set_backtrace raises a TypeError when passed a Symbol" # Expected TypeError but no exception was raised ("unhappy" was returned)
  fails "Exception#set_backtrace raises a TypeError when the Array contains a Symbol" # Expected TypeError but no exception was raised (["String", "unhappy"] was returned)
  fails "Exception#to_s calls #to_s on the message" # Mock 'message' expected to receive to_s("any_args") exactly 1 times but received it 2 times
  fails "Interrupt is raised on the main Thread by the default SIGINT handler" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6b5e8>
  fails "Interrupt.new returns an instance of interrupt with no message given" # NoMethodError: undefined method `signo' for #<Interrupt: Interrupt>
  fails "Interrupt.new takes an optional message argument" # NoMethodError: undefined method `signo' for #<Interrupt: message>
  fails "KeyError accepts :receiver and :key options" # ArgumentError: no receiver is available
  fails "LocalJumpError#exit_value returns the value given to return" # Expected LocalJumpError but got: Exception (unexpected return)
  fails "LocalJumpError#reason returns 'return' for a return" # Expected LocalJumpError but got: Exception (unexpected return)
  fails "NameError#dup copies the name and receiver" # NoMethodError: undefined method `receiver' for #<NoMethodError: undefined method `foo' for #<MSpecEnv:0x69be8>>
  fails "NameError#name returns a class variable name as a symbol" # Expected "binding" == "@@doesnt_exist" to be truthy but was false
  fails "NameError#receiver returns a class when an undefined class variable is called in a subclass' namespace" # NoMethodError: undefined method `receiver' for #<NameError: uninitialized class variable @@doesnt_exist in NameErrorSpecs::ReceiverClass>
  fails "NameError#receiver returns a class when an undefined constant is called" # NoMethodError: undefined method `receiver' for #<NameError: uninitialized constant NameErrorSpecs::ReceiverClass::DoesntExist>
  fails "NameError#receiver returns the Object class when an undefined class variable is called" # NoMethodError: undefined method `receiver' for #<NoMethodError: undefined method `binding' for #<MSpecEnv:0x6665c>>
  fails "NameError#receiver returns the Object class when an undefined constant is called without namespace" # NoMethodError: undefined method `receiver' for #<NameError: uninitialized constant DoesntExist>
  fails "NameError#receiver returns the object that raised the exception" # NoMethodError: undefined method `receiver' for #<NoMethodError: undefined method `doesnt_exist' for #<Object:0x6667e>>
  fails "NameError#receiver returns the receiver when raised from #class_variable_get" # NoMethodError: undefined method `receiver' for #<NameError: `invalid_cvar_name' is not allowed as a class variable name>
  fails "NameError#receiver returns the receiver when raised from #instance_variable_get" # NoMethodError: undefined method `receiver' for #<NameError: 'invalid_ivar_name' is not allowed as an instance variable name>
  fails "NameError#to_s raises its own message for an undefined variable" # Expected "undefined method `not_defined' for #<MSpecEnv:0x19344>" =~ /undefined local variable or method `not_defined'/ to be truthy but was nil
  fails "NameError.new accepts a :receiver keyword argument" # ArgumentError: [NameError#initialize] wrong number of arguments(3 for -2)
  fails "NoMethodError#dup copies the name, arguments and receiver" # NoMethodError: undefined method `receiver' for #<NoMethodError: undefined method `foo' for #<Object:0x31eb8>>
  fails "NoMethodError#message uses #name to display the receiver if it is a class or a module" # Expected "undefined method `foo' for #<Class:0x31e84>" == "undefined method `foo' for MyClass:Class" to be truthy but was false
  fails "NoMethodError.new accepts a :receiver keyword argument" # NoMethodError: undefined method `receiver' for #<NoMethodError: msg>
  fails "SignalException can be rescued" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x626ae>
  fails "SignalException cannot be trapped with Signal.trap" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x626ae>
  fails "SignalException runs after at_exit" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x626ae>
  fails "SignalException self-signals for USR1" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x626ae>
  fails "SignalException#signm returns the signal name" # Expected SignalException but got: NoMethodError (undefined method `kill' for Process)
  fails "SignalException#signo returns the signal number" # Expected SignalException but got: NoMethodError (undefined method `kill' for Process)
  fails "SignalException.new raises an exception for an optional argument with a signal name" # Expected ArgumentError but no exception was raised (#<SignalException: INT> was returned)
  fails "SignalException.new raises an exception with an invalid first argument type" # Expected ArgumentError but no exception was raised (#<SignalException: #<Object:0x6271c>> was returned)
  fails "SignalException.new raises an exception with an invalid signal name" # Expected ArgumentError but no exception was raised (#<SignalException: NONEXISTENT> was returned)
  fails "SignalException.new raises an exception with an invalid signal number" # Expected ArgumentError but no exception was raised (#<SignalException: 100000> was returned)
  fails "SignalException.new takes a signal name with SIG prefix as the first argument" # NoMethodError: undefined method `signo' for #<SignalException: SIGINT>
  fails "SignalException.new takes a signal name without SIG prefix as the first argument" # NoMethodError: undefined method `signo' for #<SignalException: INT>
  fails "SignalException.new takes a signal number as the first argument" # NoMethodError: undefined method `list' for Signal
  fails "SignalException.new takes a signal symbol with SIG prefix as the first argument" # NoMethodError: undefined method `signo' for #<SignalException: SIGINT>
  fails "SignalException.new takes a signal symbol without SIG prefix as the first argument" # NoMethodError: undefined method `signo' for #<SignalException: INT>
  fails "SignalException.new takes an optional message argument with a signal number" # NoMethodError: undefined method `list' for Signal
  fails "StopIteration#result returns the method-returned-object from an Enumerator" # NoMethodError: undefined method `next' for #<Enumerator: #<Object:0x4fb42>:each>
  fails "SystemCallError#backtrace is nil if not raised" # Expected ["ruby/core/exception/system_call_error_spec.rb:141:5:in `new'",  "<internal:corelib/basic_object.rb>:119:1:in `instance_exec'",  "<internal:corelib/runtime.js>:1780:5:in `Opal.send2'",  "<internal:corelib/runtime.js>:1770:5:in `Opal.send'",  "mspec/runner/mspec.rb:114:7:in `instance_exec'",  "<internal:corelib/runtime.js>:1780:5:in `Opal.send2'",  "<internal:corelib/runtime.js>:1770:5:in `Opal.send'",  "mspec/runner/context.rb:176:34:in `protect'",  "<internal:corelib/runtime.js>:1569:5:in `Opal.yieldX'",  "<internal:corelib/enumerable.rb>:27:16:in `$$3'"] == nil to be truthy but was false
  fails "SystemCallError#dup copies the errno" # NoMethodError: undefined method `errno' for #<SystemCallError: message>
  fails "SystemCallError#errno returns nil when no errno given" # NoMethodError: undefined method `errno' for #<SystemCallError: message>
  fails "SystemCallError#errno returns the errno given as optional argument to new" # NoMethodError: undefined method `errno' for #<SystemCallError: message>
  fails "SystemCallError#message returns the default message when no message is given" # Expected "268435456" =~ /Unknown error/i to be truthy but was nil
  fails "SystemCallError.=== returns false if errnos different" # NoMethodError: undefined method `+' for Errno
  fails "SystemCallError.=== returns true if errnos same" # Expected false == true to be truthy but was false
  fails "SystemCallError.new accepts an optional custom message preceding the errno" # Expected #<SystemCallError: custom message> (SystemCallError) to be an instance of Errno::EINVAL
  fails "SystemCallError.new accepts an optional third argument specifying the location" # Expected #<SystemCallError: custom message> (SystemCallError) to be an instance of Errno::EINVAL
  fails "SystemCallError.new accepts single Integer argument as errno" # NoMethodError: undefined method `errno' for #<SystemCallError: -16777216>
  fails "SystemCallError.new coerces location if it is not a String" # Expected "foo" =~ /@ not_a_string - foo/ to be truthy but was nil
  fails "SystemCallError.new constructs the appropriate Errno class" # Expected #<SystemCallError: Errno> (SystemCallError) to be an instance of Errno::EINVAL
  fails "SystemCallError.new converts to Integer if errno is a Complex convertible to Integer" # Expected #<SystemCallError: foo> == #<SystemCallError: foo> to be truthy but was false
  fails "SystemCallError.new converts to Integer if errno is a Float" # Expected #<SystemCallError: foo> == #<SystemCallError: foo> to be truthy but was false
  fails "SystemCallError.new raises RangeError if errno is a Complex not convertible to Integer" # Expected RangeError (/can't convert/) but no exception was raised (#<SystemCallError: foo> was returned)
  fails "SystemCallError.new raises TypeError if errno is not an Integer" # Expected TypeError (/no implicit conversion of String into Integer/) but no exception was raised (#<SystemCallError: foo> was returned)
  fails "SystemCallError.new raises TypeError if message is not a String" # Expected TypeError (/no implicit conversion of Symbol into String/) but no exception was raised (#<SystemCallError: foo> was returned)
  fails "SystemCallError.new requires at least one argument" # Expected ArgumentError but no exception was raised (#<SystemCallError: SystemCallError> was returned)
  fails "SystemExit sets the exit status and exits silently when raised when subclassed" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6edd2>
  fails "SystemExit sets the exit status and exits silently when raised" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6edd2>
  fails_badly "SystemExit#status returns the exit status"
  fails_badly "SystemExit#success? returns false if the process exited unsuccessfully"
  fails_badly "SystemExit#success? returns true if the process exited successfully"
end
