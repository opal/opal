# NOTE: run bin/format-filters after changing this file
opal_filter "Module" do
  fails "Module#alias_method creates methods that are == to each other" # Expected #<Method: #<Class:0x9122>#uno (defined in #<Class:0x9122> in ruby/core/module/fixtures/classes.rb:206)> == #<Method: #<Class:0x9122>#public_one (defined in ModuleSpecs::Aliasing in ruby/core/module/fixtures/classes.rb:206)> to be truthy but was false
  fails "Module#alias_method creates methods that are == to eachother" # Expected #<Method: #<Class:0x3ee54>#uno (defined in #<Class:0x3ee54> in ruby/core/module/fixtures/classes.rb:203)> to equal #<Method: #<Class:0x3ee54>#public_one (defined in ModuleSpecs::Aliasing in ruby/core/module/fixtures/classes.rb:203)>
  fails "Module#alias_method handles aliasing a method only present in a refinement" # NoMethodError: undefined method `refine' for #<Module:0x90fa>
  fails "Module#alias_method retains method visibility"
  fails "Module#append_features on Class raises a TypeError if calling after rebinded to Class"
  fails "Module#attr applies current visibility to methods created"
  fails "Module#attr converts non string/symbol names to strings using to_str" # Expected false == true to be truthy but was false
  fails "Module#attr converts non string/symbol/fixnum names to strings using to_str"
  fails "Module#attr raises a TypeError when the given names can't be converted to strings using to_str"
  fails "Module#attr_accessor applies current visibility to methods created"
  fails "Module#attr_accessor converts non string/symbol names to strings using to_str" # Expected false == true to be truthy but was false
  fails "Module#attr_accessor converts non string/symbol/fixnum names to strings using to_str"
  fails "Module#attr_accessor not allows creating an attr_accessor on an immediate class"
  fails "Module#attr_accessor on immediates can read through the accessor" # NoMethodError: undefined method `foobar' for 1
  fails "Module#attr_accessor raises a TypeError when the given names can't be converted to strings using to_str"
  fails "Module#attr_reader applies current visibility to methods created"
  fails "Module#attr_reader converts non string/symbol names to strings using to_str" # Expected false == true to be truthy but was false
  fails "Module#attr_reader converts non string/symbol/fixnum names to strings using to_str"
  fails "Module#attr_reader not allows for adding an attr_reader to an immediate"
  fails "Module#attr_reader raises a TypeError when the given names can't be converted to strings using to_str"
  fails "Module#attr_writer applies current visibility to methods created"
  fails "Module#attr_writer converts non string/symbol names to strings using to_str" # Expected false == true to be truthy but was false
  fails "Module#attr_writer converts non string/symbol/fixnum names to strings using to_str"
  fails "Module#attr_writer not allows for adding an attr_writer to an immediate"
  fails "Module#attr_writer raises a TypeError when the given names can't be converted to strings using to_str"
  fails "Module#autoload (concurrently) blocks a second thread while a first is doing the autoload"
  fails "Module#autoload (concurrently) blocks others threads while doing an autoload"
  fails "Module#autoload allows multiple autoload constants for a single file"
  fails "Module#autoload calls #to_path on non-String filename arguments"
  fails "Module#autoload calls #to_path on non-string filenames"
  fails "Module#autoload does NOT raise a NameError when the autoload file did not define the constant and a module is opened with the same name"
  fails "Module#autoload does not load the file if the file is manually required"
  fails "Module#autoload does not load the file when accessing the constants table of the module"
  fails "Module#autoload does not load the file when referring to the constant in defined?"
  fails "Module#autoload does not remove the constant from the constant table if load fails"
  fails "Module#autoload does not remove the constant from the constant table if the loaded files does not define it"
  fails "Module#autoload ignores the autoload request if the file is already loaded"
  fails "Module#autoload loads a file with .rb extension when passed the name without the extension"
  fails "Module#autoload loads the file that defines subclass XX::YY < YY and YY is a top level constant"
  fails "Module#autoload loads the file when opening a module that is the autoloaded constant"
  fails "Module#autoload loads the registered constant into a dynamically created class"
  fails "Module#autoload loads the registered constant into a dynamically created module"
  fails "Module#autoload loads the registered constant when it is accessed"
  fails "Module#autoload loads the registered constant when it is included"
  fails "Module#autoload loads the registered constant when it is inherited from"
  fails "Module#autoload loads the registered constant when it is opened as a class"
  fails "Module#autoload loads the registered constant when it is opened as a module"
  fails "Module#autoload looks up the constant in the scope where it is referred"
  fails "Module#autoload looks up the constant when in a meta class scope"
  fails "Module#autoload raises a NameError when the constant name has a space in it"
  fails "Module#autoload raises a NameError when the constant name starts with a lower case letter"
  fails "Module#autoload raises a NameError when the constant name starts with a number"
  fails "Module#autoload raises a TypeError if not passed a String or object respodning to #to_path for the filename"
  fails "Module#autoload raises a TypeError if opening a class with a different superclass than the class defined in the autoload file"
  fails "Module#autoload raises an ArgumentError when an empty filename is given"
  fails "Module#autoload registers a file to load the first time the named constant is accessed"
  fails "Module#autoload retains the autoload even if the request to require fails"
  fails "Module#autoload returns 'constant' on referring the constant with defined?()"
  fails "Module#autoload runs for an exception condition class and doesn't trample the exception"
  fails "Module#autoload sets the autoload constant in the constants table"
  fails "Module#autoload shares the autoload request across dup'ed copies of modules"
  fails "Module#autoload when changing $LOAD_PATH does not reload a file due to a different load path"
  fails "Module#autoload? returns nil if no file has been registered for a constant"
  fails "Module#autoload? returns the name of the file that will be autoloaded"
  fails "Module#class_eval activates refinements from the eval scope with block" # NoMethodError: undefined method `refine' for #<Module:0x89ba>
  fails "Module#class_eval activates refinements from the eval scope" # NoMethodError: undefined method `refine' for #<Module:0x90be>
  fails "Module#class_eval converts a non-string filename to a string using to_str"
  fails "Module#class_eval converts non string eval-string to string using to_str"
  fails "Module#class_eval raises a TypeError when the given eval-string can't be converted to string using to_str"
  fails "Module#class_eval raises a TypeError when the given filename can't be converted to string using to_str"
  fails "Module#class_eval resolves constants in the caller scope ignoring send"
  fails "Module#class_eval resolves constants in the caller scope" # fails because of the difference between module_eval("Const") and module_eval { Const } (only the second one is supported by Opal)
  fails "Module#class_eval uses the optional filename and lineno parameters for error messages"
  fails "Module#const_defined? returns true for toplevel constant when the name begins with '::'"
  fails "Module#const_defined? returns true or false for the nested name"
  fails "Module#const_defined? returns true when passed a scoped constant name for a constant in the inheritance hierarchy and the inherited flag is default"
  fails "Module#const_defined? returns true when passed a scoped constant name for a constant in the inheritance hierarchy and the inherited flag is true"
  fails "Module#const_defined? returns true when passed a scoped constant name"
  fails "Module#const_get does autoload a constant with a toplevel scope qualifier" # NameError: uninitialized constant CSAutoloadB
  fails "Module#const_get does autoload a constant" # NameError: uninitialized constant CSAutoloadA
  fails "Module#const_get does autoload a module and resolve a constant within" # NameError: uninitialized constant CSAutoloadC
  fails "Module#const_get does autoload a non-toplevel module" # LoadError: cannot load such file -- ruby/core/module/fixtures/constants_autoload_d
  fails "Module#const_set when overwriting an existing constant does not warn if the previous value was undefined" # Expected #<Module:0x48fd0> to have constant 'Foo' but it does not
  fails "Module#const_set when overwriting an existing constant warns if the previous value was a normal value" # Expected warning to match: /already initialized constant/ but got: ""
  fails "Module#constants doesn't returns inherited constants when passed nil"
  fails "Module#constants returns only public constants"
  fails "Module#define_method raises a TypeError when a Method from a singleton class is defined on another class"
  fails "Module#define_method raises a TypeError when a Method from one class is defined on an unrelated class"
  fails "Module#define_method raises a TypeError when an UnboundMethod from a child class is defined on a parent class"
  fails "Module#define_method raises a TypeError when an UnboundMethod from a singleton class is defined on another class" # Expected TypeError (/can't bind singleton method to a different class/) but no exception was raised (#<Class:0x47ae6> was returned)
  fails "Module#define_method raises a TypeError when an UnboundMethod from one class is defined on an unrelated class"
  fails "Module#deprecate_constant accepts multiple symbols and strings as constant names"
  fails "Module#deprecate_constant raises a NameError when given an undefined name"
  fails "Module#deprecate_constant returns self"
  fails "Module#deprecate_constant when accessing the deprecated module passes the accessing"
  fails "Module#deprecate_constant when accessing the deprecated module warns with a message"
  fails "Module#extend_object extends the given object with its constants and methods by default"
  fails "Module#extend_object on Class raises a TypeError if calling after rebinded to Class"
  fails "Module#include doesn't accept no-arguments" # Expected ArgumentError but no exception was raised (#<Module:0x4fbac> was returned)
  fails "Module#initialize_copy should produce a duped module with inspectable class methods" # NameError: undefined method `hello' for class `Module'
  fails "Module#initialize_copy should retain singleton methods when duped" # Expected [] to equal ["hello"]
  fails "Module#instance_method raises a NameError if the method has been undefined"
  fails "Module#instance_method raises a TypeError if not passed a symbol"
  fails "Module#instance_method raises a TypeError if the given name is not a string/symbol"
  fails "Module#method_added is called with a precise caller location with the line of the 'def'" # NoMethodError: undefined method `caller_locations' for #<Module:0xaa8>
  fails "Module#method_defined? converts the given name to a string using to_str"
  fails "Module#method_defined? raises a TypeError when the given object is not a string/symbol" # Expected TypeError but no exception was raised (false was returned)
  fails "Module#method_defined? raises a TypeError when the given object is not a string/symbol/fixnum"
  fails "Module#method_defined? returns true if a public or private method with the given name is defined in self, self's ancestors or one of self's included modules"
  fails "Module#module_eval activates refinements from the eval scope with block" # NoMethodError: undefined method `refine' for #<Module:0x81e0>
  fails "Module#module_eval activates refinements from the eval scope" # NoMethodError: undefined method `refine' for #<Module:0x88e4>
  fails "Module#module_eval converts a non-string filename to a string using to_str"
  fails "Module#module_eval converts non string eval-string to string using to_str"
  fails "Module#module_eval raises a TypeError when the given eval-string can't be converted to string using to_str"
  fails "Module#module_eval raises a TypeError when the given filename can't be converted to string using to_str"
  fails "Module#module_eval resolves constants in the caller scope ignoring send"
  fails "Module#module_eval resolves constants in the caller scope"
  fails "Module#module_eval uses the optional filename and lineno parameters for error messages"
  fails "Module#module_function as a toggle (no arguments) in a Module body does not affect module_evaled method definitions also if outside the eval itself"
  fails "Module#module_function as a toggle (no arguments) in a Module body doesn't affect definitions when inside an eval even if the definitions are outside of it"
  fails "Module#module_function as a toggle (no arguments) in a Module body has no effect if inside a module_eval if the definitions are outside of it"
  fails "Module#module_function on Class raises a TypeError if calling after rebinded to Class"
  fails "Module#module_function with specific method names raises a TypeError when the given names can't be converted to string using to_str"
  fails "Module#module_function with specific method names tries to convert the given names to strings using to_str"
  fails "Module#name changes when the module is reachable through a constant path" # Expected nil to match /^#<Module:0x\h+>::N$/
  fails "Module#name is not nil for a nested module created with the module keyword"
  fails "Module#name is set after it is removed from a constant under an anonymous module" # Expected nil to match /^#<Module:0x\h+>::Child$/
  fails "Module#name preserves the encoding in which the class was defined"
  fails "Module#prepend keeps the module in the chain when dupping an intermediate module"
  fails "Module#prepend keeps the module in the chain when dupping the class"
  fails "Module#private with argument one or more arguments sets visibility of given method names" # Expected #<Module:0x2f186> to have private instance method 'test1' but it does not
  fails "Module#private_method_defined? raises a TypeError if passed an Integer" # Expected TypeError but no exception was raised (false was returned)
  fails "Module#protected with argument does not clone method from the ancestor when setting to the same visibility in a child" # NoMethodError: undefined method `protected_instance_methods' for #<Module:0xa2d8>
  fails "Module#protected with argument one or more arguments sets visibility of given method names" # NoMethodError: undefined method `protected_instance_methods' for #<Module:0x33d4a>
  fails "Module#protected_method_defined? raises a TypeError if passed an Integer" # Expected TypeError but no exception was raised (false was returned)
  fails "Module#public_method_defined? raises a TypeError if passed an Integer" # Expected TypeError but no exception was raised (false was returned)
  fails "Module#refine accepts a module as argument" # NoMethodError: undefined method `refine' for #<Module:0x4c172>
  fails "Module#refine adds methods defined in its block to the anonymous module's public instance methods" # NoMethodError: undefined method `refine' for #<Module:0x3ae64>
  fails "Module#refine and alias aliases a method within a refinement module, but not outside it" # NoMethodError: undefined method `refine' for #<Module:0x1aab4>
  fails "Module#refine and alias_method aliases a method within a refinement module, but not outside it" # NoMethodError: undefined method `refine' for #<Module:0x1aab0>
  fails "Module#refine and instance_methods returns a list of methods including those of the refined module" # NoMethodError: undefined method `refine' for #<Module:0x228>
  fails "Module#refine applies refinements to calls in the refine block" # NoMethodError: undefined method `refine' for #<Module:0x3ae7a>
  fails "Module#refine applies refinements to the module" # NoMethodError: undefined method `refine' for #<Module:0x22c>
  fails "Module#refine does not apply refinements to external scopes not using the module" # NoMethodError: undefined method `refine' for #<Module:0x3ae60>
  fails "Module#refine does not list methods defined only in refinement" # NoMethodError: undefined method `refine' for #<Module:0x1e042>
  fails "Module#refine does not make available methods from another refinement module" # NoMethodError: undefined method `refine' for #<Module:0x3ae8c>
  fails "Module#refine does not override methods in subclasses" # NoMethodError: undefined method `refine' for #<Module:0x3ae56>
  fails "Module#refine doesn't apply refinements outside the refine block" # NoMethodError: undefined method `refine' for #<Module:0x3ae72>
  fails "Module#refine for methods accessed indirectly is honored by BasicObject#__send__" # NoMethodError: undefined method `refine' for #<Module:0x3aeb2>
  fails "Module#refine for methods accessed indirectly is honored by Kernel#binding" # NoMethodError: undefined method `refine' for #<Module:0x3aeaa>
  fails "Module#refine for methods accessed indirectly is honored by Kernel#send" # NoMethodError: undefined method `refine' for #<Module:0x3aeae>
  fails "Module#refine for methods accessed indirectly is honored by Symbol#to_proc" # NoMethodError: undefined method `refine' for #<Module:0x3aeba>
  fails "Module#refine for methods accessed indirectly is honored by string interpolation" # NoMethodError: undefined method `refine' for #<Module:0x3aeb6>
  fails "Module#refine for methods accessed indirectly is not honored by &" # NoMethodError: undefined method `refine' for #<Module:0x21e9c>
  fails "Module#refine for methods accessed indirectly is not honored by Kernel#instance_method" # NoMethodError: undefined method `refine' for #<Module:0x4c176>
  fails "Module#refine for methods accessed indirectly is not honored by Kernel#method" # NoMethodError: undefined method `refine' for #<Module:0x3aec0>
  fails "Module#refine for methods accessed indirectly is not honored by Kernel#public_send" # NoMethodError: undefined method `refine' for #<Module:0x21ea0>
  fails "Module#refine for methods accessed indirectly is not honored by Kernel#respond_to?" # NoMethodError: undefined method `refine' for #<Module:0x3aea6>
  fails "Module#refine makes available all refinements from the same module" # NoMethodError: undefined method `refine' for #<Module:0x3ae88>
  fails "Module#refine method lookup looks in included modules from the refinement then" # NoMethodError: undefined method `refine' for #<Module:0x3aea0>
  fails "Module#refine method lookup looks in later included modules of the refined module first" # NoMethodError: undefined method `refine' for #<Module:0x230>
  fails "Module#refine method lookup looks in prepended modules from the refinement first" # NoMethodError: undefined method `refine' for #<Module:0x3ae98>
  fails "Module#refine method lookup looks in refinement then" # NoMethodError: undefined method `refine' for #<Module:0x3ae94>
  fails "Module#refine method lookup looks in the class then" # NoMethodError: undefined method `refine' for #<Module:0x3ae90>
  fails "Module#refine method lookup looks in the included modules for builtin methods" # NoMethodError: undefined method `insert' for "rubyexe.rb"
  fails "Module#refine method lookup looks in the object singleton class first" # NoMethodError: undefined method `refine' for #<Module:0x3ae9c>
  fails "Module#refine module inclusion activates all refinements from all ancestors" # NoMethodError: undefined method `refine' for #<Module:0x3aed4>
  fails "Module#refine module inclusion overrides methods of ancestors by methods in descendants" # NoMethodError: undefined method `refine' for #<Module:0x3aed0>
  fails "Module#refine raises ArgumentError if not given a block" # NoMethodError: undefined method `refine' for #<Module:0x3ae5c>
  fails "Module#refine raises ArgumentError if not passed an argument" # NoMethodError: undefined method `refine' for #<Module:0x3ae80>
  fails "Module#refine raises TypeError if not passed a class" # NoMethodError: undefined method `refine' for #<Module:0x3ae6e>
  fails "Module#refine returns created anonymous module" # NoMethodError: undefined method `refine' for #<Module:0x3ae68>
  fails "Module#refine runs its block in an anonymous module" # NoMethodError: undefined method `refine' for #<Module:0x3ae76>
  fails "Module#refine uses the same anonymous module for future refines of the same class" # NoMethodError: undefined method `refine' for #<Module:0x3ae84>
  fails "Module#refine when super is called in a refinement does't have access to active refinements for C from included module" # NoMethodError: undefined method `refine' for #<Module:0x242>
  fails "Module#refine when super is called in a refinement does't have access to other active refinements from included module" # NoMethodError: undefined method `refine' for #<Module:0x24a>
  fails "Module#refine when super is called in a refinement looks in the another active refinement if super called from included modules" # NoMethodError: undefined method `refine' for #<Module:0x252>
  fails "Module#refine when super is called in a refinement looks in the current active refinement from included modules" # NoMethodError: undefined method `refine' for #<Module:0x256>
  fails "Module#refine when super is called in a refinement looks in the included to refinery module" # NoMethodError: undefined method `refine' for #<Module:0x3aec8>
  fails "Module#refine when super is called in a refinement looks in the lexical scope refinements before other active refinements" # NoMethodError: undefined method `refine' for #<Module:0x236>
  fails "Module#refine when super is called in a refinement looks in the refined ancestors from included module" # NoMethodError: undefined method `refine' for #<Module:0x23e>
  fails "Module#refine when super is called in a refinement looks in the refined class even if there is another active refinement" # NoMethodError: undefined method `refine' for #<Module:0x3aec4>
  fails "Module#refine when super is called in a refinement looks in the refined class first if called from refined method" # NoMethodError: undefined method `refine' for #<Module:0x246>
  fails "Module#refine when super is called in a refinement looks in the refined class from included module" # NoMethodError: undefined method `refine' for #<Module:0x23a>
  fails "Module#refine when super is called in a refinement looks in the refined class" # NoMethodError: undefined method `refine' for #<Module:0x3aecc>
  fails "Module#refine when super is called in a refinement looks only in the refined class even if there is another active refinement" # NoMethodError: undefined method `refine' for #<Module:0x24e>
  fails "Module#remove_const calls #to_str to convert the given name to a String"
  fails "Module#remove_const raises a TypeError if conversion to a String by calling #to_str fails"
  fails "Module#remove_const returns nil when removing autoloaded constant"
  fails "Module#to_s always show the refinement name, even if the module is named" # NoMethodError: undefined method `refine' for ModuleSpecs::RefinementInspect
  fails "Module#to_s does not call #inspect or #to_s for singleton classes" # Expected "#<Class:#<:0x25bee>>" =~ /\A#<Class:#<#<Class:0x25bf2>:0x\h+>>\z/ to be truthy but was nil
  fails "Module#to_s for objects includes class name and object ID" # Expected "#<Class:#<ModuleSpecs::NamedClass:0xa424>>" =~ /^#<Class:#<ModuleSpecs::NamedClass:0x\h+>>$/ to be truthy but was nil
  fails "Module#to_s for the singleton class of an object of an anonymous class" # Expected "#<Class:#<:0xa450>>" == "#<Class:#<#<Class:0xa454>:0xa450>>" to be truthy but was false
  fails "Module#to_s works with an anonymous class" # Expected "#<Class:0xa482>" =~ /^#<Class:0x\h+>$/ to be truthy but was nil
  fails "Module#to_s works with an anonymous module" # Expected "#<Module:0xa4ae>" =~ /^#<Module:0x\h+>$/ to be truthy but was nil
  fails "Module#undef_method raises a NameError when passed a missing name for a class" # Expected NameError (/undefined method `not_exist' for class `#<Class:0xa514>'/) but got: NameError (method 'not_exist' not defined in )
  fails "Module#undef_method raises a NameError when passed a missing name for a metaclass" # Expected NameError (/undefined method `not_exist' for class `String'/) but got: NameError (method 'not_exist' not defined in )
  fails "Module#undef_method raises a NameError when passed a missing name for a module" # Expected NameError (/undefined method `not_exist' for module `#<Module:0xa502>'/) but got: NameError (method 'not_exist' not defined in )
  fails "Module#undef_method raises a NameError when passed a missing name for a singleton class" # Expected NameError (/undefined method `not_exist' for class `#<Class:#<:0xa51a>>'/) but got: NameError (method 'not_exist' not defined in )
  fails "Module#using accepts module as argument" # NoMethodError: undefined method `refine' for #<Module:0x2a040>
  fails "Module#using accepts module without refinements" # Expected to not get Exception but got NoMethodError (undefined method `using' for #<Module:0x2a02a>)
  fails "Module#using activates refinement even for existed objects" # NoMethodError: undefined method `refine' for #<Module:0x2a052>
  fails "Module#using activates updates when refinement reopens later" # NoMethodError: undefined method `refine' for #<Module:0x2a018>
  fails "Module#using does not accept class" # NoMethodError: undefined method `using' for #<Module:0x2a03c>
  fails "Module#using imports class refinements from module into the current class/module" # NoMethodError: undefined method `refine' for #<Module:0x2a02e>
  fails "Module#using raises TypeError if passed something other than module" # NoMethodError: undefined method `using' for #<Module:0x2a034>
  fails "Module#using raises error in method scope" # NoMethodError: undefined method `using' for #<Module:0x2a044>
  fails "Module#using returns self" # NoMethodError: undefined method `using' for #<Module:0x2a022>
  fails "Module#using scope of refinement is active for block called via instance_eval" # NoMethodError: undefined method `refine' for #<Module:0x102>
  fails "Module#using scope of refinement is active for block called via instance_exec" # NoMethodError: undefined method `refine' for #<Module:0xfe>
  fails "Module#using scope of refinement is active for class defined via Class.new {}" # NoMethodError: undefined method `refine' for #<Module:0x106>
  fails "Module#using scope of refinement is active for method defined in a scope wherever it's called" # NoMethodError: undefined method `refine' for #<Module:0x2a06a>
  fails "Module#using scope of refinement is active for module defined via Module.new {}" # NoMethodError: undefined method `refine' for #<Module:0x10a>
  fails "Module#using scope of refinement is active until the end of current class/module" # NoMethodError: undefined method `refine' for #<Module:0x2a07a>
  fails "Module#using scope of refinement is not active before the `using` call" # NoMethodError: undefined method `refine' for #<Module:0x2a05e>
  fails "Module#using scope of refinement is not active for code defined outside the current scope" # NoMethodError: undefined method `refine' for #<Module:0x2a072>
  fails "Module#using scope of refinement is not active when class/module reopens" # NoMethodError: undefined method `refine' for #<Module:0x2a056>
  fails "Module#using works in classes too" # NoMethodError: undefined method `refine' for #<Module:0x2a01c>
  fails "Module::Nesting returns the list of Modules nested at the point of call"
end
