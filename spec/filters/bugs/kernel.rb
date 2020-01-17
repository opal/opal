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
  fails "Kernel#String calls #to_s if #respond_to?(:to_s) returns true" # TypeError: no implicit conversion of MockObject into String
  fails "Kernel#String raises a TypeError if #to_s is not defined, even though #respond_to?(:to_s) returns true"
  fails "Kernel#__dir__ returns the real name of the directory containing the currently-executing file"
  fails "Kernel#__dir__ when used in eval with a given filename returns File.dirname(filename)" # ArgumentError: [MSpecEnv#eval] wrong number of arguments(3 for 1)
  fails "Kernel#__dir__ when used in eval with top level binding returns the real name of the directory containing the currently-executing file"
  fails "Kernel#autoload calls main.require(path) to load the file" # NameError: uninitialized constant TOPLEVEL_BINDING
  fails "Kernel#autoload can autoload in instance_eval" # NameError: uninitialized constant KSAutoloadD
  fails "Kernel#autoload is a private method" # Expected Kernel to have private instance method 'autoload' but it does not
  fails "Kernel#autoload loads the file when the constant is accessed" # NameError: uninitialized constant KSAutoloadB
  fails "Kernel#autoload registers a file to load the first time the named constant is accessed" # NoMethodError: undefined method `autoload?' for #<MSpecEnv:0x7849c>
  fails "Kernel#autoload sets the autoload constant in Object's constant table" # Expected Object to have constant 'KSAutoloadA' but it does not
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
  fails "Kernel#class returns the class of the object"
  fails "Kernel#clone replaces a singleton object's metaclass with a new copy with the same superclass" # NoMethodError: undefined method `singleton_methods' for #<#<Class:0x2df8e>:0x2df90>
  fails "Kernel#clone uses the internal allocator and does not call #allocate" # RuntimeError: allocate should not be called
  fails "Kernel#define_singleton_method when given an UnboundMethod will raise when attempting to define an object's singleton method from another object's singleton method"
  fails "Kernel#dup uses the internal allocator and does not call #allocate" # RuntimeError: allocate should not be called
  fails "Kernel#eval allows a binding to be captured inside an eval"
  fails "Kernel#eval allows creating a new class in a binding created by #eval"
  fails "Kernel#eval allows creating a new class in a binding"
  fails "Kernel#eval can be aliased"
  fails "Kernel#eval does not alter the value of __FILE__ in the binding"
  fails "Kernel#eval does not make Proc locals visible to evaluated code"
  fails "Kernel#eval does not share locals across eval scopes"
  fails "Kernel#eval doesn't accept a Proc object as a binding"
  fails "Kernel#eval evaluates string with given filename and negative linenumber" # NameError: uninitialized constant TOPLEVEL_BINDING
  fails "Kernel#eval finds a local in an enclosing scope"
  fails "Kernel#eval finds locals in a nested eval"
  fails "Kernel#eval includes file and line information in syntax error"
  fails "Kernel#eval raises a LocalJumpError if there is no lambda-style closure in the chain"
  fails "Kernel#eval unwinds through a Proc-style closure and returns from a lambda-style closure in the closure chain"
  fails "Kernel#eval updates a local in a scope above a surrounding block scope"
  fails "Kernel#eval updates a local in a scope above when modified in a nested block scope"
  fails "Kernel#eval updates a local in a surrounding block scope"
  fails "Kernel#eval updates a local in an enclosing scope"
  fails "Kernel#eval uses the filename of the binding if none is provided"
  fails "Kernel#eval uses the same scope for local variables when given the same binding"
  fails "Kernel#eval with a magic encoding comment allows a magic encoding comment and a frozen_string_literal magic comment on the same line in emacs style" # Opal::SyntaxError: unexpected token $end
  fails "Kernel#eval with a magic encoding comment allows a magic encoding comment and a subsequent frozen_string_literal magic comment" # Opal::SyntaxError: unexpected token $end
  fails "Kernel#eval with a magic encoding comment allows a shebang line and some spaces before the magic encoding comment" # Opal::SyntaxError: unexpected token $end
  fails "Kernel#eval with a magic encoding comment allows a shebang line before the magic encoding comment" # Opal::SyntaxError: unexpected token $end
  fails "Kernel#eval with a magic encoding comment allows an emacs-style magic comment encoding" # Opal::SyntaxError: unexpected token $end
  fails "Kernel#eval with a magic encoding comment allows spaces before the magic encoding comment" # Opal::SyntaxError: unexpected token $end
  fails "Kernel#eval with a magic encoding comment ignores the magic encoding comment if it is after a frozen_string_literal magic comment" # Opal::SyntaxError: unexpected token $end
  fails "Kernel#eval with a magic encoding comment uses the magic comment encoding for parsing constants" # Opal::SyntaxError: unexpected token $end
  fails "Kernel#eval with a magic encoding comment uses the magic comment encoding for the encoding of literal strings" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:UTF-8>
  fails "Kernel#extend does not calls append_features on arguments metaclass"
  fails "Kernel#extend raises an ArgumentError when no arguments given"
  fails "Kernel#fail accepts an Object with an exception method returning an Exception" # TypeError: exception class/object expected
  fails "Kernel#inspect does not call #to_s if it is defined"
  fails "Kernel#instance_variables immediate values returns the correct array if an instance variable is added"
  fails "Kernel#is_a? does not take into account `class` method overriding" # TypeError: can't define singleton
  fails "Kernel#is_a? returns true if given a Module that object has been extended with" # Requires string mutability
  fails "Kernel#kind_of? does not take into account `class` method overriding" # TypeError: can't define singleton
  fails "Kernel#kind_of? returns true if given a Module that object has been extended with" # Requires string mutability
  fails "Kernel#local_variables contains locals as they are added"
  fails "Kernel#local_variables is accessible from bindings"
  fails "Kernel#local_variables is accessible in eval"
  fails "Kernel#method can be called even if we only repond_to_missing? method, true"
  fails "Kernel#method returns a method object if we repond_to_missing? method"
  fails "Kernel#method will see an alias of the original method as == when in a derived class"
  fails "Kernel#methods does not return private singleton methods defined in 'class << self'"
  fails "Kernel#methods returns the publicly accessible methods of the object"
  fails "Kernel#object_id returns a different value for two Bignum literals"
  fails "Kernel#object_id returns a different value for two String literals"
  fails "Kernel#p flushes output if receiver is a File"
  fails "Kernel#p is not affected by setting $\\, $/ or $,"
  fails "Kernel#pp lazily loads the 'pp' library and delegates the call to that library" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x4f28>
  fails "Kernel#proc uses the implicit block from an enclosing method"
  fails "Kernel#public_method changes the method called for super on a target aliased method"
  fails "Kernel#public_method raises a NameError if we only repond_to_missing? method, true"
  fails "Kernel#public_method returns a method object for a valid method"
  fails "Kernel#public_method returns a method object for a valid singleton method"
  fails "Kernel#public_method returns a method object if we repond_to_missing? method"
  fails "Kernel#public_methods returns a list of names without protected accessible methods in the object"
  fails "Kernel#public_methods when passed false returns a list of public methods in without its ancestors"
  fails "Kernel#public_methods when passed nil returns a list of public methods in without its ancestors"
  fails "Kernel#public_send raises a TypeError if the method name is not a string or symbol" # NoMethodError: undefined method `' for SendSpecs
  fails "Kernel#puts delegates to $stdout.puts"
  fails "Kernel#raise raises RuntimeError if no exception class is given" # RuntimeError: RuntimeError
  fails "Kernel#raise re-raises a previously rescued exception without overwriting the backtrace" # Expected "RuntimeError: raised" to include "ruby/shared/kernel/raise.rb:65:"
  fails "Kernel#respond_to? throws a type error if argument can't be coerced into a Symbol"
  fails "Kernel#respond_to_missing? causes #respond_to? to return false if called and returning false"
  fails "Kernel#respond_to_missing? causes #respond_to? to return false if called and returning nil"
  fails "Kernel#respond_to_missing? causes #respond_to? to return true if called and not returning false"
  fails "Kernel#respond_to_missing? is called a 2nd argument of false when #respond_to? is called with only 1 argument"
  fails "Kernel#respond_to_missing? is called for missing class methods"
  fails "Kernel#respond_to_missing? is called when #respond_to? would return false"
  fails "Kernel#respond_to_missing? is called with a 2nd argument of false when #respond_to? is"
  fails "Kernel#respond_to_missing? is called with true as the second argument when #respond_to? is"
  fails "Kernel#respond_to_missing? is not called when #respond_to? would return true"
  fails "Kernel#respond_to_missing? isn't called when obj responds to the given public method"
  fails "Kernel#send raises a TypeError if the method name is not a string or symbol" # NoMethodError: undefined method `' for SendSpecs
  fails "Kernel#singleton_class raises TypeError for Fixnum"
  fails "Kernel#singleton_class raises TypeError for Symbol"
  fails "Kernel#singleton_method find a method defined on the singleton class" # NoMethodError: undefined method `singleton_method' for #<Object:0x39d20>
  fails "Kernel#singleton_method only looks at singleton methods and not at methods in the class" # Expected NoMethodError to equal NameError
  fails "Kernel#singleton_method raises a NameError if there is no such method" # Expected NoMethodError to equal NameError
  fails "Kernel#singleton_method returns a Method which can be called" # NoMethodError: undefined method `singleton_method' for #<Object:0x39d1a>
  fails "Kernel#singleton_methods when not passed an argument does not return any included methods for a class including a module"
  fails "Kernel#singleton_methods when not passed an argument does not return any included methods for a module including a module"
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
  fails "Kernel#singleton_methods when not passed an argument returns the names of singleton methods for an object extented with a module including a module"
  fails "Kernel#singleton_methods when not passed an argument returns the names of singleton methods for an object extented with a module"
  fails "Kernel#singleton_methods when not passed an argument returns the names of singleton methods for an object extented with two modules"
  fails "Kernel#singleton_methods when not passed an argument returns the names of singleton methods for an object"
  fails "Kernel#singleton_methods when passed false does not return any included methods for a class including a module"
  fails "Kernel#singleton_methods when passed false does not return any included methods for a module including a module"
  fails "Kernel#singleton_methods when passed false does not return names of inherited singleton methods for a subclass"
  fails "Kernel#singleton_methods when passed false does not return the names of inherited singleton methods for a class extended with a module"
  fails "Kernel#singleton_methods when passed false for a module does not return methods in a module prepended to Module itself" # NoMethodError: undefined method `singleton_methods' for SingletonMethodsSpecs::SelfExtending
  fails "Kernel#singleton_methods when passed false returns an empty Array for an object extended with a module including a module"
  fails "Kernel#singleton_methods when passed false returns an empty Array for an object extented with a module"
  fails "Kernel#singleton_methods when passed false returns an empty Array for an object extented with two modules"
  fails "Kernel#singleton_methods when passed false returns an empty Array for an object with no singleton methods"
  fails "Kernel#singleton_methods when passed false returns the names of class methods for a class"
  fails "Kernel#singleton_methods when passed false returns the names of module methods for a module"
  fails "Kernel#singleton_methods when passed false returns the names of singleton methods for an object"
  fails "Kernel#singleton_methods when passed false returns the names of singleton methods of the subclass"
  fails "Kernel#singleton_methods when passed true does not return any included methods for a class including a module"
  fails "Kernel#singleton_methods when passed true does not return any included methods for a module including a module"
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
  fails "Kernel#singleton_methods when passed true returns the names of singleton methods for an object extented with a module including a module"
  fails "Kernel#singleton_methods when passed true returns the names of singleton methods for an object extented with a module"
  fails "Kernel#singleton_methods when passed true returns the names of singleton methods for an object extented with two modules"
  fails "Kernel#singleton_methods when passed true returns the names of singleton methods for an object"
  fails "Kernel#sprintf faulty key raises a KeyError"
  fails "Kernel#sprintf faulty key sets the Hash as the receiver of KeyError"
  fails "Kernel#sprintf faulty key sets the unmatched key as the key of KeyError"
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
  fails "Kernel#sprintf precision float types controls the number of decimal places displayed in fraction part" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel#sprintf precision float types does not affect G format" # Expected "12.12340000" to equal "12.1234"
  fails "Kernel#sprintf precision string formats determines the maximum number of characters to be copied from the string" # Expected "1" to equal "["
  fails "Kernel#sprintf raises Encoding::CompatibilityError if both encodings are ASCII compatible and there ano not ASCII characters" # ArgumentError: unknown encoding name - windows-1252
  fails "Kernel#sprintf returns a String in the argument's encoding if format encoding is more restrictive" # Expected #<Encoding:UTF-16LE> to be identical to #<Encoding:UTF-8>
  fails "Kernel#sprintf width specifies the minimum number of characters that will be written to the result" # Expected "         1.095200e+02" to equal "        1.095200e+02"
  fails "Kernel#sprintf with format string that contains %<> sections raises ArgumentError if missing second named argument" # KeyError: key not found: "foo"
  fails "Kernel#warn :uplevel keyword argument converts value to Integer"
  fails "Kernel#warn :uplevel keyword argument does not prepend caller information if line number is too big"
  fails "Kernel#warn :uplevel keyword argument prepends a message with specified line from the backtrace"
  fails "Kernel#warn :uplevel keyword argument prepends even if a message is empty or nil"
  fails "Kernel#warn writes each array element on a line when passes an array" # Expected:   $stderr: "line 1\nline 2\n"      got:   $stderr: "[\"line 1\", \"line 2\"]\n"
  fails "Kernel#yield_self returns a sized Enumerator when no block given" # Requires Enumerator#peek
  fails "Kernel.Complex() when passed Numerics n1 and n2 and at least one responds to #real? with false returns n1 + n2 * Complex(0, 1)"
  fails "Kernel.Complex() when passed [Complex, Complex] returns a new Complex number based on the two given numbers"
  fails "Kernel.Complex() when passed [Complex] returns the passed Complex number"
  fails "Kernel.Complex() when passed a Numeric which responds to #real? with false returns the passed argument"
  fails "Kernel.Complex() when passed a non-Numeric second argument raises TypeError"
  fails "Kernel.Complex() when passed a single non-Numeric coerces the passed argument using #to_c"
  fails "Kernel.Complex() when passed an Object which responds to #to_c returns the passed argument" # Expected (#<Object:0x332c0>+0i) to equal (0+1i)
  fails "Kernel.Complex() when passed an Objectc which responds to #to_c returns the passed argument" # Expected (#<Object:0x46fa6>+0i) to equal (0+1i)
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
  fails "Kernel.Rational when passed a String converts the String to a Rational using the same method as String#to_r"
  fails "Kernel.Rational when passed a String does not use the same method as Float#to_r"
  fails "Kernel.Rational when passed a String raises a TypeError if the first argument is a Symbol"
  fails "Kernel.Rational when passed a String raises a TypeError if the second argument is a Symbol"
  fails "Kernel.Rational when passed a String scales the Rational value of the first argument by the Rational value of the second"
  fails "Kernel.Rational when passed a String when passed a Numeric calls #to_r to convert the first argument to a Rational"
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
  fails "Kernel.autoload registers a file to load the first time the toplevel constant is accessed" # NoMethodError: undefined method `autoload?' for Kernel
  fails "Kernel.autoload sets the autoload constant in Object's constant table" # Expected Object to have constant 'KSAutoloadBB' but it does not
  fails "Kernel.autoload when called from included module's method setups the autoload on the included module" # NoMethodError: undefined method `autoload?' for KernelSpecs::AutoloadMethod2
  fails "Kernel.autoload when called from included module's method the autoload is reachable from the class too" # NoMethodError: undefined method `autoload?' for KernelSpecs::AutoloadMethodIncluder2
  fails "Kernel.autoload when called from included module's method the autoload relative to the included module works" # NameError: uninitialized constant KernelSpecs::AutoloadMethod2::AutoloadFromIncludedModule2
  fails "Kernel.autoload? returns nil if no file has been registered for a constant" # NoMethodError: undefined method `autoload?' for Kernel
  fails "Kernel.autoload? returns the name of the file that will be autoloaded" # NoMethodError: undefined method `autoload?' for Kernel
  fails "Kernel.global_variables finds subset starting with std"
  fails "Kernel.lambda raises an ArgumentError when no block is given"
  fails "Kernel.lambda returned the passed Proc if given an existing Proc" # Expected true to be false
  fails "Kernel.lambda returns from the lambda itself, not the creation site of the lambda"
  fails "Kernel.loop returns StopIteration#result, the result value of a finished iterator" # requires changes in enumerator.rb
  fails "Kernel.printf calls write on the first argument when it is not a string"
  fails "Kernel.printf writes to stdout when a string is the first argument"
  fails "Kernel.proc returned the passed Proc if given an existing Proc" # Expected false to be true
  fails "Kernel.rand supports custom object types" # Expected "NaN#<struct KernelSpecs::CustomRangeInteger value=1>" (String) to be an instance of KernelSpecs::CustomRangeInteger
  fails "Kernel.sprintf faulty key raises a KeyError"
  fails "Kernel.sprintf faulty key sets the Hash as the receiver of KeyError"
  fails "Kernel.sprintf faulty key sets the unmatched key as the key of KeyError"
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
  fails "Kernel.sprintf precision float types controls the number of decimal places displayed in fraction part" # NotImplementedError: `A` and `a` format field types are not implemented in Opal yet
  fails "Kernel.sprintf precision float types does not affect G format" # Expected "12.12340000" to equal "12.1234"
  fails "Kernel.sprintf precision string formats determines the maximum number of characters to be copied from the string" # Expected "1" to equal "["
  fails "Kernel.sprintf raises Encoding::CompatibilityError if both encodings are ASCII compatible and there ano not ASCII characters" # ArgumentError: unknown encoding name - windows-1252
  fails "Kernel.sprintf returns a String in the argument's encoding if format encoding is more restrictive" # Expected #<Encoding:UTF-16LE> to be identical to #<Encoding:UTF-8>
  fails "Kernel.sprintf returns a String in the same encoding as the format String if compatible" # NameError: uninitialized constant Encoding::KOI8_U
  fails "Kernel.sprintf width specifies the minimum number of characters that will be written to the result" # Expected "         1.095200e+02" to equal "        1.095200e+02"
end
