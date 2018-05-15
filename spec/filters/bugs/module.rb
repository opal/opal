opal_filter "Module" do
  fails "Module#alias_method can call a method with super aliased twice"
  fails "Module#alias_method creates methods that are == to eachother" # Expected #<Method: #<Class:0x3ee54>#uno (defined in #<Class:0x3ee54> in ruby/core/module/fixtures/classes.rb:203)> to equal #<Method: #<Class:0x3ee54>#public_one (defined in ModuleSpecs::Aliasing in ruby/core/module/fixtures/classes.rb:203)>
  fails "Module#alias_method raises a TypeError when the given name can't be converted using to_str"
  fails "Module#alias_method retains method visibility"
  fails "Module#append_features on Class raises a TypeError if calling after rebinded to Class"
  fails "Module#attr applies current visibility to methods created"
  fails "Module#attr converts non string/symbol/fixnum names to strings using to_str"
  fails "Module#attr creates a getter but no setter for all given attribute names"
  fails "Module#attr creates a getter for the given attribute name"
  fails "Module#attr raises a TypeError when the given names can't be converted to strings using to_str"
  fails "Module#attr_accessor applies current visibility to methods created"
  fails "Module#attr_accessor converts non string/symbol/fixnum names to strings using to_str"
  fails "Module#attr_accessor not allows creating an attr_accessor on an immediate class"
  fails "Module#attr_accessor raises a TypeError when the given names can't be converted to strings using to_str"
  fails "Module#attr_reader applies current visibility to methods created"
  fails "Module#attr_reader converts non string/symbol/fixnum names to strings using to_str"
  fails "Module#attr_reader not allows for adding an attr_reader to an immediate"
  fails "Module#attr_reader raises a TypeError when the given names can't be converted to strings using to_str"
  fails "Module#attr_writer applies current visibility to methods created"
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
  fails "Module#class_eval converts a non-string filename to a string using to_str"
  fails "Module#class_eval converts non string eval-string to string using to_str"
  fails "Module#class_eval raises a TypeError when the given eval-string can't be converted to string using to_str"
  fails "Module#class_eval raises a TypeError when the given filename can't be converted to string using to_str"
  fails "Module#class_eval resolves constants in the caller scope ignoring send"
  fails "Module#class_eval resolves constants in the caller scope" # fails because of the difference between module_eval("Const") and module_eval { Const } (only the second one is supported by Opal)
  fails "Module#class_eval uses the optional filename and lineno parameters for error messages"
  fails "Module#const_defined? returns true for toplevel constant when the name begins with '::'"
  fails "Module#const_defined? returns true or false for the nested name"
  fails "Module#const_defined? returns true when passed a constant name with EUC-JP characters"
  fails "Module#const_defined? returns true when passed a scoped constant name for a constant in the inheritance hierarchy and the inherited flag is default"
  fails "Module#const_defined? returns true when passed a scoped constant name for a constant in the inheritance hierarchy and the inherited flag is true"
  fails "Module#const_defined? returns true when passed a scoped constant name"
  fails "Module#constants doesn't returns inherited constants when passed nil"
  fails "Module#constants returns only public constants"
  fails "Module#define_method raises a TypeError when a Method from a singleton class is defined on another class"
  fails "Module#define_method raises a TypeError when a Method from one class is defined on an unrelated class"
  fails "Module#define_method raises a TypeError when an UnboundMethod from a child class is defined on a parent class"
  fails "Module#define_method raises a TypeError when an UnboundMethod from one class is defined on an unrelated class"
  fails "Module#deprecate_constant accepts multiple symbols and strings as constant names"
  fails "Module#deprecate_constant raises a NameError when given an undefined name"
  fails "Module#deprecate_constant returns self"
  fails "Module#deprecate_constant when accessing the deprecated module passes the accessing"
  fails "Module#deprecate_constant when accessing the deprecated module warns with a message"
  fails "Module#extend_object extends the given object with its constants and methods by default"
  fails "Module#extend_object is called when #extend is called on an object"
  fails "Module#extend_object on Class raises a TypeError if calling after rebinded to Class"
  fails "Module#include doesn't accept no-arguments" # Expected ArgumentError but no exception was raised (#<Module:0x4fbac> was returned)
  fails "Module#include doesn't include module if it is included in a super class"
  fails "Module#initialize_copy should retain singleton methods when duped" # Expected [] to equal ["hello"]
  fails "Module#instance_method raises a NameError if the method has been undefined"
  fails "Module#instance_method raises a TypeError if not passed a symbol"
  fails "Module#instance_method raises a TypeError if the given name is not a string/symbol"
  fails "Module#method_defined? converts the given name to a string using to_str"
  fails "Module#method_defined? raises a TypeError when the given object is not a string/symbol/fixnum"
  fails "Module#method_defined? returns true if a public or private method with the given name is defined in self, self's ancestors or one of self's included modules"
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
  fails "Module#name is not nil for a nested module created with the module keyword"
  fails "Module#name is set with a conditional assignment to a constant"
  fails "Module#name is set with a conditional assignment to a nested constant"
  fails "Module#name preserves the encoding in which the class was defined"
  fails "Module#prepend keeps the module in the chain when dupping an intermediate module"
  fails "Module#prepend keeps the module in the chain when dupping the class"
  fails "Module#refine adds methods defined in its block to the anonymous module's public instance methods" # NoMethodError: undefined method `refine' for #<Module:0x3ae64>
  fails "Module#refine applies refinements to calls in the refine block" # NoMethodError: undefined method `refine' for #<Module:0x3ae7a>
  fails "Module#refine does not apply refinements to external scopes not using the module" # NoMethodError: undefined method `refine' for #<Module:0x3ae60>
  fails "Module#refine does not make available methods from another refinement module" # NoMethodError: undefined method `refine' for #<Module:0x3ae8c>
  fails "Module#refine does not override methods in subclasses" # NoMethodError: undefined method `refine' for #<Module:0x3ae56>
  fails "Module#refine doesn't apply refinements outside the refine block" # NoMethodError: undefined method `refine' for #<Module:0x3ae72>
  fails "Module#refine for methods accessed indirectly is honored by BasicObject#__send__" # NoMethodError: undefined method `refine' for #<Module:0x3aeb2>
  fails "Module#refine for methods accessed indirectly is honored by Kernel#binding" # NoMethodError: undefined method `refine' for #<Module:0x3aeaa>
  fails "Module#refine for methods accessed indirectly is honored by Kernel#send" # NoMethodError: undefined method `refine' for #<Module:0x3aeae>
  fails "Module#refine for methods accessed indirectly is honored by Symbol#to_proc" # NoMethodError: undefined method `refine' for #<Module:0x3aeba>
  fails "Module#refine for methods accessed indirectly is honored by string interpolation" # NoMethodError: undefined method `refine' for #<Module:0x3aeb6>
  fails "Module#refine for methods accessed indirectly is not honored by Kernel#method" # NoMethodError: undefined method `refine' for #<Module:0x3aec0>
  fails "Module#refine for methods accessed indirectly is not honored by Kernel#respond_to?" # NoMethodError: undefined method `refine' for #<Module:0x3aea6>
  fails "Module#refine makes available all refinements from the same module" # NoMethodError: undefined method `refine' for #<Module:0x3ae88>
  fails "Module#refine method lookup looks in included modules from the refinement then" # NoMethodError: undefined method `refine' for #<Module:0x3aea0>
  fails "Module#refine method lookup looks in prepended modules from the refinement first" # NoMethodError: undefined method `refine' for #<Module:0x3ae98>
  fails "Module#refine method lookup looks in refinement then" # NoMethodError: undefined method `refine' for #<Module:0x3ae94>
  fails "Module#refine method lookup looks in the class then" # NoMethodError: undefined method `refine' for #<Module:0x3ae90>
  fails "Module#refine method lookup looks in the object singleton class first" # NoMethodError: undefined method `refine' for #<Module:0x3ae9c>
  fails "Module#refine module inclusion activates all refinements from all ancestors" # NoMethodError: undefined method `refine' for #<Module:0x3aed4>
  fails "Module#refine module inclusion overrides methods of ancestors by methods in descendants" # NoMethodError: undefined method `refine' for #<Module:0x3aed0>
  fails "Module#refine raises ArgumentError if not given a block" # NoMethodError: undefined method `refine' for #<Module:0x3ae5c>
  fails "Module#refine raises ArgumentError if not passed an argument" # NoMethodError: undefined method `refine' for #<Module:0x3ae80>
  fails "Module#refine raises TypeError if not passed a class" # NoMethodError: undefined method `refine' for #<Module:0x3ae6e>
  fails "Module#refine returns created anonymous module" # NoMethodError: undefined method `refine' for #<Module:0x3ae68>
  fails "Module#refine runs its block in an anonymous module" # NoMethodError: undefined method `refine' for #<Module:0x3ae76>
  fails "Module#refine uses the same anonymous module for future refines of the same class" # NoMethodError: undefined method `refine' for #<Module:0x3ae84>
  fails "Module#refine when super is called in a refinement looks in the included to refinery module" # NoMethodError: undefined method `refine' for #<Module:0x3aec8>
  fails "Module#refine when super is called in a refinement looks in the refined class even if there is another active refinement" # NoMethodError: undefined method `refine' for #<Module:0x3aec4>
  fails "Module#refine when super is called in a refinement looks in the refined class" # NoMethodError: undefined method `refine' for #<Module:0x3aecc>
  fails "Module#remove_class_variable removes class variable" # Exception: Cannot set property '@@mvar' of undefined
  fails "Module#remove_class_variable returns the value of removing class variable" # Exception: Cannot set property '@@mvar' of undefined
  fails "Module#remove_const calls #to_str to convert the given name to a String"
  fails "Module#remove_const raises a TypeError if conversion to a String by calling #to_str fails"
  fails "Module#remove_const returns nil when removing autoloaded constant"
  fails "Module#using accepts module as argument" # NoMethodError: undefined method `refine' for #<Module:0x2a040>
  fails "Module#using accepts module without refinements" # Expected to not get Exception but got NoMethodError (undefined method `using' for #<Module:0x2a02a>)
  fails "Module#using activates refinement even for existed objects" # NoMethodError: undefined method `refine' for #<Module:0x2a052>
  fails "Module#using activates updates when refinement reopens later" # NoMethodError: undefined method `refine' for #<Module:0x2a018>
  fails "Module#using does not accept class" # NoMethodError: undefined method `using' for #<Module:0x2a03c>
  fails "Module#using imports class refinements from module into the current class/module" # NoMethodError: undefined method `refine' for #<Module:0x2a02e>
  fails "Module#using raises TypeError if passed something other than module" # NoMethodError: undefined method `using' for #<Module:0x2a034>
  fails "Module#using raises error in method scope" # NoMethodError: undefined method `using' for #<Module:0x2a044>
  fails "Module#using returns self" # NoMethodError: undefined method `using' for #<Module:0x2a022>
  fails "Module#using scope of refinement is active for method defined in a scope wherever it's called" # NoMethodError: undefined method `refine' for #<Module:0x2a06a>
  fails "Module#using scope of refinement is active until the end of current class/module" # NoMethodError: undefined method `refine' for #<Module:0x2a07a>
  fails "Module#using scope of refinement is not active before the `using` call" # NoMethodError: undefined method `refine' for #<Module:0x2a05e>
  fails "Module#using scope of refinement is not active for code defined outside the current scope" # NoMethodError: undefined method `refine' for #<Module:0x2a072>
  fails "Module#using scope of refinement is not active when class/module reopens" # NoMethodError: undefined method `refine' for #<Module:0x2a056>
  fails "Module#using works in classes too" # NoMethodError: undefined method `refine' for #<Module:0x2a01c>
  fails "Module.constants returns an array of Symbol names" # requires Bignum
  fails "Module.new creates a new Module and passes it to the provided block"
  fails "Module::Nesting returns the list of Modules nested at the point of call"
end
