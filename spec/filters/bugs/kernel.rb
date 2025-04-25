# NOTE: run bin/format-filters after changing this file
opal_filter "Kernel" do
  fails "Kernel#=== does not call #object_id nor #equal? but still returns true for #== or #=== on the same object" # Mock '#<Object:0x2514>' expected to receive object_id("any_args") exactly 0 times but received it 2 times
  fails "Kernel#Float for hexadecimal literals with binary exponent allows embedded _ in a number on either side of the P" # ArgumentError: invalid value for Float(): "0x1_0P10"
  fails "Kernel#Float for hexadecimal literals with binary exponent allows embedded _ in a number on either side of the p" # ArgumentError: invalid value for Float(): "0x1_0p10"
  fails "Kernel#Float for hexadecimal literals with binary exponent allows hexadecimal points on the left side of the 'P'" # ArgumentError: invalid value for Float(): "0x1.8P0"
  fails "Kernel#Float for hexadecimal literals with binary exponent allows hexadecimal points on the left side of the 'p'" # ArgumentError: invalid value for Float(): "0x1.8p0"
  fails "Kernel#Float for hexadecimal literals with binary exponent interprets the exponent (on the right of 'P') in decimal" # ArgumentError: invalid value for Float(): "0x1P10"
  fails "Kernel#Float for hexadecimal literals with binary exponent interprets the exponent (on the right of 'p') in decimal" # ArgumentError: invalid value for Float(): "0x1p10"
  fails "Kernel#Float for hexadecimal literals with binary exponent interprets the fractional part (on the left side of 'P') in hexadecimal" # ArgumentError: invalid value for Float(): "0x10P0"
  fails "Kernel#Float for hexadecimal literals with binary exponent interprets the fractional part (on the left side of 'p') in hexadecimal" # ArgumentError: invalid value for Float(): "0x10p0"
  fails "Kernel#Float for hexadecimal literals with binary exponent returns 0 for '0x1P-10000'" # ArgumentError: invalid value for Float(): "0x1P-10000"
  fails "Kernel#Float for hexadecimal literals with binary exponent returns 0 for '0x1p-10000'" # ArgumentError: invalid value for Float(): "0x1p-10000"
  fails "Kernel#Float for hexadecimal literals with binary exponent returns Infinity for '0x1P10000'" # ArgumentError: invalid value for Float(): "0x1P10000"
  fails "Kernel#Float for hexadecimal literals with binary exponent returns Infinity for '0x1p10000'" # ArgumentError: invalid value for Float(): "0x1p10000"
  fails "Kernel#String calls #to_s if #respond_to?(:to_s) returns true" # TypeError: no implicit conversion of MockObject into String
  fails "Kernel#String raises a TypeError if #to_s is not defined, even though #respond_to?(:to_s) returns true" # Expected TypeError but got: NoMethodError (undefined method `to_s' for #<Object:0x2961a>)
  fails "Kernel#__dir__ returns the expanded path of the directory when used in the main script" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x2b0e6>
  fails "Kernel#__dir__ returns the real name of the directory containing the currently-executing file" # Expected "ruby/core/kernel" == "/home/jan/workspace/opal/spec/ruby/core/kernel" to be truthy but was false
  fails "Kernel#__dir__ when used in eval with top level binding returns nil" # Expected "." == nil to be truthy but was false
  fails "Kernel#autoload calls main.require(path) to load the file" # Expected NameError but got: LoadError (cannot load such file -- main_autoload_not_exist)
  fails "Kernel#autoload can autoload in instance_eval" # NoMethodError: undefined method `autoload' for #<Object:0x4b3d2>
  fails "Kernel#autoload inside a Class.new method body should define on the new anonymous class" # NoMethodError: undefined method `autoload' for #<#<Class:0x4b3ee>:0x4b3ec>
  fails "Kernel#autoload is a private method" # Expected Kernel to have private instance method 'autoload' but it does not
  fails "Kernel#autoload when Object is frozen raises a FrozenError before defining the constant" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x4b3b4 @loaded_features=["corelib/runtime", "opal", "opal/base"...]>
  fails "Kernel#autoload? is a private method" # Expected Kernel to have private instance method 'autoload?' but it does not
  fails "Kernel#autoload? returns nil if no file has been registered for a constant" # NoMethodError: undefined method `autoload?' for #<MSpecEnv:0x4b3b4 @loaded_features=["corelib/runtime", "opal", "opal/base"...]>
  fails "Kernel#autoload? returns the name of the file that will be autoloaded" # NoMethodError: undefined method `autoload?' for #<MSpecEnv:0x4b3b4 @loaded_features=["corelib/runtime", "opal", "opal/base"...]>
  fails "Kernel#caller includes core library methods defined in Ruby" # Expected "<internal:corelib/kernel.rb>:829:5:in `send2'".end_with? "in `tap'" to be truthy but was false
  fails "Kernel#caller is a private method" # Expected Kernel to have private instance method 'caller' but it does not
  fails "Kernel#caller returns an Array of caller locations using a custom offset" # Expected "ruby/core/kernel/fixtures/caller.rb:4:7:in `locations'" =~ /runner\/mspec.rb/ to be truthy but was nil
  fails "Kernel#caller returns an Array of caller locations using a range" # Expected 0 == 1 to be truthy but was false
  fails "Kernel#caller returns an Array with the block given to #at_exit at the base of the stack" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0xafc18>
  fails "Kernel#caller returns the locations as String instances" # Expected "ruby/core/kernel/fixtures/caller.rb:4:7:in `locations'" to include "ruby/core/kernel/caller_spec.rb:32:in"
  fails "Kernel#caller works with beginless ranges" # Expected nil == ["<internal:corelib/basic_object.rb>:125:1:in `instance_exec'",  "mspec/runner/mspec.rb:116:11:in `protect'",  "mspec/runner/context.rb:176:39:in `$$17'",  "<internal:corelib/enumerable.rb>:27:16:in `$$3'"] to be truthy but was false
  fails "Kernel#caller works with endless ranges" # Expected [] == ["<internal:corelib/basic_object.rb>:125:1:in `instance_exec'",  "mspec/runner/mspec.rb:116:11:in `protect'",  "mspec/runner/context.rb:176:39:in `$$17'",  "<internal:corelib/enumerable.rb>:27:16:in `$$3'",  "<internal:corelib/array.rb>:983:1:in `each'",  "<internal:corelib/enumerable.rb>:26:7:in `Enumerable_all$ques$1'",  "mspec/runner/context.rb:176:18:in `protect'",  "mspec/runner/context.rb:212:26:in `$$21'",  "mspec/runner/mspec.rb:284:7:in `repeat'",  "mspec/runner/context.rb:204:16:in `$$20'",  "<internal:corelib/array.rb>:983:1:in `each'",  "mspec/runner/context.rb:203:18:in `process'",  "mspec/runner/mspec.rb:55:10:in `describe'",  "mspec/runner/object.rb:11:10:in `describe'",  "ruby/core/kernel/caller_spec.rb:4:1:in `Opal.modules.ruby/core/kernel/caller_spec'",  "<internal:corelib/kernel.rb>:535:6:in `load'",  "mspec/runner/mspec.rb:99:42:in `instance_exec'",  "<internal:corelib/basic_object.rb>:125:1:in `instance_exec'",  "mspec/runner/mspec.rb:116:11:in `protect'",  "mspec/runner/mspec.rb:99:7:in `$$1'",  "<internal:corelib/array.rb>:983:1:in `each'",  "mspec/runner/mspec.rb:90:12:in `each_file'",  "mspec/runner/mspec.rb:95:5:in `files'",  "mspec/runner/mspec.rb:63:5:in `process'",  "tmp/mspec_nodejs.rb:3887:6:in `undefined'",  "tmp/mspec_nodejs.rb:1:1:in `null'",  "node:internal/modules/cjs/loader:1105:14:in `Module._compile'",  "node:internal/modules/cjs/loader:1159:10:in `Module._extensions..js'",  "node:internal/modules/cjs/loader:981:32:in `Module.load'",  "node:internal/modules/cjs/loader:822:12:in `Module._load'",  "node:internal/modules/run_main:77:12:in `executeUserEntryPoint'",  "node:internal/main/run_main_module:17:47:in `undefined'"] to be truthy but was false
  fails "Kernel#class returns the class of the object" # Expected Number to be identical to Integer
  fails "Kernel#clone replaces a singleton object's metaclass with a new copy with the same superclass" # NoMethodError: undefined method `singleton_methods' for #<#<Class:0x5537a>:0x55378>
  fails "Kernel#clone uses the internal allocator and does not call #allocate" # RuntimeError: allocate should not be called
  fails "Kernel#clone with freeze: anything else raises ArgumentError when passed not true/false/nil" # Expected ArgumentError (unexpected value for freeze: Integer) but got: ArgumentError (unexpected value for freeze: Number)
  fails "Kernel#clone with freeze: false calls #initialize_clone with kwargs freeze: false even if #initialize_clone only takes a single argument" # Expected ArgumentError (wrong number of arguments (given 2, expected 1)) but got: ArgumentError ([Clone#initialize_clone] wrong number of arguments (given 2, expected 1))
  fails "Kernel#clone with freeze: true calls #initialize_clone with kwargs freeze: true even if #initialize_clone only takes a single argument" # Expected ArgumentError (wrong number of arguments (given 2, expected 1)) but got: ArgumentError ([Clone#initialize_clone] wrong number of arguments (given 2, expected 1))
  fails "Kernel#dup uses the internal allocator and does not call #allocate" # RuntimeError: allocate should not be called
  fails "Kernel#eval allows a binding to be captured inside an eval" # NoMethodError: undefined method `w' for #<MSpecEnv:0x4be5a>
  fails "Kernel#eval allows creating a new class in a binding" # RuntimeError: Evaluation on a Proc#binding is not supported
  fails "Kernel#eval can be aliased" # NoMethodError: undefined method `+' for nil
  fails "Kernel#eval does not make Proc locals visible to evaluated code" # Expected NameError but got: RuntimeError (Evaluation on a Proc#binding is not supported)
  fails "Kernel#eval does not share locals across eval scopes" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x4be5a>
  fails "Kernel#eval doesn't accept a Proc object as a binding" # Expected TypeError but got: NoMethodError (undefined method `js_eval' for #<Proc:0x4c92e>)
  fails "Kernel#eval evaluates string with given filename and negative linenumber" # Expected "unexpected token $end" =~ /speccing.rb:-100:.+/ to be truthy but was nil
  fails "Kernel#eval includes file and line information in syntax error" # Expected "unexpected token $end" =~ /speccing.rb:1:.+/ to be truthy but was nil
  fails "Kernel#eval raises a LocalJumpError if there is no lambda-style closure in the chain" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x4be5a>
  fails "Kernel#eval returns from the method calling #eval when evaluating 'return' in BEGIN" # SyntaxError: Unsupported sexp: preexe
  fails "Kernel#eval unwinds through a Proc-style closure and returns from a lambda-style closure in the closure chain" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x4be5a>
  fails "Kernel#eval updates a local in a scope above a surrounding block scope" # Expected 1 == 2 to be truthy but was false
  fails "Kernel#eval updates a local in a scope above when modified in a nested block scope" # NoMethodError: undefined method `es' for #<MSpecEnv:0x4be5a>
  fails "Kernel#eval updates a local in a surrounding block scope" # Expected 1 == 2 to be truthy but was false
  fails "Kernel#eval updates a local in an enclosing scope" # Expected 1 == 2 to be truthy but was false
  fails "Kernel#eval uses the same scope for local variables when given the same binding" # NoMethodError: undefined method `a' for #<MSpecEnv:0x4be5a>
  fails "Kernel#eval with a magic encoding comment allows a magic encoding comment and a frozen_string_literal magic comment on the same line in emacs style" # Expected ["A", "CoercedObject"] to include "Vπsame_line"
  fails "Kernel#eval with a magic encoding comment allows a magic encoding comment and a subsequent frozen_string_literal magic comment" # Expected ["A", "CoercedObject"] to include "Vπstring"
  fails "Kernel#eval with a magic encoding comment allows a shebang line and some spaces before the magic encoding comment" # Expected ["A", "CoercedObject"] to include "Vπshebang_spaces"
  fails "Kernel#eval with a magic encoding comment allows a shebang line before the magic encoding comment" # Expected ["A", "CoercedObject"] to include "Vπshebang"
  fails "Kernel#eval with a magic encoding comment allows an emacs-style magic comment encoding" # Expected ["A", "CoercedObject"] to include "Vπemacs"
  fails "Kernel#eval with a magic encoding comment allows spaces before the magic encoding comment" # Expected ["A", "CoercedObject"] to include "Vπspaces"
  fails "Kernel#eval with a magic encoding comment ignores the frozen_string_literal magic comment if it appears after a token and warns if $VERBOSE is true" # Expected warning to match: /warning: `frozen_string_literal' is ignored after any tokens/ but got: ""
  fails "Kernel#eval with a magic encoding comment ignores the magic encoding comment if it is after a frozen_string_literal magic comment" # Expected ["A", "CoercedObject"] to include "Vπfrozen_first"
  fails "Kernel#eval with a magic encoding comment uses the magic comment encoding for parsing constants" # Expected ["A", "CoercedObject"] to include "Vπ"
  fails "Kernel#eval with refinements activates refinements from the binding" # NoMethodError: undefined method `foo' for #<EvalSpecs::A:0x4f966>
  fails "Kernel#eval with refinements activates refinements from the eval scope" # NoMethodError: undefined method `foo' for #<EvalSpecs::A:0x4fa98>
  fails "Kernel#extend does not calls append_features on arguments metaclass" # Expected true == false to be truthy but was false
  fails "Kernel#fail accepts an Object with an exception method returning an Exception" # Expected StandardError (...) but got: TypeError (exception class/object expected)
  fails "Kernel#freeze causes mutative calls to raise RuntimeError" # Expected RuntimeError but no exception was raised (1 was returned)
  fails "Kernel#initialize_copy does nothing if the argument is the same as the receiver" # Expected nil.equal? #<Object:0x3cb42> to be truthy but was false
  fails "Kernel#initialize_copy raises FrozenError if the receiver is frozen" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Kernel#initialize_copy raises TypeError if the objects are of different class" # Expected TypeError (initialize_copy should take same class object) but no exception was raised (nil was returned)
  fails "Kernel#initialize_copy returns self" # Expected nil.equal? #<Object:0x66548> to be truthy but was false
  fails "Kernel#inspect returns a String for an object without #class method" # NoMethodError: undefined method `class' for #<Object:0x42c12>
  fails "Kernel#instance_variable_set on frozen objects accepts unicode instance variable names" # NameError: '@💙' is not allowed as an instance variable name
  fails "Kernel#instance_variable_set on frozen objects raises for frozen objects" # Expected NameError but got: FrozenError (can't modify frozen NilClass: )
  fails "Kernel#instance_variables immediate values returns the correct array if an instance variable is added" # Expected RuntimeError but got: Exception (Cannot create property 'test' on number '0')
  fails "Kernel#is_a? does not take into account `class` method overriding" # TypeError: can't define singleton
  fails "Kernel#kind_of? does not take into account `class` method overriding" # TypeError: can't define singleton
  fails "Kernel#local_variables is accessible from bindings" # Expected [] to include "a"
  fails "Kernel#method converts the given name to a String using #to_str calls #to_str to convert the given name to a String" # Mock 'method-name' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "Kernel#method converts the given name to a String using #to_str raises a NoMethodError if the given argument raises a NoMethodError during type coercion to a String" # Expected NoMethodError but got: NameError (undefined method `#<MockObject:0x9e5a6>' for class `Class')
  fails "Kernel#method converts the given name to a String using #to_str raises a TypeError if the given name can't be converted to a String" # Expected TypeError but got: NameError (undefined method `' for class `Class')
  fails "Kernel#method will see an alias of the original method as == when in a derived class" # Expected #<Method: KernelSpecs::B#aliased_pub_method (defined in KernelSpecs::B in ruby/core/kernel/fixtures/classes.rb:164)> == #<Method: KernelSpecs::B#pub_method (defined in KernelSpecs::A in ruby/core/kernel/fixtures/classes.rb:164)> to be truthy but was false
  fails "Kernel#methods does not return private singleton methods defined in 'class << self'" # Expected ["ichi", "san", "shi", "roku", "shichi", "hachi", "juu", "juu_ichi", "juu_ni"] not to include "shichi"
  fails "Kernel#object_id returns a different value for two Bignum literals" # Expected 295330 == 295330 to be falsy but was true
  fails "Kernel#object_id returns a different value for two String literals" # Expected 133036 == 133036 to be falsy but was true
  fails "Kernel#open accepts options as keyword arguments" # Expected ArgumentError (wrong number of arguments (given 4, expected 1..3)) but no exception was raised (<File:fd 27> was returned)
  fails "Kernel#open is a private method" # Expected Kernel to have private instance method 'open' but it does not
  fails "Kernel#open is not redefined by open-uri" # NotImplementedError: NotImplementedError
  fails "Kernel#open opens an io for writing" # Expected (STDOUT): "."           but got: "" Backtrace
  fails "Kernel#open opens an io when called with a block" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open '|date'
  fails "Kernel#open opens an io when path starts with a pipe" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, open '|date'
  fails "Kernel#open when given an object that responds to to_open passes keyword arguments onto #to_open as keyword arguments if to_open accepts them" # ArgumentError: [MSpecEnv#open] wrong number of arguments (given 5, expected -2)
  fails "Kernel#pp lazily loads the 'pp' library and delegates the call to that library" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x572a>
  fails "Kernel#print prints $_ when no arguments are given" # Expected:   $stdout: "foo"       got:   $stdout: ""
  fails "Kernel#public_method changes the method called for super on a target aliased method" # NoMethodError: undefined method `public_method' for #<#<Class:0x5a558>:0x5a556>
  fails "Kernel#public_method raises a NameError if we only repond_to_missing? method, true" # Expected NameError but no exception was raised ("Done public_method(handled_privately)" was returned)
  fails "Kernel#public_method returns a method object for a valid method" # NoMethodError: undefined method `public_method' for #<KernelSpecs::Foo:0x5a56c>
  fails "Kernel#public_method returns a method object for a valid singleton method" # NoMethodError: undefined method `public_method' for KernelSpecs::Foo
  fails "Kernel#public_method returns a method object if respond_to_missing?(method) is true" # Expected "Done public_method(handled_publicly)" (String) to be an instance of Method
  fails "Kernel#public_method the returned method object if respond_to_missing?(method) calls #method_missing with a Symbol name" # Expected "Done public_method(handled_publicly)" (String) to be an instance of Method
  fails "Kernel#public_methods returns a list of names without protected accessible methods in the object" # Expected ["hachi", "ichi", "juu", "juu_ichi", "juu_ni", "roku", "san", "shi", "shichi"] not to include "juu_ichi"
  fails "Kernel#public_methods when passed false returns a list of public methods in without its ancestors" # Expected ["f_pub", "f_pro", "f_pri"] == ["f_pub"] to be truthy but was false
  fails "Kernel#public_methods when passed nil returns a list of public methods in without its ancestors" # Expected ["f_pub", "f_pro", "f_pri"] == ["f_pub"] to be truthy but was false
  fails "Kernel#public_send includes `public_send` in the backtrace when passed a single incorrect argument" # Expected "method=\"public_send\" @object=nil> is not a symbol nor a string:in `TypeError: #<MSpecEnv:0x5399c '".include? "`public_send'" to be truthy but was false
  fails "Kernel#public_send includes `public_send` in the backtrace when passed not enough arguments" # Expected "<internal:corelib/runtime.js>:1546:5:in `Opal.ac'".include? "`public_send'" to be truthy but was false
  fails "Kernel#putc is a private instance method" # Expected Kernel to have private instance method 'putc' but it does not
  fails "Kernel#raise accepts a cause keyword argument that overrides the last exception" # Expected #<RuntimeError: first raise> == #<StandardError: StandardError> to be truthy but was false
  fails "Kernel#raise accepts a cause keyword argument that sets the cause" # Expected nil == #<StandardError: StandardError> to be truthy but was false
  fails "Kernel#raise passes no arguments to the constructor when given only an exception class" # Expected #<Class:0x5390e> but got: ArgumentError ([#initialize] wrong number of arguments (given 1, expected 0))
  fails "Kernel#raise raises an ArgumentError when only cause is given" # Expected ArgumentError but got: TypeError (exception class/object expected)
  fails "Kernel#raise re-raises a previously rescued exception without overwriting the backtrace" # Expected "<internal:corelib/kernel.rb>:612:37:in `raise'" to include "ruby/shared/kernel/raise.rb:130:"
  fails "Kernel#rand is a private method" # Expected Kernel to have private instance method 'rand' but it does not
  fails "Kernel#rand is random on boot" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x19c2a>
  fails "Kernel#rand supports custom object types" # Expected "NaN#<struct KernelSpecs::CustomRangeInteger value=1>" (String) to be an instance of KernelSpecs::CustomRangeInteger
  fails "Kernel#readline is a private method" # Expected Kernel to have private instance method 'readline' but it does not
  fails "Kernel#readlines is a private method" # Expected Kernel to have private instance method 'readlines' but it does not
  fails "Kernel#remove_instance_variable raises a FrozenError if self is frozen" # Expected FrozenError but got: NameError (instance variable @foo not defined)
  fails "Kernel#remove_instance_variable raises for frozen objects" # Expected FrozenError but got: NameError (instance variable @foo not defined)
  fails "Kernel#respond_to? throws a type error if argument can't be coerced into a Symbol" # Expected TypeError (/is not a symbol nor a string/) but no exception was raised (false was returned)
  fails "Kernel#respond_to_missing? causes #respond_to? to return false if called and returning nil" # Expected nil to be false
  fails "Kernel#respond_to_missing? causes #respond_to? to return true if called and not returning false" # Expected "glark" to be true
  fails "Kernel#singleton_class for an IO object with a replaced singleton class looks up singleton methods from the fresh singleton class after an object instance got a new one" # NoMethodError: undefined method `reopen' for #<File:0x6c204 @fd="ruby/core/kernel/singleton_class_spec.rb" @flags="r" @eof=false @closed="write">
  fails "Kernel#singleton_class raises TypeError for Symbol" # Expected TypeError but no exception was raised (#<Class:#<String:0x53aaa>> was returned)
  fails "Kernel#singleton_class raises TypeError for a frozen deduplicated String" # Expected TypeError (can't define singleton) but no exception was raised (#<Class:#<String:0x6c200>> was returned)
  fails "Kernel#singleton_method find a method defined on the singleton class" # NoMethodError: undefined method `singleton_method' for #<Object:0x4540a>
  fails "Kernel#singleton_method only looks at singleton methods and not at methods in the class" # Expected NoMethodError == NameError to be truthy but was false
  fails "Kernel#singleton_method raises a NameError if there is no such method" # Expected NoMethodError == NameError to be truthy but was false
  fails "Kernel#singleton_method returns a Method which can be called" # NoMethodError: undefined method `singleton_method' for #<Object:0x453d6>
  fails "Kernel#singleton_methods when not passed an argument does not return private singleton methods for an object extended with a module including a module" # Expected ["n_pub", "n_pro", "n_pri", "m_pub", "m_pro", "m_pri", "pub", "pro", "pri"] not to include "m_pri"
  fails "Kernel#singleton_methods when passed true does not return private singleton methods for an object extended with a module including a module" # Expected ["n_pub", "n_pro", "n_pri", "m_pub", "m_pro", "m_pri", "pub", "pro", "pri"] not to include "m_pri"
  fails "Kernel#sleep accepts any Object that reponds to divmod" # TypeError: can't convert Object into time interval
  fails "Kernel#sprintf %c raises error when a codepoint isn't representable in an encoding of a format string" # Expected RangeError (out of char range) but no exception was raised ("Ԇ" was returned)
  fails "Kernel#sprintf %c uses the encoding of the format string to interpret codepoints" # Exception: Invalid code point 9415601
  fails "Kernel#sprintf can produce a string with invalid encoding" # Expected #<Encoding:ASCII-8BIT> == #<Encoding:UTF-8> to be truthy but was false
  fails "Kernel#sprintf integer formats d works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "Kernel#sprintf integer formats i works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "Kernel#sprintf integer formats u works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "Kernel#sprintf other formats c raises TypeError if argument is nil" # Expected TypeError (no implicit conversion from nil to integer) but got: TypeError (no implicit conversion of NilClass into Integer)
  fails "Kernel#sprintf other formats c raises TypeError if converting to Integer with to_int returns non-Integer" # Expected TypeError (can't convert BasicObject to Integer) but got: TypeError (can't convert BasicObject into Integer (BasicObject#to_int gives String))
  fails "Kernel#sprintf other formats c raises TypeError if converting to String with to_str returns non-String" # Expected TypeError (can't convert BasicObject to String) but no exception was raised ("f" was returned)
  fails "Kernel#sprintf raises Encoding::CompatibilityError if both encodings are ASCII compatible and there are not ASCII characters" # Expected CompatibilityError but no exception was raised ("Ä Ђ" was returned)
  fails "Kernel#sprintf returns a String in the same encoding as the format String if compatible" # Expected #<Encoding:UTF-8> to be identical to #<Encoding:KOI8_U (dummy)>
  fails "Kernel#srand is a private method" # Expected Kernel to have private instance method 'srand' but it does not
  fails "Kernel#srand returns the system-initialized seed value on the first call" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x46d76 @seed=6933182541716747>
  fails "Kernel#system is a private method" # Expected Kernel to have private instance method 'system' but it does not
  fails "Kernel#warn :uplevel keyword argument converts first arg using to_s" # Expected:   $stderr: /core\/kernel\/fixtures\/classes.rb:453: warning: false/       got:   $stderr:  "ruby/core/kernel/fixtures/classes.rb:453:7: warning: false "
  fails "Kernel#warn :uplevel keyword argument converts value to Integer" # TypeError: no implicit conversion of Number into Integer
  fails "Kernel#warn :uplevel keyword argument prepends a message with specified line from the backtrace" # Expected:   $stderr: /core\/kernel\/fixtures\/classes.rb:453: warning: foo/       got:   $stderr:  "ruby/core/kernel/fixtures/classes.rb:453:7: warning: foo "
  fails "Kernel#warn :uplevel keyword argument prepends even if a message is empty or nil" # Expected:   $stderr: /core\/kernel\/fixtures\/classes.rb:453: warning: \n$/       got:   $stderr:  "ruby/core/kernel/fixtures/classes.rb:453:7: warning:  "
  fails "Kernel#warn :uplevel keyword argument raises if :category keyword is not nil and not convertible to symbol" # Expected TypeError but no exception was raised (nil was returned)
  fails "Kernel#warn :uplevel keyword argument shows the caller of #require and not #require itself with RubyGems loaded" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0xa4104 @before_verbose=nil @before_separator="\n">
  fails "Kernel#warn :uplevel keyword argument shows the caller of #require and not #require itself without RubyGems" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0xa4104 @before_verbose=nil @before_separator="\n">
  fails "Kernel#warn :uplevel keyword argument skips <internal: core library methods defined in Ruby" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0xa4104 @before_verbose=nil @before_separator="\n">
  fails "Kernel#warn avoids recursion if Warning#warn is redefined and calls super" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0xa4104 @before_verbose=nil @before_separator="\n">
  fails "Kernel#warn does not call Warning.warn if self is the Warning module" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0xa4104 @before_verbose=nil @before_separator="\n">
  fails "Kernel#warn writes each array element on a line when passes an array" # Expected:   $stderr:  "line 1 line 2 "       got:   $stderr:  "[\"line 1\", \"line 2\"] "
  fails "Kernel.Complex() when passed Numerics n1 and n2 and at least one responds to #real? with false returns n1 + n2 * Complex(0, 1)" # Expected #<Complex>(#pretty_inspect raised #<ArgumentError: comparison of NumericMockObject with 0 failed>) to be identical to #<NumericMockObject:0x4a1ea @name="n4" @null=nil>
  fails "Kernel.Complex() when passed [Complex, Complex] returns a new Complex number based on the two given numbers" # Expected #<Complex>(#pretty_inspect raised #<NoMethodError: undefined method `positive?' for (5+6i)>) == (-3+9i) to be truthy but was false
  fails "Kernel.Complex() when passed [Complex] returns the passed Complex number" # Expected ((1+2i)+0i) == (1+2i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] ignores leading whitespaces" # Expected ("  79+4i"+0i) == (79+4i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] ignores trailing whitespaces" # Expected ("79+4i  "+0i) == (79+4i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] invalid argument and exception: false passed raises Encoding::CompatibilityError if String is in not ASCII-compatible encoding" # Expected CompatibilityError (ASCII incompatible encoding: UTF-16) but got: ArgumentError (unknown encoding name - UTF-16)
  fails "Kernel.Complex() when passed [String] invalid argument and exception: false passed returns nil for Float::INFINITY" # Expected #<Complex>(#pretty_inspect raised #<NoMethodError: undefined method `positive?' for {"exception"=>false}>) == nil to be truthy but was false
  fails "Kernel.Complex() when passed [String] invalid argument and exception: false passed returns nil for Float::NAN" # Expected #<Complex>(#pretty_inspect raised #<NoMethodError: undefined method `positive?' for {"exception"=>false}>) == nil to be truthy but was false
  fails "Kernel.Complex() when passed [String] invalid argument and exception: false passed returns nil for unrecognised Strings" # Expected #<Complex>(#pretty_inspect raised #<NoMethodError: undefined method `positive?' for {"exception"=>false}>) == nil to be truthy but was false
  fails "Kernel.Complex() when passed [String] invalid argument and exception: false passed returns nil when String contains null-byte" # Expected #<Complex>(#pretty_inspect raised #<NoMethodError: undefined method `positive?' for {"exception"=>false}>) == nil to be truthy but was false
  fails "Kernel.Complex() when passed [String] invalid argument and exception: false passed returns nil when there is a sequence of _" # Expected #<Complex>(#pretty_inspect raised #<NoMethodError: undefined method `positive?' for {"exception"=>false}>) == nil to be truthy but was false
  fails "Kernel.Complex() when passed [String] invalid argument and exception: false passed returns nil when trailing garbage" # Expected #<Complex>(#pretty_inspect raised #<NoMethodError: undefined method `positive?' for {"exception"=>false}>) == nil to be truthy but was false
  fails "Kernel.Complex() when passed [String] invalid argument does not allow null-byte" # Expected ArgumentError (string contains null byte) but no exception was raised (("1-2i\u0000"+0i) was returned)
  fails "Kernel.Complex() when passed [String] invalid argument does not understand Float::INFINITY" # Expected ArgumentError (invalid value for convert(): "Infinity") but no exception was raised (("Infinity"+0i) was returned)
  fails "Kernel.Complex() when passed [String] invalid argument does not understand Float::NAN" # Expected ArgumentError (invalid value for convert(): "NaN") but no exception was raised (("NaN"+0i) was returned)
  fails "Kernel.Complex() when passed [String] invalid argument does not understand a sequence of _" # Expected ArgumentError (invalid value for convert(): "7__9+4__0i") but no exception was raised (("7__9+4__0i"+0i) was returned)
  fails "Kernel.Complex() when passed [String] invalid argument raises ArgumentError for trailing garbage" # Expected ArgumentError (invalid value for convert(): "79+4iruby") but no exception was raised (("79+4iruby"+0i) was returned)
  fails "Kernel.Complex() when passed [String] invalid argument raises ArgumentError for unrecognised Strings" # Expected ArgumentError (invalid value for convert(): "ruby") but no exception was raised (("ruby"+0i) was returned)
  fails "Kernel.Complex() when passed [String] invalid argument raises Encoding::CompatibilityError if String is in not ASCII-compatible encoding" # Expected CompatibilityError (ASCII incompatible encoding: UTF-16) but got: ArgumentError (unknown encoding name - UTF-16)
  fails "Kernel.Complex() when passed [String] understands 'a+bi' to mean a complex number with 'a' as the real part, 'b' as the imaginary" # Expected ("79+4i"+0i) == (79+4i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands 'a+i' to mean a complex number with 'a' as the real part, 1i as the imaginary" # Expected ("79+i"+0i) == (79+1i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands 'a-bi' to mean a complex number with 'a' as the real part, '-b' as the imaginary" # Expected ("79-4i"+0i) == (79-4i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands 'a-i' to mean a complex number with 'a' as the real part, -1i as the imaginary" # Expected ("79-i"+0i) == (79-1i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands 'm@a' to mean a complex number in polar form with 'm' as the modulus, 'a' as the argument" # Expected ("79@4"+0i) == (-51.63784604822534-59.78739712932633i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands _" # Expected ("7_9+4_0i"+0i) == (79+40i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands a '-i' by itself as denoting a complex number with an imaginary part of -1" # Expected ("-i"+0i) == (0-1i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands a negative integer followed by 'i' to mean that negative integer is the imaginary part" # Expected ("-29i"+0i) == (0-29i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands an 'i' by itself as denoting a complex number with an imaginary part of 1" # Expected ("i"+0i) == (0+1i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands an integer followed by 'i' to mean that integer is the imaginary part" # Expected ("35i"+0i) == (0+35i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands floats (a.b) for the imaginary part" # Expected ("4+2.3i"+0i) == (4+2.3i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands floats (a.b) for the real part" # Expected ("2.3"+0i) == (2.3+0i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands fractions (numerator/denominator) for the imaginary part" # Expected ("4+2/3i"+0i) == (4+(2/3)i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands fractions (numerator/denominator) for the real part" # Expected ("2/3"+0i) == ((2/3)+0i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands i, I, j, and J imaginary units" # Expected ("79+4i"+0i) == (79+4i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands integers" # Expected ("20"+0i) == (20+0i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands negative floats (-a.b) for the imaginary part" # Expected ("7-28.771i"+0i) == (7-28.771i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands negative floats (-a.b) for the real part" # Expected ("-2.33"+0i) == (-2.33+0i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands negative fractions (-numerator/denominator) for the imaginary part" # Expected ("7-2/3i"+0i) == (7-(2/3)i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands negative fractions (-numerator/denominator) for the real part" # Expected ("-2/3"+0i) == ((-2/3)+0i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands negative integers" # Expected ("-3"+0i) == (-3+0i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands negative scientific notation for the imaginary part" # Expected ("4-2e3i"+0i) == (4-2000i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands negative scientific notation for the real and imaginary part in the same String" # Expected ("-2e3-2e4i"+0i) == (-2000-20000i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands negative scientific notation for the real part" # Expected ("-2e3+4i"+0i) == (-2000+4i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands scientific notation for the imaginary part" # Expected ("4+2e3i"+0i) == (4+2000i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands scientific notation for the real and imaginary part in the same String" # Expected ("2e3+2e4i"+0i) == (2000+20000i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands scientific notation for the real part" # Expected ("2e3+4i"+0i) == (2000+4i) to be truthy but was false
  fails "Kernel.Complex() when passed [String] understands scientific notation with e and E" # Expected ("2e3+2e4i"+0i) == (2000+20000i) to be truthy but was false
  fails "Kernel.Complex() when passed a Numeric which responds to #real? with false returns the passed argument" # Expected (#<NumericMockObject:0x4a1b8 @name="unreal" @null=nil>+0i) to be identical to #<NumericMockObject:0x4a1b8 @name="unreal" @null=nil>
  fails "Kernel.Complex() when passed a non-Numeric second argument raises TypeError" # Expected TypeError but no exception was raised (#<Complex>(#pretty_inspect raised #<NoMethodError: undefined method `positive?' for "sym">) was returned)
  fails "Kernel.Complex() when passed a single non-Numeric coerces the passed argument using #to_c" # Expected (#<MockObject:0x4a298 @name="n" @null=nil>+0i) to be identical to (0+0i)
  fails "Kernel.Complex() when passed an Object which responds to #to_c returns the passed argument" # Expected (#<Object:0x4a18a>+0i) == (0+1i) to be truthy but was false
  fails "Kernel.Complex() when passed exception: false and [Numeric] returns a complex number" # Expected #<Complex>(#pretty_inspect raised #<NoMethodError: undefined method `positive?' for {"exception"=>false}>) == (123+0i) to be truthy but was false
  fails "Kernel.Complex() when passed exception: false and [anything, non-Numeric] argument swallows an error" # ArgumentError: [MSpecEnv#Complex] wrong number of arguments (given 3, expected -2)
  fails "Kernel.Complex() when passed exception: false and [non-Numeric, Numeric] argument throws a TypeError" # Expected TypeError (not a real) but got: ArgumentError ([MSpecEnv#Complex] wrong number of arguments (given 3, expected -2))
  fails "Kernel.Complex() when passed exception: false and [non-Numeric] swallows an error" # Expected #<Complex>(#pretty_inspect raised #<NoMethodError: undefined method `positive?' for {"exception"=>false}>) == nil to be truthy but was false
  fails "Kernel.Complex() when passed exception: false and nil arguments swallows an error" # Expected #<Complex>(#pretty_inspect raised #<NoMethodError: undefined method `positive?' for {"exception"=>false}>) == nil to be truthy but was false
  fails "Kernel.Complex() when passed exception: false and non-numeric String arguments swallows an error" # ArgumentError: [MSpecEnv#Complex] wrong number of arguments (given 3, expected -2)
  fails "Kernel.Complex() when passed nil raises TypeError" # Expected TypeError (can't convert nil into Complex) but no exception was raised ((nil+0i) was returned)
  fails "Kernel.Float for hexadecimal literals with binary exponent allows embedded _ in a number on either side of the P" # ArgumentError: invalid value for Float(): "0x1_0P10"
  fails "Kernel.Float for hexadecimal literals with binary exponent allows embedded _ in a number on either side of the p" # ArgumentError: invalid value for Float(): "0x1_0p10"
  fails "Kernel.Float for hexadecimal literals with binary exponent allows hexadecimal points on the left side of the 'P'" # ArgumentError: invalid value for Float(): "0x1.8P0"
  fails "Kernel.Float for hexadecimal literals with binary exponent allows hexadecimal points on the left side of the 'p'" # ArgumentError: invalid value for Float(): "0x1.8p0"
  fails "Kernel.Float for hexadecimal literals with binary exponent interprets the exponent (on the right of 'P') in decimal" # ArgumentError: invalid value for Float(): "0x1P10"
  fails "Kernel.Float for hexadecimal literals with binary exponent interprets the exponent (on the right of 'p') in decimal" # ArgumentError: invalid value for Float(): "0x1p10"
  fails "Kernel.Float for hexadecimal literals with binary exponent interprets the fractional part (on the left side of 'P') in hexadecimal" # ArgumentError: invalid value for Float(): "0x10P0"
  fails "Kernel.Float for hexadecimal literals with binary exponent interprets the fractional part (on the left side of 'p') in hexadecimal" # ArgumentError: invalid value for Float(): "0x10p0"
  fails "Kernel.Float for hexadecimal literals with binary exponent returns 0 for '0x1P-10000'" # ArgumentError: invalid value for Float(): "0x1P-10000"
  fails "Kernel.Float for hexadecimal literals with binary exponent returns 0 for '0x1p-10000'" # ArgumentError: invalid value for Float(): "0x1p-10000"
  fails "Kernel.Float for hexadecimal literals with binary exponent returns Infinity for '0x1P10000'" # ArgumentError: invalid value for Float(): "0x1P10000"
  fails "Kernel.Float for hexadecimal literals with binary exponent returns Infinity for '0x1p10000'" # ArgumentError: invalid value for Float(): "0x1p10000"
  fails "Kernel.Rational raises a TypeError if the first argument is a Symbol" # Expected TypeError but no exception was raised ((0/1) was returned)
  fails "Kernel.Rational raises a TypeError if the second argument is a Symbol" # Expected TypeError but got: ZeroDivisionError (divided by 0)
  fails "Kernel.Rational when passed a Numeric calls #to_r to convert the first argument to a Rational" # NoMethodError: undefined method `/' for #<RationalSpecs::SubNumeric:0x8bc3a @value=(2/1)>
  fails "Kernel.Rational when passed a String converts the String to a Rational using the same method as String#to_r" # Expected (0/1) == (13/25) to be truthy but was false
  fails "Kernel.Rational when passed a String does not use the same method as Float#to_r" # Expected (5404319552844595/9007199254740992) == (3/5) to be truthy but was false
  fails "Kernel.Rational when passed a String scales the Rational value of the first argument by the Rational value of the second" # ZeroDivisionError: divided by 0
  fails "Kernel.Rational when passed exception: false and [anything, non-Numeric] swallows an error" # ArgumentError: [MSpecEnv#Rational] wrong number of arguments (given 3, expected -2)
  fails "Kernel.Rational when passed exception: false and [non-Numeric, Numeric] swallows an error" # ArgumentError: [MSpecEnv#Rational] wrong number of arguments (given 3, expected -2)
  fails "Kernel.Rational when passed exception: false and [non-Numeric] swallows an error" # NoMethodError: undefined method `to_i' for {"exception"=>false}
  fails "Kernel.Rational when passed exception: false and nil arguments swallows an error" # TypeError: cannot convert nil into Rational
  fails "Kernel.Rational when passed exception: false and non-Numeric String arguments swallows an error" # ArgumentError: [MSpecEnv#Rational] wrong number of arguments (given 3, expected -2)
  fails "Kernel.String calls #to_s if #respond_to?(:to_s) returns true" # TypeError: no implicit conversion of MockObject into String
  fails "Kernel.String raises a TypeError if #to_s is not defined, even though #respond_to?(:to_s) returns true" # Expected TypeError but got: NoMethodError (undefined method `to_s' for #<Object:0x295e2>)
  fails "Kernel.__callee__ returns method name even from eval" # Expected nil == "from_eval" to be truthy but was false
  fails "Kernel.__callee__ returns method name even from send" # NoMethodError: undefined method `__callee__' for #<KernelSpecs::CalleeTest:0x4679a>
  fails "Kernel.__callee__ returns the aliased name when aliased method" # Expected "f" == "g" to be truthy but was false
  fails "Kernel.__callee__ returns the caller from a define_method called from the same class" # Expected nil == "f" to be truthy but was false
  fails "Kernel.__callee__ returns the caller from block inside define_method too" # Expected [nil, nil] == ["dm_block", "dm_block"] to be truthy but was false
  fails "Kernel.__callee__ returns the caller from blocks too" # Expected [nil, nil] == ["in_block", "in_block"] to be truthy but was false
  fails "Kernel.__callee__ returns the caller from define_method too" # Expected nil == "dm" to be truthy but was false
  fails "Kernel.__method__ returns method name even from eval" # Expected nil == "from_eval" to be truthy but was false
  fails "Kernel.__method__ returns method name even from send" # NoMethodError: undefined method `__method__' for #<KernelSpecs::MethodTest:0x7c4de>
  fails "Kernel.__method__ returns the caller from block inside define_method too" # Expected [nil, nil] == ["dm_block", "dm_block"] to be truthy but was false
  fails "Kernel.__method__ returns the caller from blocks too" # Expected [nil, nil] == ["in_block", "in_block"] to be truthy but was false
  fails "Kernel.__method__ returns the caller from define_method too" # Expected nil == "dm" to be truthy but was false
  fails "Kernel.autoload calls #to_path on non-String filenames" # Mock 'path' expected to receive to_path("any_args") exactly 1 times but received it 0 times
  fails "Kernel.autoload when called from included module's method setups the autoload on the included module" # Expected nil == "ruby/core/kernel/fixtures/autoload_from_included_module2.rb" to be truthy but was false
  fails "Kernel.autoload when called from included module's method the autoload relative to the included module works" # NameError: uninitialized constant KernelSpecs::AutoloadMethod2::AutoloadFromIncludedModule2
  fails "Kernel.global_variables finds subset starting with std" # NoMethodError: undefined method `global_variables' for #<MSpecEnv:0xb3298 @i=0>
  fails "Kernel.lambda does not create lambda-style Procs when captured with #method" # Expected true to be false
  fails "Kernel.lambda raises an ArgumentError when no block is given" # Expected ArgumentError but got: Exception (Cannot add property $$is_lambda, object is not extensible)
  fails "Kernel.lambda returns the passed Proc if given an existing Proc through super" # Expected true to be false
  fails "Kernel.lambda returns the passed Proc if given an existing Proc" # Expected true to be false
  fails "Kernel.loop returns StopIteration#result, the result value of a finished iterator" # Expected nil == "stopped" to be truthy but was false
  fails "Kernel.printf formatting io is not specified integer formats d works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "Kernel.printf formatting io is not specified integer formats i works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "Kernel.printf formatting io is not specified integer formats u works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "Kernel.printf formatting io is not specified other formats c raises TypeError if argument is nil" # Expected TypeError (no implicit conversion from nil to integer) but got: TypeError (no implicit conversion of NilClass into Integer)
  fails "Kernel.printf formatting io is not specified other formats c raises TypeError if converting to Integer with to_int returns non-Integer" # Expected TypeError (can't convert BasicObject to Integer) but got: TypeError (can't convert BasicObject into Integer (BasicObject#to_int gives String))
  fails "Kernel.printf formatting io is not specified other formats c raises TypeError if converting to String with to_str returns non-String" # Expected TypeError (can't convert BasicObject to String) but no exception was raised ("f" was returned)
  fails "Kernel.printf formatting io is specified integer formats d works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "Kernel.printf formatting io is specified integer formats i works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "Kernel.printf formatting io is specified integer formats u works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "Kernel.printf formatting io is specified other formats c raises TypeError if argument is nil" # Expected TypeError (no implicit conversion from nil to integer) but got: TypeError (no implicit conversion of NilClass into Integer)
  fails "Kernel.printf formatting io is specified other formats c raises TypeError if converting to Integer with to_int returns non-Integer" # Expected TypeError (can't convert BasicObject to Integer) but got: TypeError (can't convert BasicObject into Integer (BasicObject#to_int gives String))
  fails "Kernel.printf formatting io is specified other formats c raises TypeError if converting to String with to_str returns non-String" # Expected TypeError (can't convert BasicObject to String) but no exception was raised ("f" was returned)
  fails "Kernel.proc returned the passed Proc if given an existing Proc" # Expected false to be true
  fails "Kernel.sprintf %c raises error when a codepoint isn't representable in an encoding of a format string" # Expected RangeError (out of char range) but no exception was raised ("Ԇ" was returned)
  fails "Kernel.sprintf %c uses the encoding of the format string to interpret codepoints" # Exception: Invalid code point 9415601
  fails "Kernel.sprintf can produce a string with invalid encoding" # Expected #<Encoding:ASCII-8BIT> == #<Encoding:UTF-8> to be truthy but was false
  fails "Kernel.sprintf integer formats d works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "Kernel.sprintf integer formats i works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "Kernel.sprintf integer formats u works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "Kernel.sprintf other formats c raises TypeError if argument is nil" # Expected TypeError (no implicit conversion from nil to integer) but got: TypeError (no implicit conversion of NilClass into Integer)
  fails "Kernel.sprintf other formats c raises TypeError if converting to Integer with to_int returns non-Integer" # Expected TypeError (can't convert BasicObject to Integer) but got: TypeError (can't convert BasicObject into Integer (BasicObject#to_int gives String))
  fails "Kernel.sprintf other formats c raises TypeError if converting to String with to_str returns non-String" # Expected TypeError (can't convert BasicObject to String) but no exception was raised ("f" was returned)
  fails "Kernel.sprintf raises Encoding::CompatibilityError if both encodings are ASCII compatible and there are not ASCII characters" # Expected CompatibilityError but no exception was raised ("Ä Ђ" was returned)
  fails "Kernel.sprintf returns a String in the same encoding as the format String if compatible" # Expected #<Encoding:UTF-8> to be identical to #<Encoding:KOI8_U (dummy)>
  fails_badly "Kernel#autoload registers a file to load the first time the named constant is accessed" # NoMethodError: undefined method `autoload?' for #<MSpecEnv:0x5b168>
  fails_badly "Kernel#autoload when called from included module's method setups the autoload on the included module"
  fails_badly "Kernel#autoload when called from included module's method the autoload is reachable from the class too"
  fails_badly "Kernel#autoload when called from included module's method the autoload relative to the included module works"
end
