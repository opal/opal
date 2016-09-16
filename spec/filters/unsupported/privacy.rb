opal_unsupported_filter "private" do
  fails "BasicObject#initialize is a private instance method"
  fails "BasicObject#method_missing for a Class raises a NoMethodError when an undefined method is called"
  fails "BasicObject#method_missing is a private method"
  fails "BasicObject#singleton_method_added is a private method"
  fails "BasicObject#singleton_method_removed is a private method"
  fails "BasicObject#singleton_method_undefined is a private method"
  fails "Module#alias_method aliasing special methods keeps initialize private when aliasing"
  fails "Module#alias_method aliasing special methods keeps initialize_clone private when aliasing"
  fails "Module#alias_method aliasing special methods keeps initialize_copy private when aliasing"
  fails "Module#alias_method aliasing special methods keeps initialize_dup private when aliasing"
  fails "Module#alias_method aliasing special methods keeps respond_to_missing? private when aliasing"
  fails "Module#alias_method is a private method"
  fails "Module#append_features is a private method"
  fails "Module#attr is a private method"
  fails "Module#attr_accessor is a private method"
  fails "Module#attr_reader is a private method"
  fails "Module#attr_writer is a private method"
  fails "Module#define_method when name is not a special private name given an UnboundMethod sets the visibility of the method to the current visibility"
  fails "Module#define_method when name is not a special private name given an UnboundMethod and called from the target module sets the visibility of the method to the current visibility"
  fails "Module#define_method when name is not a special private name passed a block and called from the target module sets the visibility of the method to the current visibility"
  fails "Module#extend_object is a private method"
  fails "Module#extend_object is called even when private"
  fails "Module#extended is private in its default implementation"
  fails "Module#included is private in its default implementation"
  fails "Module#method_added is a private instance method"
  fails "Module#method_removed is a private instance method"
  fails "Module#method_undefined is a private instance method"
  fails "Module#module_function is a private method"
  fails "Module#module_function with specific method names can make accessible private methods"
  fails "Module#module_function with specific method names makes the instance methods private"
  fails "Module#prepend_features is a private method"
  fails "Module#prepended is a private method"
  fails "Module#private is a private method"
  fails "Module#private makes a public Object instance method private in Kernel"
  fails "Module#private makes a public Object instance method private in a new module"
  fails "Module#private makes the target method uncallable from other types"
  fails "Module#private raises a NameError when given an undefined name"
  fails "Module#private returns self"
  fails "Module#private without arguments affects evaled method definitions when itself is outside the eval"
  fails "Module#private without arguments affects normally if itself and following method definitions are inside a eval"
  fails "Module#private without arguments affects normally if itself and method definitions are inside a module_eval"
  fails "Module#private without arguments continues setting visibility if the body encounters other visibility setters with arguments"
  fails "Module#private without arguments does not affect method definitions when itself is inside an eval and method definitions are outside"
  fails "Module#private without arguments does not affect module_evaled method definitions when itself is outside the eval"
  fails "Module#private without arguments sets visibility to following method definitions"
  fails "Module#private without arguments stops setting visibility if the body encounters other visibility setters without arguments"
  fails "Module#private_class_method accepts more than one method at a time"
  fails "Module#private_class_method makes a class method private"
  fails "Module#private_class_method makes an existing class method private up the inheritance tree"
  fails "Module#private_class_method makes an existing class method private"
  fails "Module#private_class_method raises a NameError if class method doesn't exist"
  fails "Module#private_class_method raises a NameError when the given name is an instance method"
  fails "Module#private_class_method raises a NameError when the given name is not a method"
  fails "Module#private_constant accepts multiple names"
  fails "Module#private_constant accepts strings as constant names"
  fails "Module#private_constant can only be passed constant names defined in the target (self) module"
  fails "Module#private_constant marked constants remain private even when updated"
  fails "Module#private_constant marked constants in a module cannot be accessed from outside the module"
  fails "Module#private_constant marked constants in a module cannot be reopened as a class"
  fails "Module#private_constant marked constants in a module is not defined? with A::B form"
  fails "Module#private_constant marked constants in a module can be accessed from the module itself"
  fails "Module#private_constant marked constants in a module can be accessed from lexical scope"
  fails "Module#private_constant marked constants in a module is defined? from lexical scope"
  fails "Module#private_constant marked constants in a class cannot be accessed from outside the class"
  fails "Module#private_constant marked constants in a class cannot be reopened as a class"
  fails "Module#private_constant marked constants in a class is not defined? with A::B form"
  fails "Module#private_constant marked constants in a class can be accessed from the class itself"
  fails "Module#private_constant marked constants in a class can be accessed from lexical scope"
  fails "Module#private_constant marked constants in a class is defined? from lexical scope"
  fails "Module#private_constant marked constants in Object cannot be accessed using ::Const form"
  fails "Module#private_constant marked constants in Object is not defined? using ::Const form"
  fails "Module#public_constant marked constants in a module can be accessed from outside the module"
  fails "Module#public_constant marked constants in a class can be accessed from outside the class"
  fails "Module#private_constant marked constants in a module cannot be reopened as a module"
  fails "Module#private_constant marked constants in a class cannot be reopened as a module"
  fails "Module#private_instance_methods returns a list of private methods in module and its ancestors"
  fails "Module#private_instance_methods when not passed an argument returns a unique list for a class including a module"
  fails "Module#private_instance_methods when not passed an argument returns a unique list for a subclass"
  fails "Module#private_instance_methods when passed false as a parameter, should return only methods defined in that module"
  fails "Module#private_instance_methods when passed true returns a unique list for a class including a module"
  fails "Module#private_instance_methods when passed true returns a unique list for a subclass"
  fails "Module#private_method_defined? accepts symbols for the method name"
  fails "Module#private_method_defined? calls #to_str to convert an Object"
  fails "Module#private_method_defined? raises a TypeError if passed a Fixnum"
  fails "Module#private_method_defined? raises a TypeError if passed an object that defines #to_sym"
  fails "Module#private_method_defined? raises a TypeError if passed an object that does not defined #to_str"
  fails "Module#private_method_defined? raises a TypeError if passed false"
  fails "Module#private_method_defined? raises a TypeError if passed nil"
  fails "Module#private_method_defined? returns true if the named private method is defined by module or its ancestors"
  fails "Module#protected is a private method"
  fails "Module#protected makes a public Object instance method protected in Kernel"
  fails "Module#protected makes a public Object instance method protected in a new module"
  fails "Module#protected makes an existing class method protected"
  fails "Module#protected raises a NameError when given an undefined name"
  fails "Module#protected returns self"
  fails "Module#protected without arguments affects evaled method definitions when itself is outside the eval"
  fails "Module#protected without arguments affects normally if itself and following method definitions are inside a eval"
  fails "Module#protected without arguments affects normally if itself and method definitions are inside a module_eval"
  fails "Module#protected without arguments continues setting visibility if the body encounters other visibility setters with arguments"
  fails "Module#protected without arguments does not affect method definitions when itself is inside an eval and method definitions are outside"
  fails "Module#protected without arguments does not affect module_evaled method definitions when itself is outside the eval"
  fails "Module#protected without arguments sets visibility to following method definitions"
  fails "Module#protected without arguments stops setting visibility if the body encounters other visibility setters without arguments"
  fails "Module#protected_instance_methods default list should be the same as passing true as an argument"
  fails "Module#protected_instance_methods returns a list of protected methods in module and its ancestors"
  fails "Module#protected_instance_methods when not passed an argument returns a unique list for a class including a module"
  fails "Module#protected_instance_methods when not passed an argument returns a unique list for a subclass"
  fails "Module#protected_instance_methods when passed false as a parameter, should return only methods defined in that module"
  fails "Module#protected_instance_methods when passed true returns a unique list for a class including a module"
  fails "Module#protected_instance_methods when passed true returns a unique list for a subclass"
  fails "Module#protected_method_defined? accepts symbols for the method name"
  fails "Module#protected_method_defined? calls #to_str to convert an Object"
  fails "Module#protected_method_defined? raises a TypeError if passed a Fixnum"
  fails "Module#protected_method_defined? raises a TypeError if passed an object that defines #to_sym"
  fails "Module#protected_method_defined? raises a TypeError if passed an object that does not defined #to_str"
  fails "Module#protected_method_defined? raises a TypeError if passed false"
  fails "Module#protected_method_defined? raises a TypeError if passed nil"
  fails "Module#protected_method_defined? returns true if the named protected method is defined by module or its ancestors"
  fails "Module#public is a private method"
  fails "Module#public makes a private Object instance method public in Kernel"
  fails "Module#public makes a private Object instance method public in a new module"
  fails "Module#public raises a NameError when given an undefined name"
  fails "Module#public returns self"
  fails "Module#public without arguments affects evaled method definitions when itself is outside the eval"
  fails "Module#public without arguments affects normally if itself and following method definitions are inside a eval"
  fails "Module#public without arguments does not affect method definitions when itself is inside an eval and method definitions are outside"
  fails "Module#public without arguments does not affect module_evaled method definitions when itself is outside the eval"
  fails "Module#public without arguments stops setting visibility if the body encounters other visibility setters without arguments"
  fails "Module#public_class_method accepts more than one method at a time"
  fails "Module#public_class_method makes an existing class method public up the inheritance tree"
  fails "Module#public_class_method makes an existing class method public"
  fails "Module#public_class_method raises a NameError if class method doesn't exist"
  fails "Module#public_class_method raises a NameError when the given name is an instance method"
  fails "Module#public_class_method raises a NameError when the given name is not a method"
  fails "Module#public_constant accepts multiple names"
  fails "Module#public_constant accepts strings as constant names"
  fails "Module#public_constant can only be passed constant names defined in the target (self) module"
  fails "Module#public_instance_method is a public method"
  fails "Module#public_instance_method raises a TypeError when given a name is not Symbol or String"
  fails "Module#public_instance_method requires an argument"
  fails "Module#public_instance_method sets the NameError#name attribute to the name of the missing method"
  fails "Module#public_instance_method when given a public method name accepts if the name is a Symbol or String"
  fails "Module#public_instance_method when given a public method name returns an UnboundMethod corresponding to the defined Module"
  fails "Module#public_instance_methods when passed false as a parameter, should return only methods defined in that module"
  fails "Module#public_method_defined? calls #to_str to convert an Object"
  fails "Module#public_method_defined? raises a TypeError if passed a Fixnum"
  fails "Module#public_method_defined? raises a TypeError if passed an object that defines #to_sym"
  fails "Module#public_method_defined? raises a TypeError if passed an object that does not defined #to_str"
  fails "Module#public_method_defined? raises a TypeError if passed false"
  fails "Module#public_method_defined? raises a TypeError if passed nil"
  fails "Module#public_method_defined? returns false if method is not a public method"
  fails "Module#remove_const is a private method"
  fails "Module#remove_method is a private method"
  fails "Module#undef_method is a private method"
  fails "OpenStruct#initialize is private"
  fails "OpenStruct#new_ostruct_member is protected"
  fails "OpenStruct#table is protected"
  fails "Defining a method at the top-level defines it on Object with private visibility by default"
  fails "Defining an 'initialize' method sets the method's visibility to private"
  fails "Defining an 'initialize_copy' method sets the method's visibility to private"
  fails "Defining an 'initialize_dup' method sets the method's visibility to private"
  fails "Defining an 'initialize_clone' method sets the method's visibility to private"
  fails "Defining a 'respond_to_missing?' method sets the method's visibility to private"
  fails "Redefining a singleton method does not inherit a previously set visibility"
  fails "Redefining a singleton method does not inherit a previously set visibility"
  fails "Enumerator#initialize is a private method"
  fails "NoMethodError#message for private method match /private method/"
  fails "Kernel#block_given? is a private method"
  fails "Kernel#eval is a private method"
  fails "Kernel#iterator? is a private method"
  fails "Kernel#local_variables is a private method"
  fails "Kernel#methods returns private singleton methods defined by obj.meth"
  fails "Kernel#methods returns singleton methods defined in 'class << self' when it follows 'private'"
  fails "Kernel#p is a private method"
  fails "Kernel#print is a private method"
  fails "Kernel#printf is a private method"
  fails "Kernel#public_send raises a NoMethodError if the named method is an alias of a private method"
  fails "Kernel#public_send raises a NoMethodError if the named method is an alias of a protected method"
  fails "Kernel#public_send raises a NoMethodError if the named method is private"
  fails "Kernel#puts is a private method"
  fails "Kernel#respond_to? does not change method visibility when finding private method"
  fails "Kernel#respond_to? returns false even if obj responds to the given private method (include_private = false)"
  fails "Kernel#respond_to? returns false if obj responds to the given private method"
  fails "Kernel#respond_to_missing? is a private method"
  fails "Kernel#respond_to_missing? is called when obj responds to the given private method, include_private = false"
  fails "Kernel#respond_to_missing? is called when obj responds to the given protected method, include_private = false"
  fails "Kernel#respond_to_missing? isn't called when obj responds to the given private method, include_private = true"
  fails "Kernel#respond_to_missing? isn't called when obj responds to the given protected method, include_private = true"
  fails "Kernel#respond_to_missing? isn't called when obj responds to the given public method, include_private = true"
  fails "Kernel.global_variables is a private method"
  fails "Kernel.lambda is a private method"
  fails "Kernel.loop is a private method"
  fails "Kernel.proc is a private method"
  fails "Kernel.rand is a private method"
  fails "Kernel.srand is a private method"
  fails "Kernel#private_methods returns a list of the names of privately accessible methods in the object and its ancestors and mixed-in modules"
  fails "Kernel#private_methods returns a list of the names of privately accessible methods in the object"
  fails "Kernel#private_methods returns private methods mixed in to the metaclass"
  fails "Kernel#private_methods when not passed an argument returns a unique list for a class including a module"
  fails "Kernel#private_methods when not passed an argument returns a unique list for a subclass of a class that includes a module"
  fails "Kernel#private_methods when not passed an argument returns a unique list for an object extended by a module"
  fails "Kernel#private_methods when passed false returns a list of private methods in without its ancestors"
  fails "Kernel#private_methods when passed nil returns a list of private methods in without its ancestors"
  fails "Kernel#private_methods when passed true returns a unique list for a class including a module"
  fails "Kernel#private_methods when passed true returns a unique list for a subclass of a class that includes a module"
  fails "Kernel#private_methods when passed true returns a unique list for an object extended by a module"
  fails "Kernel#respond_to? returns false if obj responds to the given protected method (include_private = false)"
  fails "Kernel#singleton_methods when not passed an argument does not return private class methods for a class"
  fails "Kernel#singleton_methods when not passed an argument does not return private inherited singleton methods for a class including a module"
  fails "Kernel#singleton_methods when not passed an argument does not return private inherited singleton methods for a module including a module"
  fails "Kernel#singleton_methods when not passed an argument does not return private inherited singleton methods for a subclass including a module"
  fails "Kernel#singleton_methods when not passed an argument does not return private inherited singleton methods for a subclass of a class including a module"
  fails "Kernel#singleton_methods when not passed an argument does not return private inherited singleton methods for a subclass of a class that includes a module, where the subclass also includes a module"
  fails "Kernel#singleton_methods when not passed an argument does not return private inherited singleton methods for a subclass"
  fails "Kernel#singleton_methods when not passed an argument does not return private module methods for a module"
  fails "Kernel#singleton_methods when not passed an argument does not return private singleton methods for a class extended with a module"
  fails "Kernel#singleton_methods when not passed an argument does not return private singleton methods for an object extended with a module"
  fails "Kernel#singleton_methods when not passed an argument does not return private singleton methods for an object extended with two modules"
  fails "Kernel#singleton_methods when not passed an argument does not return private singleton methods for an object extented with a module including a module"
  fails "Kernel#singleton_methods when passed false does not return private class methods for a class"
  fails "Kernel#singleton_methods when passed false does not return private inherited singleton methods for a class including a module"
  fails "Kernel#singleton_methods when passed false does not return private inherited singleton methods for a module including a module"
  fails "Kernel#singleton_methods when passed false does not return private inherited singleton methods for a subclass including a module"
  fails "Kernel#singleton_methods when passed false does not return private inherited singleton methods for a subclass of a class including a module"
  fails "Kernel#singleton_methods when passed false does not return private inherited singleton methods for a subclass of a class that includes a module, where the subclass also includes a module"
  fails "Kernel#singleton_methods when passed false does not return private inherited singleton methods for a subclass"
  fails "Kernel#singleton_methods when passed false does not return private module methods for a module"
  fails "Kernel#singleton_methods when passed false does not return private singleton methods for a class extended with a module"
  fails "Kernel#singleton_methods when passed false does not return private singleton methods for an object extended with a module"
  fails "Kernel#singleton_methods when passed false does not return private singleton methods for an object extended with two modules"
  fails "Kernel#singleton_methods when passed false does not return private singleton methods for an object extented with a module including a module"
  fails "Kernel#singleton_methods when passed true does not return private class methods for a class"
  fails "Kernel#singleton_methods when passed true does not return private inherited singleton methods for a class including a module"
  fails "Kernel#singleton_methods when passed true does not return private inherited singleton methods for a module including a module"
  fails "Kernel#singleton_methods when passed true does not return private inherited singleton methods for a subclass including a module"
  fails "Kernel#singleton_methods when passed true does not return private inherited singleton methods for a subclass of a class including a module"
  fails "Kernel#singleton_methods when passed true does not return private inherited singleton methods for a subclass of a class that includes a module, where the subclass also includes a module"
  fails "Kernel#singleton_methods when passed true does not return private inherited singleton methods for a subclass"
  fails "Kernel#singleton_methods when passed true does not return private module methods for a module"
  fails "Kernel#singleton_methods when passed true does not return private singleton methods for a class extended with a module"
  fails "Kernel#singleton_methods when passed true does not return private singleton methods for an object extended with a module"
  fails "Kernel#singleton_methods when passed true does not return private singleton methods for an object extended with two modules"
  fails "Kernel#singleton_methods when passed true does not return private singleton methods for an object extented with a module including a module"
  fails "Invoking a private getter method does not permit self as a receiver"
  fails "Method#== missing methods calls respond_to_missing? with true to include private methods"
  fails "Method#eql? missing methods calls respond_to_missing? with true to include private methods"
  fails "Module#private without arguments within a closure sets the visibility outside the closure"
  fails "Rational#marshal_dump is a private method"
  fails "Regexp#initialize is a private method"
  fails "StringScanner#initialize is a private method"
  fails "NoMethodError#message for an protected method match /protected method/"
  fails "Kernel#protected_methods returns a list of the names of protected methods accessible in the object and from its ancestors and mixed-in modules"
  fails "Kernel#protected_methods returns a list of the names of protected methods accessible in the object"
  fails "Kernel#protected_methods returns methods mixed in to the metaclass"
  fails "Kernel#protected_methods when not passed an argument returns a unique list for a class including a module"
  fails "Kernel#protected_methods when not passed an argument returns a unique list for a subclass of a class that includes a module"
  fails "Kernel#protected_methods when not passed an argument returns a unique list for an object extended by a module"
  fails "Kernel#protected_methods when passed false returns a list of protected methods in without its ancestors"
  fails "Kernel#protected_methods when passed nil returns a list of protected methods in without its ancestors"
  fails "Kernel#protected_methods when passed true returns a unique list for a class including a module"
  fails "Kernel#protected_methods when passed true returns a unique list for a subclass of a class that includes a module"
  fails "Kernel#protected_methods when passed true returns a unique list for an object extended by a module"
  fails "Kernel#public_send raises a NoMethodError if the method is protected"
  fails "Kernel#respond_to? returns false if obj responds to the given protected method"
  fails "Module#protected without arguments within a closure sets the visibility outside the closure"
  fails "Set#flatten_merge is protected"
  fails "Kernel#public_send called from own public method raises a NoMethodError if the method is private"
  fails "Kernel#public_send called from own public method raises a NoMethodError if the method is protected"
end
