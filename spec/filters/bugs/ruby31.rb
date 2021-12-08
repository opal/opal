# NOTE: run bin/format-filters after changing this file
opal_filter "Ruby 3.1" do
  fails "$LOAD_PATH.resolve_feature_path return nil if feature cannot be found" # NoMethodError: undefined method `resolve_feature_path' for ["foo"]
  fails "Enumerable#tally with a hash raises a FrozenError and does not update the given hash when the hash is frozen" # Expected FrozenError but got: ArgumentError ([Numerous#tally] wrong number of arguments(1 for 0))
  fails "File.dirname returns all the components of filename except the last parts by the level" # ArgumentError: [File.dirname] wrong number of arguments(2 for 1)
  fails "File.dirname returns the same string if the level is 0" # ArgumentError: [File.dirname] wrong number of arguments(2 for 1)
  fails "Hash literal checks duplicated float keys on initialization" # Expected warning to match: /key 1.0 is duplicated|duplicated key/ but got: ""
  fails "Pattern matching warning when one-line form does not warn about pattern matching is experimental feature" # NameError: uninitialized constant Warning
  fails "Range#step with exclusive end and Float values correctly handles values near the upper limit" # Expected 3 == 4 to be truthy but was false
  fails "String#lstrip! strips leading \\0" # NotImplementedError: String#lstrip! not supported. Mutable String methods are not supported in Opal.
  fails "String#split with String when $; is not nil warns" # Expected warning to match: /warning: \$; is set to non-nil value/ but got: ""
  fails "String#strip! removes leading and trailing NULL bytes and whitespace" # NotImplementedError: String#strip! not supported. Mutable String methods are not supported in Opal.
  fails "String#unpack1 starts unpacking from the given offset" # RuntimeError: Unsupported unpack directive "x" (no chunk reader defined)
  fails "The ** operator hash with omitted value accepts mixed syntax" # NameError: uninitialized constant MSpecEnv::a
  fails "The ** operator hash with omitted value accepts short notation 'key' for 'key: value' syntax" # NameError: uninitialized constant MSpecEnv::a
  fails "The ** operator hash with omitted value ignores hanging comma on short notation" # NameError: uninitialized constant MSpecEnv::a
  fails "The ** operator hash with omitted value works with methods and local vars" # NameError: uninitialized constant #<Class:0x874c0>::bar
  fails "kwarg with omitted value in a method call accepts short notation 'kwarg' in method call for definition 'def call(*args, **kwargs) = [args, kwargs]'" # NameError: uninitialized constant SpecEvaluate::a
  fails "kwarg with omitted value in a method call with methods and local variables for definition \n    def call(*args, **kwargs) = [args, kwargs]\n    def bar\n      \"baz\"\n    end\n    def foo(val)\n      call bar:, val:\n    end" # NameError: uninitialized constant SpecEvaluate::bar
  fails "main#private returns argument" # Expected nil to be identical to "main_public_method"
  fails "main#public returns argument" # Expected nil to be identical to "main_private_method"
  fails_badly "Class#descendants returns a list of classes descended from self (excluding self)" # GC/Spec order issue. Expected [#<Class:0x2e77c>,  #<Class:0x2e79a>,  #<Class:0x37368>,  ModuleSpecs::Child,  ModuleSpecs::Child2,  ModuleSpecs::Grandchild] == [ModuleSpecs::Child, ModuleSpecs::Child2, ModuleSpecs::Grandchild] to be truthy but was false
  fails_badly "Class#subclasses returns a list of classes directly inheriting from self" # GC/Spec order issue. Expected [#<Class:0x2e77c>,  #<Class:0x2e79a>,  #<Class:0x37368>,  ModuleSpecs::Child,  ModuleSpecs::Child2] == [ModuleSpecs::Child, ModuleSpecs::Child2] to be truthy but was false
end
