# NOTE: run bin/format-filters after changing this file
opal_filter "Kernel" do
  fails "Kernel#=== does not call #object_id nor #equal? but still returns true for #== or #=== on the same object" # Mock '#<Object:0x37dd4>' expected to receive 'object_id' exactly 0 times but received it 2 times
  fails "Kernel#=~ returns nil matching any object"
  fails "Kernel#Float for hexadecimal literals with binary exponent allows embedded _ in a number on either side of the P"
  fails "Kernel#Float for hexadecimal literals with binary exponent allows embedded _ in a number on either side of the p"
  fails "Kernel#Float for hexadecimal literals with binary exponent allows hexadecimal points on the left side of the 'P'"
  fails "Kernel#Float for hexadecimal literals with binary exponent allows hexadecimal points on the left side of the 'p'"
  fails "Kernel#Float for hexadecimal literals with binary exponent interprets the exponent (on the right of 'P') in decimal"
  fails "Kernel#Float for hexadecimal literals with binary exponent interprets the exponent (on the right of 'p') in decimal"
  fails "Kernel#Float for hexadecimal literals with binary exponent interprets the fractional part (on the left side of 'P') in hexadecimal"
  fails "Kernel#Float for hexadecimal literals with binary exponent interprets the fractional part (on the left side of 'p') in hexadecimal"
  fails "Kernel#Float for hexadecimal literals with binary exponent returns 0 for '0x1P-10000'"
  fails "Kernel#Float for hexadecimal literals with binary exponent returns 0 for '0x1p-10000'"
  fails "Kernel#Float for hexadecimal literals with binary exponent returns Infinity for '0x1P10000'"
  fails "Kernel#Float for hexadecimal literals with binary exponent returns Infinity for '0x1p10000'"
  fails "Kernel#Float when passed exception: false and invalid input swallows an error" # ArgumentError: [Object#Float] wrong number of arguments(2 for 1)
  fails "Kernel#Float when passed exception: false and nil swallows it" # ArgumentError: [Object#Float] wrong number of arguments(2 for 1)
  fails "Kernel#Float when passed exception: false and valid input returns a Float number" # ArgumentError: [Object#Float] wrong number of arguments(2 for 1)
  fails "Kernel#Integer raises a TypeError when to_int returns not-an-Integer object and to_i returns nil" # Expected TypeError but no exception was raised ("1" was returned)
  fails "Kernel#Integer return a result of to_i when to_int does not return an Integer" # Expected "1" == 42 to be truthy but was false
  fails "Kernel#Integer when passed exception: false and an argument that contains a period swallows an error" # TypeError: no implicit conversion of Hash into Integer
  fails "Kernel#Integer when passed exception: false and an empty string swallows an error" # TypeError: no implicit conversion of Hash into Integer
  fails "Kernel#Integer when passed exception: false and invalid argument swallows an error" # ArgumentError: [MSpecEnv#Integer] wrong number of arguments(3 for -2)
  fails "Kernel#Integer when passed exception: false and multiple leading -s swallows an error" # TypeError: no implicit conversion of Hash into Integer
  fails "Kernel#Integer when passed exception: false and multiple trailing -s swallows an error" # TypeError: no implicit conversion of Hash into Integer
  fails "Kernel#Integer when passed exception: false and no to_int or to_i methods exist swallows an error" # ArgumentError: base specified for non string value
  fails "Kernel#Integer when passed exception: false and passed Infinity swallows an error" # ArgumentError: base specified for non string value
  fails "Kernel#Integer when passed exception: false and passed NaN swallows an error" # ArgumentError: base specified for non string value
  fails "Kernel#Integer when passed exception: false and passed a String that can't be converted to an Integer swallows an error" # TypeError: no implicit conversion of Hash into Integer
  fails "Kernel#Integer when passed exception: false and passed a String that contains numbers normally parses it and returns an Integer" # TypeError: no implicit conversion of Hash into Integer
  fails "Kernel#Integer when passed exception: false and passed nil swallows an error" # ArgumentError: base specified for non string value
  fails "Kernel#Integer when passed exception: false and to_i returns a value that is not an Integer swallows an error" # ArgumentError: base specified for non string value
  fails "Kernel#Integer when passed exception: false and to_int returns nil and no to_i exists swallows an error" # ArgumentError: base specified for non string value
  fails "Kernel#Integer when passed exception: false and valid argument returns an Integer number" # ArgumentError: [MSpecEnv#Integer] wrong number of arguments(3 for -2)
  fails "Kernel#Pathname returns same argument when called with a pathname argument" # Expected foo.equal? foo to be truthy but was false
  fails "Kernel#String calls #to_s if #respond_to?(:to_s) returns true" # TypeError: no implicit conversion of MockObject into String
  fails "Kernel#String raises a TypeError if #to_s is not defined, even though #respond_to?(:to_s) returns true"
  fails "Kernel#__dir__ returns the expanded path of the directory when used in the main script" # NoMethodError: undefined method `insert' for "rubyexe.rb"
  fails "Kernel#__dir__ when used in eval with top level binding returns nil" # NoMethodError: undefined method `binding' for #<MSpecEnv:0x5b3aa>
  fails "Kernel#autoload calls main.require(path) to load the file" # NameError: uninitialized constant TOPLEVEL_BINDING
  fails "Kernel#autoload can autoload in instance_eval" # NameError: uninitialized constant KSAutoloadD
  fails "Kernel#autoload inside a Class.new method body should define on the new anonymous class" # NoMethodError: undefined method `autoload?' for #<#<Class:0x61d4a>:0x61d48>
  fails "Kernel#autoload is a private method" # Expected Kernel to have private instance method 'autoload' but it does not
  fails "Kernel#autoload when Object is frozen raises a FrozenError before defining the constant" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x7849c>
  fails "Kernel#autoload when called from included module's method setups the autoload on the included module" # NoMethodError: undefined method `autoload?' for KernelSpecs::AutoloadMethod
  fails "Kernel#autoload when called from included module's method the autoload is reachable from the class too" # NoMethodError: undefined method `autoload?' for KernelSpecs::AutoloadMethodIncluder
  fails "Kernel#autoload when called from included module's method the autoload relative to the included module works" # NameError: uninitialized constant KernelSpecs::AutoloadMethod::AutoloadFromIncludedModule
  fails "Kernel#autoload? is a private method" # Expected Kernel to have private instance method 'autoload?' but it does not
  fails "Kernel#autoload? returns nil if no file has been registered for a constant" # NoMethodError: undefined method `autoload?' for #<MSpecEnv:0x7849c>
  fails "Kernel#autoload? returns the name of the file that will be autoloaded" # NoMethodError: undefined method `autoload?' for #<MSpecEnv:0x7849c>
  fails "Kernel#caller is a private method" # Expected Kernel to have private instance method 'caller' but it does not
  fails "Kernel#caller returns an Array of caller locations using a custom offset" # Expected "ruby/core/kernel/fixtures/caller.rb:4" to match /runner\/mspec.rb/
  fails "Kernel#caller returns an Array of caller locations using a range" # NoMethodError: undefined method `+' for 1..1
  fails "Kernel#caller returns an Array with the block given to #at_exit at the base of the stack" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0xe208>
  fails "Kernel#caller returns the locations as String instances" # Expected "corelib/runtime.js:1675" to include "ruby/core/kernel/caller_spec.rb:32:in"
  fails "Kernel#caller works with beginless ranges" # TypeError: no implicit conversion of NilClass into Integer
  fails "Kernel#caller works with endless ranges" # Opal::SyntaxError: undefined method `type' for nil
  fails "Kernel#class returns the class of the object"
  fails "Kernel#clone replaces a singleton object's metaclass with a new copy with the same superclass" # NoMethodError: undefined method `singleton_methods' for #<#<Class:0x2df8e>:0x2df90>
  fails "Kernel#clone uses the internal allocator and does not call #allocate" # RuntimeError: allocate should not be called
  fails "Kernel#define_singleton_method when given an UnboundMethod will raise when attempting to define an object's singleton method from another object's singleton method"
  fails "Kernel#dup uses the internal allocator and does not call #allocate" # RuntimeError: allocate should not be called
  fails "Kernel#eval allows a binding to be captured inside an eval"
  fails "Kernel#eval allows creating a new class in a binding" # RuntimeError: Evaluation on a Proc#binding is not supported
  fails "Kernel#eval can be aliased"
  fails "Kernel#eval does not make Proc locals visible to evaluated code" # Expected NameError but got: RuntimeError (Evaluation on a Proc#binding is not supported)
  fails "Kernel#eval does not share locals across eval scopes"
  fails "Kernel#eval doesn't accept a Proc object as a binding"
  fails "Kernel#eval evaluates string with given filename and negative linenumber" # NameError: uninitialized constant TOPLEVEL_BINDING
  fails "Kernel#eval includes file and line information in syntax error"
  fails "Kernel#eval raises a LocalJumpError if there is no lambda-style closure in the chain"
  fails "Kernel#eval unwinds through a Proc-style closure and returns from a lambda-style closure in the closure chain"
  fails "Kernel#eval updates a local in a scope above a surrounding block scope"
  fails "Kernel#eval updates a local in a scope above when modified in a nested block scope"
  fails "Kernel#eval updates a local in a surrounding block scope"
  fails "Kernel#eval updates a local in an enclosing scope"
  fails "Kernel#eval uses the same scope for local variables when given the same binding"
  fails "Kernel#eval with a magic encoding comment allows a magic encoding comment and a frozen_string_literal magic comment on the same line in emacs style" # Opal::SyntaxError: unexpected token $end
  fails "Kernel#eval with a magic encoding comment allows a magic encoding comment and a subsequent frozen_string_literal magic comment" # Opal::SyntaxError: unexpected token $end
  fails "Kernel#eval with a magic encoding comment allows a shebang line and some spaces before the magic encoding comment" # Opal::SyntaxError: unexpected token $end
  fails "Kernel#eval with a magic encoding comment allows a shebang line before the magic encoding comment" # Opal::SyntaxError: unexpected token $end
  fails "Kernel#eval with a magic encoding comment allows an emacs-style magic comment encoding" # Opal::SyntaxError: unexpected token $end
  fails "Kernel#eval with a magic encoding comment allows spaces before the magic encoding comment" # Opal::SyntaxError: unexpected token $end
  fails "Kernel#eval with a magic encoding comment ignores the frozen_string_literal magic comment if it appears after a token and warns if $VERBOSE is true" # Expected warning to match: /warning: `frozen_string_literal' is ignored after any tokens/ but got: ""
  fails "Kernel#eval with a magic encoding comment ignores the magic encoding comment if it is after a frozen_string_literal magic comment" # Opal::SyntaxError: unexpected token $end
  fails "Kernel#eval with a magic encoding comment uses the magic comment encoding for parsing constants" # Opal::SyntaxError: unexpected token $end
  fails "Kernel#eval with refinements activates refinements from the binding" # NoMethodError: undefined method `foo' for #<EvalSpecs::A:0x26588>
  fails "Kernel#eval with refinements activates refinements from the eval scope" # NoMethodError: undefined method `foo' for #<EvalSpecs::A:0x26698>
  fails "Kernel#extend does not calls append_features on arguments metaclass"
  fails "Kernel#fail accepts an Object with an exception method returning an Exception" # TypeError: exception class/object expected
  fails "Kernel#freeze freezes an object's singleton class" # Expected false == true to be truthy but was false
  fails "Kernel#initialize_copy does nothing if the argument is the same as the receiver" # Expected nil.equal? #<Object:0x590> to be truthy but was false
  fails "Kernel#initialize_copy raises FrozenError if the receiver is frozen" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Kernel#initialize_copy raises TypeError if the objects are of different class" # Expected TypeError (initialize_copy should take same class object) but no exception was raised (nil was returned)
  fails "Kernel#inspect returns a String for an object without #class method" # Exception: Maximum call stack size exceeded
  fails "Kernel#instance_variable_set on frozen objects accepts unicode instance variable names" # NameError: '@💙' is not allowed as an instance variable name
  fails "Kernel#instance_variable_set on frozen objects raises for frozen objects" # Expected NameError but got: FrozenError (can't modify frozen NilClass: )
  fails "Kernel#instance_variables immediate values returns the correct array if an instance variable is added"
  fails "Kernel#is_a? does not take into account `class` method overriding" # TypeError: can't define singleton
  fails "Kernel#kind_of? does not take into account `class` method overriding" # TypeError: can't define singleton
  fails "Kernel#local_variables is accessible from bindings"
  fails "Kernel#method can be called even if we only repond_to_missing? method, true"
  fails "Kernel#method can call a #method_missing accepting zero or one arguments" # NameError: undefined method `foo' for class `#<Class:0x404ae>'
  fails "Kernel#method returns a method object if respond_to_missing?(method) is true" # NameError: undefined method `handled_publicly' for class `KernelSpecs::RespondViaMissing'
  fails "Kernel#method the returned method object if respond_to_missing?(method) calls #method_missing with a Symbol name" # NameError: undefined method `handled_publicly' for class `KernelSpecs::RespondViaMissing'
  fails "Kernel#method will see an alias of the original method as == when in a derived class"
  fails "Kernel#methods does not return private singleton methods defined in 'class << self'"
  fails "Kernel#object_id returns a different value for two Bignum literals"
  fails "Kernel#object_id returns a different value for two String literals"
  fails "Kernel#p flushes output if receiver is a File"
  fails "Kernel#p is not affected by setting $\\, $/ or $,"
  fails "Kernel#pp lazily loads the 'pp' library and delegates the call to that library" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x4f28>
  fails "Kernel#print prints $_ when no arguments are given" # Expected:   $stdout: "foo"       got:   $stdout: ""
  fails "Kernel#public_method changes the method called for super on a target aliased method"
  fails "Kernel#public_method raises a NameError if we only repond_to_missing? method, true"
  fails "Kernel#public_method returns a method object for a valid method"
  fails "Kernel#public_method returns a method object for a valid singleton method"
  fails "Kernel#public_method returns a method object if respond_to_missing?(method) is true" # Expected "Done public_method(handled_publicly)" (String) to be an instance of Method
  fails "Kernel#public_method the returned method object if respond_to_missing?(method) calls #method_missing with a Symbol name" # Expected "Done public_method(handled_publicly)" (String) to be an instance of Method
  fails "Kernel#public_methods returns a list of names without protected accessible methods in the object"
  fails "Kernel#public_methods when passed false returns a list of public methods in without its ancestors"
  fails "Kernel#public_methods when passed nil returns a list of public methods in without its ancestors"
  fails "Kernel#public_send includes `public_send` in the backtrace when passed a single incorrect argument" # Expected TypeError but got: NoMethodError (undefined method `#<Object:0x3da7a>' for #<MSpecEnv:0x3d9f4>)
  fails "Kernel#public_send includes `public_send` in the backtrace when passed not enough arguments" # Expected "ArgumentError: [MSpecEnv#__send__] wrong number of arguments(0 for -2)".include? "`public_send'" to be truthy but was false
  fails "Kernel#puts delegates to $stdout.puts"
  fails "Kernel#raise accepts a cause keyword argument that overrides the last exception" # NoMethodError: undefined method `cause' for #<RuntimeError: error>
  fails "Kernel#raise accepts a cause keyword argument that sets the cause" # NoMethodError: undefined method `cause' for #<RuntimeError: error>
  fails "Kernel#raise passes no arguments to the constructor when given only an exception class" # Expected #<Class:0x4c8> but got: ArgumentError ([#initialize] wrong number of arguments(1 for 0))
  fails "Kernel#raise raises an ArgumentError when only cause is given" # Expected ArgumentError but got: TypeError (exception class/object expected)
  fails "Kernel#raise re-raises a previously rescued exception without overwriting the backtrace" # Expected "RuntimeError: raised" to include "ruby/shared/kernel/raise.rb:65:"
  fails "Kernel#rand is a private method" # Expected Kernel to have private instance method 'rand' but it does not
  fails "Kernel#rand is random on boot" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x31a04>
  fails "Kernel#rand supports custom object types" # Expected "NaN#<struct KernelSpecs::CustomRangeInteger value=1>" (String) to be an instance of KernelSpecs::CustomRangeInteger
  fails "Kernel#remove_instance_variable raises a FrozenError if self is frozen" # Expected FrozenError but got: NameError (instance variable @foo not defined)
  fails "Kernel#remove_instance_variable raises for frozen objects" # Expected FrozenError but got: NameError (instance variable @foo not defined)
  fails "Kernel#respond_to? throws a type error if argument can't be coerced into a Symbol"
  fails "Kernel#respond_to_missing? causes #respond_to? to return false if called and returning nil"
  fails "Kernel#respond_to_missing? causes #respond_to? to return true if called and not returning false"
  fails "Kernel#singleton_class raises TypeError for Integer" # Expected TypeError but no exception was raised (#<Class:#<Number:0xf7>> was returned)
  fails "Kernel#singleton_class raises TypeError for Symbol"
  fails "Kernel#singleton_method find a method defined on the singleton class" # NoMethodError: undefined method `singleton_method' for #<Object:0x39d20>
  fails "Kernel#singleton_method only looks at singleton methods and not at methods in the class" # Expected NoMethodError to equal NameError
  fails "Kernel#singleton_method raises a NameError if there is no such method" # Expected NoMethodError to equal NameError
  fails "Kernel#singleton_method returns a Method which can be called" # NoMethodError: undefined method `singleton_method' for #<Object:0x39d1a>
  fails "Kernel#singleton_methods when not passed an argument does not return any included methods for a class including a module"
  fails "Kernel#singleton_methods when not passed an argument does not return any included methods for a module including a module"
  fails "Kernel#singleton_methods when not passed an argument does not return private singleton methods for an object extended with a module including a module" # NoMethodError: undefined method `singleton_methods' for #<MockObject:0x104d6>
  fails "Kernel#singleton_methods when not passed an argument for a module does not return methods in a module prepended to Module itself" # NoMethodError: undefined method `singleton_methods' for SingletonMethodsSpecs::SelfExtending
  fails "Kernel#singleton_methods when not passed an argument returns a unique list for a subclass including a module"
  fails "Kernel#singleton_methods when not passed an argument returns a unique list for a subclass"
  fails "Kernel#singleton_methods when not passed an argument returns a unique list for an object extended with a module"
  fails "Kernel#singleton_methods when not passed an argument returns an empty Array for an object with no singleton methods"
  fails "Kernel#singleton_methods when not passed an argument returns the names of class methods for a class"
  fails "Kernel#singleton_methods when not passed an argument returns the names of inherited singleton methods for a class extended with a module"
  fails "Kernel#singleton_methods when not passed an argument returns the names of inherited singleton methods for a subclass including a module"
  fails "Kernel#singleton_methods when not passed an argument returns the names of inherited singleton methods for a subclass of a class including a module"
  fails "Kernel#singleton_methods when not passed an argument returns the names of inherited singleton methods for a subclass of a class that includes a module, where the subclass also includes a module"
  fails "Kernel#singleton_methods when not passed an argument returns the names of inherited singleton methods for a subclass"
  fails "Kernel#singleton_methods when not passed an argument returns the names of module methods for a module"
  fails "Kernel#singleton_methods when not passed an argument returns the names of singleton methods for an object extended with a module including a module" # NoMethodError: undefined method `singleton_methods' for #<MockObject:0x104da>
  fails "Kernel#singleton_methods when not passed an argument returns the names of singleton methods for an object extended with a module" # NoMethodError: undefined method `singleton_methods' for #<MockObject:0x104e2>
  fails "Kernel#singleton_methods when not passed an argument returns the names of singleton methods for an object extended with two modules" # NoMethodError: undefined method `singleton_methods' for #<MockObject:0x104de>
  fails "Kernel#singleton_methods when not passed an argument returns the names of singleton methods for an object"
  fails "Kernel#singleton_methods when passed false does not return any included methods for a class including a module"
  fails "Kernel#singleton_methods when passed false does not return any included methods for a module including a module"
  fails "Kernel#singleton_methods when passed false does not return names of inherited singleton methods for a subclass"
  fails "Kernel#singleton_methods when passed false does not return private singleton methods for an object extended with a module including a module" # NoMethodError: undefined method `singleton_methods' for #<MockObject:0x104fe>
  fails "Kernel#singleton_methods when passed false does not return the names of inherited singleton methods for a class extended with a module"
  fails "Kernel#singleton_methods when passed false for a module does not return methods in a module prepended to Module itself" # NoMethodError: undefined method `singleton_methods' for SingletonMethodsSpecs::SelfExtending
  fails "Kernel#singleton_methods when passed false returns an empty Array for an object extended with a module including a module"
  fails "Kernel#singleton_methods when passed false returns an empty Array for an object extended with a module" # NoMethodError: undefined method `singleton_methods' for #<MockObject:0x104fa>
  fails "Kernel#singleton_methods when passed false returns an empty Array for an object extended with two modules" # NoMethodError: undefined method `singleton_methods' for #<MockObject:0x104f6>
  fails "Kernel#singleton_methods when passed false returns an empty Array for an object with no singleton methods"
  fails "Kernel#singleton_methods when passed false returns the names of class methods for a class"
  fails "Kernel#singleton_methods when passed false returns the names of module methods for a module"
  fails "Kernel#singleton_methods when passed false returns the names of singleton methods for an object"
  fails "Kernel#singleton_methods when passed false returns the names of singleton methods of the subclass"
  fails "Kernel#singleton_methods when passed true does not return any included methods for a class including a module"
  fails "Kernel#singleton_methods when passed true does not return any included methods for a module including a module"
  fails "Kernel#singleton_methods when passed true does not return private singleton methods for an object extended with a module including a module" # NoMethodError: undefined method `singleton_methods' for #<MockObject:0x104e6>
  fails "Kernel#singleton_methods when passed true for a module does not return methods in a module prepended to Module itself" # NoMethodError: undefined method `singleton_methods' for SingletonMethodsSpecs::SelfExtending
  fails "Kernel#singleton_methods when passed true returns a unique list for a subclass including a module"
  fails "Kernel#singleton_methods when passed true returns a unique list for a subclass"
  fails "Kernel#singleton_methods when passed true returns a unique list for an object extended with a module"
  fails "Kernel#singleton_methods when passed true returns an empty Array for an object with no singleton methods"
  fails "Kernel#singleton_methods when passed true returns the names of class methods for a class"
  fails "Kernel#singleton_methods when passed true returns the names of inherited singleton methods for a class extended with a module"
  fails "Kernel#singleton_methods when passed true returns the names of inherited singleton methods for a subclass including a module"
  fails "Kernel#singleton_methods when passed true returns the names of inherited singleton methods for a subclass of a class including a module"
  fails "Kernel#singleton_methods when passed true returns the names of inherited singleton methods for a subclass of a class that includes a module, where the subclass also includes a module"
  fails "Kernel#singleton_methods when passed true returns the names of inherited singleton methods for a subclass"
  fails "Kernel#singleton_methods when passed true returns the names of module methods for a module"
  fails "Kernel#singleton_methods when passed true returns the names of singleton methods for an object extended with a module including a module" # NoMethodError: undefined method `singleton_methods' for #<MockObject:0x104f2>
  fails "Kernel#singleton_methods when passed true returns the names of singleton methods for an object extended with a module" # NoMethodError: undefined method `singleton_methods' for #<MockObject:0x104ee>
  fails "Kernel#singleton_methods when passed true returns the names of singleton methods for an object extended with two modules" # NoMethodError: undefined method `singleton_methods' for #<MockObject:0x104ea>
  fails "Kernel#singleton_methods when passed true returns the names of singleton methods for an object"
  fails "Kernel#sleep accepts any Object that reponds to divmod" # TypeError: can't convert Object into time interval
  fails "Kernel#sprintf %c raises error when a codepoint isn't representable in an encoding of a format string" # Expected RangeError (/out of char range/) but no exception was raised ("Ԇ" was returned)
  fails "Kernel#sprintf %c uses the encoding of the format string to interpret codepoints" # ArgumentError: unknown encoding name - euc-jp
  fails "Kernel#sprintf can produce a string with invalid encoding" # Expected true to be false
  fails "Kernel#sprintf flags # applies to format o does nothing for negative argument" # Expected "0..7651" to equal "..7651"
  fails "Kernel#sprintf flags # applies to formats aAeEfgG changes format from dd.dddd to exponential form for gG" # Expected "1.234e+02" to equal "1.e+02"
  fails "Kernel#sprintf flags # applies to formats aAeEfgG forces a decimal point to be added, even if no digits follow" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel#sprintf flags (digit)$ specifies the absolute argument number for this field" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel#sprintf flags * left-justifies the result if specified with $ argument is negative" # Expected "1.095200e+2         " to equal "1.095200e+02        "
  fails "Kernel#sprintf flags * left-justifies the result if width is negative" # Expected "1.095200e+2         " to equal "1.095200e+02        "
  fails "Kernel#sprintf flags * raises ArgumentError when is mixed with width" # Expected ArgumentError but no exception was raised ("       112" was returned)
  fails "Kernel#sprintf flags * uses the previous argument as the field width" # Expected "         1.095200e+02" to equal "        1.095200e+02"
  fails "Kernel#sprintf flags * uses the specified argument as the width if * is followed by a number and $" # Expected "         1.095200e+02" to equal "        1.095200e+02"
  fails "Kernel#sprintf flags + applies to numeric formats bBdiouxXaAeEfgG adds a leading plus sign to non-negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel#sprintf flags - left-justifies the result of conversion if width is specified" # Expected "1.095200e+2         " to equal "1.095200e+02        "
  fails "Kernel#sprintf flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified pads with zeros, not spaces" # Expected "0000000001.095200e+02" to equal "000000001.095200e+02"
  fails "Kernel#sprintf flags space applies to numeric formats bBdiouxXeEfgGaA does not leave a space at the start of negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel#sprintf flags space applies to numeric formats bBdiouxXeEfgGaA leaves a space at the start of non-negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel#sprintf flags space applies to numeric formats bBdiouxXeEfgGaA treats several white spaces as one" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel#sprintf float formats A converts floating point argument as [-]0xh.hhhhp[+-]dd and use uppercase X and P" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel#sprintf float formats A displays Float::INFINITY as Inf" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel#sprintf float formats A displays Float::NAN as NaN" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel#sprintf float formats G otherwise cuts excessive digits in fractional part and keeps only 4 ones" # Expected "12.12341111" to equal "12.1234"
  fails "Kernel#sprintf float formats G otherwise cuts fraction part to have only 6 digits at all" # Expected "1.1234567" to equal "1.12346"
  fails "Kernel#sprintf float formats G otherwise rounds the last significant digit to the closest one in fractional part" # Expected "1.555555555" to equal "1.55556"
  fails "Kernel#sprintf float formats G the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # Expected "1.234567E+06" to equal "1.23457E+06"
  fails "Kernel#sprintf float formats a converts floating point argument as [-]0xh.hhhhp[+-]dd" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel#sprintf float formats a displays Float::INFINITY as Inf" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel#sprintf float formats a displays Float::NAN as NaN" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel#sprintf float formats g otherwise cuts excessive digits in fractional part and keeps only 4 ones" # Expected "12.12341111" to equal "12.1234"
  fails "Kernel#sprintf float formats g otherwise cuts fraction part to have only 6 digits at all" # Expected "1.1234567" to equal "1.12346"
  fails "Kernel#sprintf float formats g otherwise rounds the last significant digit to the closest one in fractional part" # Expected "1.555555555" to equal "1.55556"
  fails "Kernel#sprintf float formats g the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # Expected "1.234567e+06" to equal "1.23457e+06"
  fails "Kernel#sprintf integer formats d works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
  fails "Kernel#sprintf integer formats i works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
  fails "Kernel#sprintf integer formats u works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
  fails "Kernel#sprintf other formats % alone raises an ArgumentError" # Expected ArgumentError but no exception was raised ("%" was returned)
  fails "Kernel#sprintf other formats c raises TypeError if argument is nil" # Expected TypeError (/no implicit conversion from nil to integer/) but got: TypeError (no implicit conversion of NilClass into Integer)
  fails "Kernel#sprintf other formats c raises TypeError if argument is not String or Integer and cannot be converted to them" # Expected TypeError (/no implicit conversion of Array into Integer/) but got: ArgumentError (too few arguments)
  fails "Kernel#sprintf other formats c raises TypeError if converting to Integer with to_int returns non-Integer" # Expected TypeError (/can't convert BasicObject to String/) but got: NoMethodError (undefined method `respond_to?' for #<BasicObject:0x7b8c0>)
  fails "Kernel#sprintf other formats c raises TypeError if converting to String with to_str returns non-String" # Expected TypeError (/can't convert BasicObject to String/) but got: NoMethodError (undefined method `respond_to?' for #<BasicObject:0x7b8e8>)
  fails "Kernel#sprintf other formats c tries to convert argument to Integer with to_int" # NoMethodError: undefined method `respond_to?' for #<BasicObject:0x7b8e4>
  fails "Kernel#sprintf other formats c tries to convert argument to String with to_str" # NoMethodError: undefined method `respond_to?' for #<BasicObject:0x7b8e0>
  fails "Kernel#sprintf other formats s preserves encoding of the format string" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT (dummy)> to be truthy but was false
  fails "Kernel#sprintf precision float types controls the number of decimal places displayed in fraction part" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel#sprintf precision float types does not affect G format" # Expected "12.12340000" to equal "12.1234"
  fails "Kernel#sprintf precision string formats determines the maximum number of characters to be copied from the string" # Expected "1" to equal "["
  fails "Kernel#sprintf raises Encoding::CompatibilityError if both encodings are ASCII compatible and there ano not ASCII characters" # ArgumentError: unknown encoding name - windows-1252
  fails "Kernel#sprintf raises Encoding::CompatibilityError if both encodings are ASCII compatible and there are not ASCII characters" # ArgumentError: unknown encoding name - windows-1252
  fails "Kernel#sprintf width specifies the minimum number of characters that will be written to the result" # Expected "         1.095200e+02" to equal "        1.095200e+02"
  fails "Kernel#srand is a private method" # Expected Kernel to have private instance method 'srand' but it does not
  fails "Kernel#srand returns the system-initialized seed value on the first call" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x7c8be @seed=33>
  fails "Kernel#warn :uplevel keyword argument converts first arg using to_s" # Expected:   $stderr: /core\/kernel\/fixtures\/classes.rb:441: warning: false/       got:   $stderr: "ruby/core/kernel/fixtures/classes.rb:441:7:in `warn': warning: false\n"
  fails "Kernel#warn :uplevel keyword argument converts value to Integer" # TypeError: no implicit conversion of Number into Integer
  fails "Kernel#warn :uplevel keyword argument prepends a message with specified line from the backtrace" # Expected:   $stderr: /core\/kernel\/fixtures\/classes.rb:441: warning: foo/       got:   $stderr: "ruby/core/kernel/fixtures/classes.rb:441:7:in `warn': warning: foo\n"
  fails "Kernel#warn :uplevel keyword argument prepends even if a message is empty or nil" # Expected:   $stderr: /core\/kernel\/fixtures\/classes.rb:441: warning: \n$/       got:   $stderr: "ruby/core/kernel/fixtures/classes.rb:441:7:in `warn': warning: \n"
  fails "Kernel#warn :uplevel keyword argument raises if :category keyword is not nil and not convertible to symbol" # Expected TypeError but no exception was raised (nil was returned)
  fails "Kernel#warn :uplevel keyword argument shows the caller of #require and not #require itself with RubyGems loaded" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x28d18>
  fails "Kernel#warn :uplevel keyword argument shows the caller of #require and not #require itself without RubyGems" # NoMethodError: undefined method `insert' for "rubyexe.rb"
  fails "Kernel#warn :uplevel keyword argument skips <internal: core library methods defined in Ruby" # NoMethodError: undefined method `insert' for "rubyexe.rb"
  fails "Kernel#warn avoids recursion if Warning#warn is redefined and calls super" # NoMethodError: undefined method `insert' for "rubyexe.rb"
  fails "Kernel#warn does not call Warning.warn if self is the Warning module" # NoMethodError: undefined method `insert' for "rubyexe.rb"
  fails "Kernel#warn writes each array element on a line when passes an array" # Expected:   $stderr: "line 1\nline 2\n"       got:   $stderr: "[\"line 1\", \"li
  fails "Kernel.Complex() when passed Numerics n1 and n2 and at least one responds to #real? with false returns n1 + n2 * Complex(0, 1)"
  fails "Kernel.Complex() when passed [Complex, Complex] returns a new Complex number based on the two given numbers"
  fails "Kernel.Complex() when passed [Complex] returns the passed Complex number"
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
  fails "Kernel.Complex() when passed a Numeric which responds to #real? with false returns the passed argument"
  fails "Kernel.Complex() when passed a non-Numeric second argument raises TypeError"
  fails "Kernel.Complex() when passed a single non-Numeric coerces the passed argument using #to_c"
  fails "Kernel.Complex() when passed an Object which responds to #to_c returns the passed argument" # Expected (#<Object:0x332c0>+0i) to equal (0+1i)
  fails "Kernel.Complex() when passed exception: false and [Numeric] returns a complex number" # Expected #<Complex>(#pretty_inspect raised #<NoMethodError: undefined method `positive?' for {"exception"=>false}>) == (123+0i) to be truthy but was false
  fails "Kernel.Complex() when passed exception: false and [anything, non-Numeric] argument swallows an error" # ArgumentError: [MSpecEnv#Complex] wrong number of arguments(3 for -2)
  fails "Kernel.Complex() when passed exception: false and [non-Numeric, Numeric] argument throws a TypeError" # Expected TypeError (not a real) but got: ArgumentError ([MSpecEnv#Complex] wrong number of arguments(3 for -2))
  fails "Kernel.Complex() when passed exception: false and [non-Numeric] swallows an error" # Expected #<Complex>(#pretty_inspect raised #<NoMethodError: undefined method `positive?' for {"exception"=>false}>) == nil to be truthy but was false
  fails "Kernel.Complex() when passed exception: false and nil arguments swallows an error" # Expected #<Complex>(#pretty_inspect raised #<NoMethodError: undefined method `positive?' for {"exception"=>false}>) == nil to be truthy but was false
  fails "Kernel.Complex() when passed exception: false and non-numeric String arguments swallows an error" # ArgumentError: [MSpecEnv#Complex] wrong number of arguments(3 for -2)
  fails "Kernel.Complex() when passed nil raises TypeError" # Expected TypeError (can't convert nil into Complex) but no exception was raised ((nil+0i) was returned)
  fails "Kernel.Float for hexadecimal literals with binary exponent allows embedded _ in a number on either side of the P"
  fails "Kernel.Float for hexadecimal literals with binary exponent allows embedded _ in a number on either side of the p"
  fails "Kernel.Float for hexadecimal literals with binary exponent allows hexadecimal points on the left side of the 'P'"
  fails "Kernel.Float for hexadecimal literals with binary exponent allows hexadecimal points on the left side of the 'p'"
  fails "Kernel.Float for hexadecimal literals with binary exponent interprets the exponent (on the right of 'P') in decimal"
  fails "Kernel.Float for hexadecimal literals with binary exponent interprets the exponent (on the right of 'p') in decimal"
  fails "Kernel.Float for hexadecimal literals with binary exponent interprets the fractional part (on the left side of 'P') in hexadecimal"
  fails "Kernel.Float for hexadecimal literals with binary exponent interprets the fractional part (on the left side of 'p') in hexadecimal"
  fails "Kernel.Float for hexadecimal literals with binary exponent returns 0 for '0x1P-10000'"
  fails "Kernel.Float for hexadecimal literals with binary exponent returns 0 for '0x1p-10000'"
  fails "Kernel.Float for hexadecimal literals with binary exponent returns Infinity for '0x1P10000'"
  fails "Kernel.Float for hexadecimal literals with binary exponent returns Infinity for '0x1p10000'"
  fails "Kernel.Float when passed exception: false and invalid input swallows an error" # ArgumentError: [Kernel.Float] wrong number of arguments(2 for 1)
  fails "Kernel.Float when passed exception: false and nil swallows it" # ArgumentError: [Kernel.Float] wrong number of arguments(2 for 1)
  fails "Kernel.Float when passed exception: false and valid input returns a Float number" # ArgumentError: [Kernel.Float] wrong number of arguments(2 for 1)
  fails "Kernel.Integer raises a TypeError when to_int returns not-an-Integer object and to_i returns nil" # Expected TypeError but no exception was raised ("1" was returned)
  fails "Kernel.Integer return a result of to_i when to_int does not return an Integer" # Expected "1" == 42 to be truthy but was false
  fails "Kernel.Integer when passed exception: false and an argument that contains a period swallows an error" # TypeError: no implicit conversion of Hash into Integer
  fails "Kernel.Integer when passed exception: false and an empty string swallows an error" # TypeError: no implicit conversion of Hash into Integer
  fails "Kernel.Integer when passed exception: false and invalid argument swallows an error" # ArgumentError: [MSpecEnv#Integer] wrong number of arguments(3 for -2)
  fails "Kernel.Integer when passed exception: false and multiple leading -s swallows an error" # TypeError: no implicit conversion of Hash into Integer
  fails "Kernel.Integer when passed exception: false and multiple trailing -s swallows an error" # TypeError: no implicit conversion of Hash into Integer
  fails "Kernel.Integer when passed exception: false and no to_int or to_i methods exist swallows an error" # ArgumentError: base specified for non string value
  fails "Kernel.Integer when passed exception: false and passed Infinity swallows an error" # ArgumentError: base specified for non string value
  fails "Kernel.Integer when passed exception: false and passed NaN swallows an error" # ArgumentError: base specified for non string value
  fails "Kernel.Integer when passed exception: false and passed a String that can't be converted to an Integer swallows an error" # TypeError: no implicit conversion of Hash into Integer
  fails "Kernel.Integer when passed exception: false and passed a String that contains numbers normally parses it and returns an Integer" # TypeError: no implicit conversion of Hash into Integer
  fails "Kernel.Integer when passed exception: false and passed nil swallows an error" # ArgumentError: base specified for non string value
  fails "Kernel.Integer when passed exception: false and to_i returns a value that is not an Integer swallows an error" # ArgumentError: base specified for non string value
  fails "Kernel.Integer when passed exception: false and to_int returns nil and no to_i exists swallows an error" # ArgumentError: base specified for non string value
  fails "Kernel.Integer when passed exception: false and valid argument returns an Integer number" # ArgumentError: [MSpecEnv#Integer] wrong number of arguments(3 for -2)
  fails "Kernel.Rational when passed a String converts the String to a Rational using the same method as String#to_r"
  fails "Kernel.Rational when passed a String does not use the same method as Float#to_r"
  fails "Kernel.Rational when passed a String raises a TypeError if the first argument is a Symbol"
  fails "Kernel.Rational when passed a String raises a TypeError if the second argument is a Symbol"
  fails "Kernel.Rational when passed a String scales the Rational value of the first argument by the Rational value of the second"
  fails "Kernel.Rational when passed a String when passed a Numeric calls #to_r to convert the first argument to a Rational"
  fails "Kernel.Rational when passed exception: false and [anything, non-Numeric] swallows an error" # ArgumentError: [MSpecEnv#Rational] wrong number of arguments(3 for -2)
  fails "Kernel.Rational when passed exception: false and [non-Numeric, Numeric] swallows an error" # ArgumentError: [MSpecEnv#Rational] wrong number of arguments(3 for -2)
  fails "Kernel.Rational when passed exception: false and [non-Numeric] swallows an error" # NoMethodError: undefined method `to_i' for {"exception"=>false}
  fails "Kernel.Rational when passed exception: false and nil arguments swallows an error" # TypeError: cannot convert nil into Rational
  fails "Kernel.Rational when passed exception: false and non-Numeric String arguments swallows an error" # ArgumentError: [MSpecEnv#Rational] wrong number of arguments(3 for -2)
  fails "Kernel.String calls #to_s if #respond_to?(:to_s) returns true" # TypeError: no implicit conversion of MockObject into String
  fails "Kernel.String raises a TypeError if #to_s is not defined, even though #respond_to?(:to_s) returns true"
  fails "Kernel.__callee__ returns method name even from eval"
  fails "Kernel.__callee__ returns method name even from send"
  fails "Kernel.__callee__ returns the aliased name when aliased method"
  fails "Kernel.__callee__ returns the caller from a define_method called from the same class"
  fails "Kernel.__callee__ returns the caller from block inside define_method too"
  fails "Kernel.__callee__ returns the caller from blocks too"
  fails "Kernel.__callee__ returns the caller from define_method too"
  fails "Kernel.__method__ returns method name even from eval"
  fails "Kernel.__method__ returns method name even from send"
  fails "Kernel.__method__ returns the caller from block inside define_method too"
  fails "Kernel.__method__ returns the caller from blocks too"
  fails "Kernel.__method__ returns the caller from define_method too"
  fails "Kernel.autoload calls #to_path on non-String filenames" # Mock 'path' expected to receive to_path("any_args") exactly 1 times but received it 0 times
  fails "Kernel.autoload when called from included module's method setups the autoload on the included module" # NoMethodError: undefined method `autoload?' for KernelSpecs::AutoloadMethod2
  fails "Kernel.autoload when called from included module's method the autoload relative to the included module works" # NameError: uninitialized constant KernelSpecs::AutoloadMethod2::AutoloadFromIncludedModule2
  fails "Kernel.global_variables finds subset starting with std"
  fails "Kernel.lambda does not create lambda-style Procs when captured with #method" # Expected true to be false
  fails "Kernel.lambda raises an ArgumentError when no block is given"
  fails "Kernel.lambda returns the passed Proc if given an existing Proc through super" # Expected true to be false
  fails "Kernel.lambda returns the passed Proc if given an existing Proc" # Expected true to be false
  fails "Kernel.loop returns StopIteration#result, the result value of a finished iterator" # requires changes in enumerator.rb
  fails "Kernel.printf calls write on the first argument when it is not a string"
  fails "Kernel.printf formatting io is not specified other formats c raises TypeError if argument is nil" # Expected TypeError (/no implicit conversion from nil to integer/) but got: TypeError (no implicit conversion of NilClass into Integer)
  fails "Kernel.printf formatting io is not specified other formats c raises TypeError if argument is not String or Integer and cannot be converted to them" # Expected TypeError (/no implicit conversion of Array into Integer/) but got: ArgumentError (too few arguments)
  fails "Kernel.printf formatting io is not specified other formats c raises TypeError if converting to Integer with to_int returns non-Integer" # Expected TypeError (/can't convert BasicObject to String/) but got: NoMethodError (undefined method `respond_to?' for #<BasicObject:0x69f02>)
  fails "Kernel.printf formatting io is not specified other formats c raises TypeError if converting to String with to_str returns non-String" # Expected TypeError (/can't convert BasicObject to String/) but got: NoMethodError (undefined method `respond_to?' for #<BasicObject:0x69f0c>)
  fails "Kernel.printf formatting io is not specified other formats c tries to convert argument to Integer with to_int" # NoMethodError: undefined method `respond_to?' for #<BasicObject:0x69f24>
  fails "Kernel.printf formatting io is not specified other formats c tries to convert argument to String with to_str" # NoMethodError: undefined method `respond_to?' for #<BasicObject:0x69f1e>
  fails "Kernel.printf formatting io is not specified other formats s preserves encoding of the format string" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT (dummy)> to be truthy but was false
  fails "Kernel.printf formatting io is specified other formats c raises TypeError if argument is nil" # Expected TypeError (/no implicit conversion from nil to integer/) but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified other formats c raises TypeError if argument is not String or Integer and cannot be converted to them" # Expected TypeError (/no implicit conversion of Array into Integer/) but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified other formats c raises TypeError if converting to Integer with to_int returns non-Integer" # Expected TypeError (/can't convert BasicObject to String/) but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified other formats c raises TypeError if converting to String with to_str returns non-String" # Expected TypeError (/can't convert BasicObject to String/) but got: Exception (format_string.indexOf is not a function)
  fails "Kernel.printf formatting io is specified other formats c tries to convert argument to Integer with to_int" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats c tries to convert argument to String with to_str" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats s formats nil with precision" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats s formats nil with width" # Exception: format_string.indexOf is not a function
  fails "Kernel.printf formatting io is specified other formats s preserves encoding of the format string" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT (dummy)> to be truthy but was false
  fails "Kernel.printf writes to stdout when a string is the first argument"
  fails "Kernel.proc returned the passed Proc if given an existing Proc" # Expected false to be true
  fails "Kernel.rand is random on boot" # NoMethodError: undefined method `insert' for "rubyexe.rb"
  fails "Kernel.rand supports custom object types" # Expected "NaN#<struct KernelSpecs::CustomRangeInteger value=1>" (String) to be an instance of KernelSpecs::CustomRangeInteger
  fails "Kernel.sprintf %c raises error when a codepoint isn't representable in an encoding of a format string" # Expected RangeError (/out of char range/) but no exception was raised ("Ԇ" was returned)
  fails "Kernel.sprintf %c uses the encoding of the format string to interpret codepoints" # ArgumentError: unknown encoding name - euc-jp
  fails "Kernel.sprintf can produce a string with invalid encoding" # Expected true to be false
  fails "Kernel.sprintf flags # applies to format o does nothing for negative argument" # Expected "0..7651" to equal "..7651"
  fails "Kernel.sprintf flags # applies to formats aAeEfgG changes format from dd.dddd to exponential form for gG" # Expected "1.234e+02" to equal "1.e+02"
  fails "Kernel.sprintf flags # applies to formats aAeEfgG forces a decimal point to be added, even if no digits follow" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.sprintf flags (digit)$ specifies the absolute argument number for this field" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.sprintf flags * left-justifies the result if specified with $ argument is negative" # Expected "1.095200e+2         " to equal "1.095200e+02        "
  fails "Kernel.sprintf flags * left-justifies the result if width is negative" # Expected "1.095200e+2         " to equal "1.095200e+02        "
  fails "Kernel.sprintf flags * raises ArgumentError when is mixed with width" # Expected ArgumentError but no exception was raised ("       112" was returned)
  fails "Kernel.sprintf flags * uses the previous argument as the field width" # Expected "         1.095200e+02" to equal "        1.095200e+02"
  fails "Kernel.sprintf flags * uses the specified argument as the width if * is followed by a number and $" # Expected "         1.095200e+02" to equal "        1.095200e+02"
  fails "Kernel.sprintf flags + applies to numeric formats bBdiouxXaAeEfgG adds a leading plus sign to non-negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.sprintf flags - left-justifies the result of conversion if width is specified" # Expected "1.095200e+2         " to equal "1.095200e+02        "
  fails "Kernel.sprintf flags 0 (zero) applies to numeric formats bBdiouxXaAeEfgG and width is specified pads with zeros, not spaces" # Expected "0000000001.095200e+02" to equal "000000001.095200e+02"
  fails "Kernel.sprintf flags space applies to numeric formats bBdiouxXeEfgGaA does not leave a space at the start of negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.sprintf flags space applies to numeric formats bBdiouxXeEfgGaA leaves a space at the start of non-negative numbers" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.sprintf flags space applies to numeric formats bBdiouxXeEfgGaA treats several white spaces as one" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.sprintf float formats A converts floating point argument as [-]0xh.hhhhp[+-]dd and use uppercase X and P" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.sprintf float formats A displays Float::INFINITY as Inf" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.sprintf float formats A displays Float::NAN as NaN" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.sprintf float formats G otherwise cuts excessive digits in fractional part and keeps only 4 ones" # Expected "12.12341111" to equal "12.1234"
  fails "Kernel.sprintf float formats G otherwise cuts fraction part to have only 6 digits at all" # Expected "1.1234567" to equal "1.12346"
  fails "Kernel.sprintf float formats G otherwise rounds the last significant digit to the closest one in fractional part" # Expected "1.555555555" to equal "1.55556"
  fails "Kernel.sprintf float formats G the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # Expected "1.234567E+06" to equal "1.23457E+06"
  fails "Kernel.sprintf float formats a converts floating point argument as [-]0xh.hhhhp[+-]dd" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.sprintf float formats a displays Float::INFINITY as Inf" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.sprintf float formats a displays Float::NAN as NaN" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.sprintf float formats g otherwise cuts excessive digits in fractional part and keeps only 4 ones" # Expected "12.12341111" to equal "12.1234"
  fails "Kernel.sprintf float formats g otherwise cuts fraction part to have only 6 digits at all" # Expected "1.1234567" to equal "1.12346"
  fails "Kernel.sprintf float formats g otherwise rounds the last significant digit to the closest one in fractional part" # Expected "1.555555555" to equal "1.55556"
  fails "Kernel.sprintf float formats g the exponent is greater than or equal to the precision (6 by default) converts a floating point number using exponential form" # Expected "1.234567e+06" to equal "1.23457e+06"
  fails "Kernel.sprintf integer formats d works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
  fails "Kernel.sprintf integer formats i works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
  fails "Kernel.sprintf integer formats u works well with large numbers" # Expected "1234567890987654400" to equal "1234567890987654321"
  fails "Kernel.sprintf other formats % alone raises an ArgumentError" # Expected ArgumentError but no exception was raised ("%" was returned)
  fails "Kernel.sprintf other formats c raises TypeError if argument is nil" # Expected TypeError (/no implicit conversion from nil to integer/) but got: TypeError (no implicit conversion of NilClass into Integer)
  fails "Kernel.sprintf other formats c raises TypeError if argument is not String or Integer and cannot be converted to them" # Expected TypeError (/no implicit conversion of Array into Integer/) but got: ArgumentError (too few arguments)
  fails "Kernel.sprintf other formats c raises TypeError if converting to Integer with to_int returns non-Integer" # Expected TypeError (/can't convert BasicObject to String/) but got: NoMethodError (undefined method `respond_to?' for #<BasicObject:0x7bc3a>)
  fails "Kernel.sprintf other formats c raises TypeError if converting to String with to_str returns non-String" # Expected TypeError (/can't convert BasicObject to String/) but got: NoMethodError (undefined method `respond_to?' for #<BasicObject:0x7bc62>)
  fails "Kernel.sprintf other formats c tries to convert argument to Integer with to_int" # NoMethodError: undefined method `respond_to?' for #<BasicObject:0x7bc42>
  fails "Kernel.sprintf other formats c tries to convert argument to String with to_str" # NoMethodError: undefined method `respond_to?' for #<BasicObject:0x7bc46>
  fails "Kernel.sprintf other formats s preserves encoding of the format string" # Expected #<Encoding:UTF-8> == #<Encoding:ASCII-8BIT (dummy)> to be truthy but was false
  fails "Kernel.sprintf precision float types controls the number of decimal places displayed in fraction part" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.sprintf precision float types does not affect G format" # Expected "12.12340000" to equal "12.1234"
  fails "Kernel.sprintf precision string formats determines the maximum number of characters to be copied from the string" # Expected "1" to equal "["
  fails "Kernel.sprintf raises Encoding::CompatibilityError if both encodings are ASCII compatible and there ano not ASCII characters" # ArgumentError: unknown encoding name - windows-1252
  fails "Kernel.sprintf raises Encoding::CompatibilityError if both encodings are ASCII compatible and there are not ASCII characters" # ArgumentError: unknown encoding name - windows-1252
  fails "Kernel.sprintf returns a String in the same encoding as the format String if compatible" # NameError: uninitialized constant Encoding::KOI8_U
  fails "Kernel.sprintf width specifies the minimum number of characters that will be written to the result" # Expected "         1.095200e+02" to equal "        1.095200e+02"
  fails "Kernel.srand returns the previous seed value on the first call" # NoMethodError: undefined method `insert' for "rubyexe.rb"
  fails_badly "Kernel#autoload registers a file to load the first time the named constant is accessed" # NoMethodError: undefined method `autoload?' for #<MSpecEnv:0x5b168>
end
