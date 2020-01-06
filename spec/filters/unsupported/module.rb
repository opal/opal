# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Module" do
  fails "Module#alias_method raises FrozenError if frozen" # Expected FrozenError but no exception was raised (#<Class:0x2caa> was returned)
  fails "Module#append_features when other is frozen raises a FrozenError before appending self" # Expected FrozenError but no exception was raised (#<Module:0x223a> was returned)
  fails "Module#autoload (concurrently) blocks a second thread while a first is doing the autoload" # no thread support
  fails "Module#autoload (concurrently) blocks others threads while doing an autoload" # no thread support
  fails "Module#autoload calls main.require(path) to load the file" # NameError: uninitialized constant TOPLEVEL_BINDING
  fails "Module#autoload during the autoload before the constant is assigned keeps the constant in Module#constants" # checked, requires thread support
  fails "Module#autoload during the autoload before the constant is assigned returns false in autoload thread and true otherwise for Module#const_defined?" # checked, requires thread support
  fails "Module#autoload during the autoload before the constant is assigned returns nil in autoload thread and 'constant' otherwise for defined?" # checked, requires thread support
  fails "Module#autoload during the autoload before the constant is assigned returns nil in autoload thread and returns the path in other threads for Module#autoload?" # checked, requires thread support
  fails "Module#class_eval converts a non-string filename to a string using to_str" # Mock 'ruby/core/module/shared/class_eval.rb' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "Module#class_eval converts non string eval-string to string using to_str" # Mock '1 + 1' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "Module#class_eval raises a TypeError when the given eval-string can't be converted to string using to_str" # NoMethodError: undefined method `encoding' for #<MockObject:0x1116>
  fails "Module#class_eval raises a TypeError when the given filename can't be converted to string using to_str" # Expected TypeError but no exception was raised (2 was returned)
  fails "Module#class_eval resolves constants in the caller scope ignoring send" # NameError: uninitialized constant ModuleSpecs::ClassEvalTest::Lookup
  fails "Module#class_eval resolves constants in the caller scope" # NameError: uninitialized constant ModuleSpecs::ClassEvalTest::Lookup
  fails "Module#class_eval uses the optional filename and lineno parameters for error messages" # Expected ["test", 1] to equal ["test", 102]
  fails "Module#class_variable_set raises a FrozenError when self is frozen" # Expected FrozenError but no exception was raised ("test" was returned)
  fails "Module#const_set on a frozen module raises a FrozenError before setting the name" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Module#define_method raises a FrozenError if frozen" # Expected FrozenError but no exception was raised (#<Class:0x23ec> was returned)
  fails "Module#module_eval converts a non-string filename to a string using to_str" # Mock 'ruby/core/module/shared/class_eval.rb' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "Module#module_eval converts non string eval-string to string using to_str" # Mock '1 + 1' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "Module#module_eval raises a TypeError when the given eval-string can't be converted to string using to_str" # NoMethodError: undefined method `encoding' for #<MockObject:0x3e22>
  fails "Module#module_eval raises a TypeError when the given filename can't be converted to string using to_str" # Expected TypeError but no exception was raised (2 was returned)
  fails "Module#module_eval resolves constants in the caller scope ignoring send" # NameError: uninitialized constant ModuleSpecs::ClassEvalTest::Lookup
  fails "Module#module_eval resolves constants in the caller scope" # NameError: uninitialized constant ModuleSpecs::ClassEvalTest::Lookup
  fails "Module#module_eval uses the optional filename and lineno parameters for error messages" # Expected ["test", 1] to equal ["test", 102]
  fails "Module#private is a private method" # Expected Module to have private instance method 'private' but it does not
  fails "Module#private without arguments affects evaled method definitions when itself is outside the eval" # Expected #<Module:0x2a26> to have private instance method 'test1' but it does not
  fails "Module#private without arguments affects normally if itself and following method definitions are inside a eval" # Expected #<Module:0x27fa> to have private instance method 'test1' but it does not
  fails "Module#private without arguments affects normally if itself and method definitions are inside a module_eval" # Expected #<Module:0x28da> to have private instance method 'test1' but it does not
  fails "Module#private without arguments continues setting visibility if the body encounters other visibility setters with arguments" # Expected #<Module:0x2a2c> to have private instance method 'test2' but it does not
  fails "Module#private without arguments sets visibility to following method definitions" # Expected #<Module:0x2b84> to have private instance method 'test1' but it does not
  fails "Module#private without arguments stops setting visibility if the body encounters other visibility setters without arguments" # NoMethodError: undefined method `protected_instance_methods' for #<Module:0x2a34>
  fails "Module#private without arguments within a closure sets the visibility outside the closure" # Expected #<Module:0x2b8a> to have private instance method 'test1' but it does not
  fails "Module#private_instance_methods when not passed an argument returns a unique list for a class including a module" # Expected [] to equal ["pri"]
  fails "Module#private_instance_methods when not passed an argument returns a unique list for a subclass" # Expected [] to equal ["pri"]
  fails "Module#private_instance_methods when passed true returns a unique list for a class including a module" # Expected [] to equal ["pri"]
  fails "Module#private_instance_methods when passed true returns a unique list for a subclass" # Expected [] to equal ["pri"]
  fails "Module#protected is a private method" # Expected Module to have private instance method 'protected' but it does not
  fails "Module#protected without arguments affects evaled method definitions when itself is outside the eval" # NoMethodError: undefined method `protected_instance_methods' for #<Module:0xb2a>
  fails "Module#protected without arguments affects normally if itself and following method definitions are inside a eval" # NoMethodError: undefined method `protected_instance_methods' for #<Module:0x7a0>
  fails "Module#protected without arguments affects normally if itself and method definitions are inside a module_eval" # NoMethodError: undefined method `protected_instance_methods' for #<Module:0x7a8>
  fails "Module#protected without arguments continues setting visibility if the body encounters other visibility setters with arguments" # NoMethodError: undefined method `protected_instance_methods' for #<Module:0x7ae>
  fails "Module#protected without arguments sets visibility to following method definitions" # NoMethodError: undefined method `protected_instance_methods' for #<Module:0x904>
  fails "Module#protected without arguments stops setting visibility if the body encounters other visibility setters without arguments" # Expected #<Module:0x7b4> to have private instance method 'test1' but it does not
  fails "Module#protected without arguments within a closure sets the visibility outside the closure" # NoMethodError: undefined method `protected_instance_methods' for #<Module:0xb30>
  fails "Module#protected_instance_methods when not passed an argument returns a unique list for a class including a module" # NoMethodError: undefined method `protected_instance_methods' for ReflectSpecs::D
  fails "Module#protected_instance_methods when not passed an argument returns a unique list for a subclass" # NoMethodError: undefined method `protected_instance_methods' for ReflectSpecs::E
  fails "Module#protected_instance_methods when passed true returns a unique list for a class including a module" # NoMethodError: undefined method `protected_instance_methods' for ReflectSpecs::D
  fails "Module#protected_instance_methods when passed true returns a unique list for a subclass" # NoMethodError: undefined method `protected_instance_methods' for ReflectSpecs::E
  fails "Module#public is a private method" # Expected Module to have private instance method 'public' but it does not
  fails "Module#public without arguments does not affect method definitions when itself is inside an eval and method definitions are outside" # NoMethodError: undefined method `protected_instance_methods' for #<Module:0x36d4>
  fails "Module#public without arguments stops setting visibility if the body encounters other visibility setters without arguments" # NoMethodError: undefined method `protected_instance_methods' for #<Module:0x36da>
  fails "Module#remove_method on frozen instance raises a FrozenError when passed a missing name" # NameError: method 'not_exist' not defined in
  fails "Module#remove_method on frozen instance raises a FrozenError when passed a name" # NameError: method 'method_to_remove' not defined in
  fails "Module#undef_method on frozen instance raises a FrozenError when passed a missing name" # NameError: method 'not_exist' not defined in
  fails "Module#undef_method on frozen instance raises a FrozenError when passed a name" # NameError: method 'method_to_undef' not defined in
end
