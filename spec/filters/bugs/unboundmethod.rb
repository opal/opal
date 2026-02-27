# NOTE: run bin/format-filters after changing this file
opal_filter "UnboundMethod" do
  fails "UnboundMethod#== considers methods through aliasing and visibility change equal" # Expected #<Method: Class#new (defined in Class in <internal:corelib/class.rb>:40)> == #<Method: Class#n (defined in #<Class:> in <internal:corelib/class.rb>:40)> to be truthy but was false
  fails "UnboundMethod#== considers methods through aliasing equal" # Expected #<Method: Class#new (defined in Class in <internal:corelib/class.rb>:40)> == #<Method: Class#n (defined in #<Class:> in <internal:corelib/class.rb>:40)> to be truthy but was false
  fails "UnboundMethod#== considers methods through visibility change equal" # Expected #<Method: Class#new (defined in Class in <internal:corelib/class.rb>:40)> == #<Method: Class#new (defined in Class in <internal:corelib/class.rb>:40)> to be truthy but was false
  fails "UnboundMethod#== returns false if same method but extracted from two different subclasses" # Expected false == true to be truthy but was false
  fails "UnboundMethod#== returns true if both are aliases for a third method" # Expected false == true to be truthy but was false
  fails "UnboundMethod#== returns true if either is an alias for the other" # Expected false == true to be truthy but was false
  fails "UnboundMethod#== returns true if methods are the same but added from an included Module" # Expected false == true to be truthy but was false
  fails "UnboundMethod#== returns true if objects refer to the same method" # Expected false == true to be truthy but was false
  fails "UnboundMethod#== returns true if same method but one extracted from a subclass" # Expected false == true to be truthy but was false
  fails "UnboundMethod#== returns true if same method is extracted from the same subclass" # Expected false == true to be truthy but was false
  fails "UnboundMethod#bind the returned Method is equal to the one directly returned by obj.method" # Expected #<Method: UnboundMethodSpecs::Methods#foo (defined in UnboundMethodSpecs::Methods in ruby/core/unboundmethod/fixtures/classes.rb:30)> == #<Method: UnboundMethodSpecs::Methods#foo (defined in UnboundMethodSpecs::Methods in ruby/core/unboundmethod/fixtures/classes.rb:30)> to be truthy but was false
  fails "UnboundMethod#clone returns a copy of the UnboundMethod" # Expected false == true to be truthy but was false
  fails "UnboundMethod#hash equals a hash of the same method in the superclass" # Expected 13816 == 13814 to be truthy but was false
  fails "UnboundMethod#hash returns the same value for builtin methods that are eql?" # Expected 13858 == 13860 to be truthy but was false
  fails "UnboundMethod#hash returns the same value for user methods that are eql?" # Expected 13902 == 13904 to be truthy but was false
  fails "UnboundMethod#inspect returns a String including all details" # Expected "#<UnboundMethod: UnboundMethodSpecs::Methods#from_mod (defined in UnboundMethodSpecs::Mod in ruby/core/unboundmethod/fixtures/classes.rb:24)>".start_with? "#<UnboundMethod: UnboundMethodSpecs::Methods(UnboundMethodSpecs::Mod)#from_mod" to be truthy but was false
  fails "UnboundMethod#original_name returns the name of the method" # NoMethodError: undefined method `original_name' for #<UnboundMethod: String#upcase (defined in String in <internal:corelib/string.rb>:1685)>
  fails "UnboundMethod#original_name returns the original name even when aliased twice" # NoMethodError: undefined method `original_name' for #<UnboundMethod: UnboundMethodSpecs::Methods#foo (defined in UnboundMethodSpecs::Methods in ruby/core/unboundmethod/fixtures/classes.rb:30)>
  fails "UnboundMethod#original_name returns the original name" # NoMethodError: undefined method `original_name' for #<UnboundMethod: UnboundMethodSpecs::Methods#foo (defined in UnboundMethodSpecs::Methods in ruby/core/unboundmethod/fixtures/classes.rb:30)>
  fails "UnboundMethod#source_location sets the first value to the path of the file in which the method was defined" # Expected "ruby/core/unboundmethod/fixtures/classes.rb" == "./ruby/core/unboundmethod/fixtures/classes.rb" to be truthy but was false
  fails "UnboundMethod#source_location works for eval with a given line" # Expected ["(eval)", 0] == ["foo", 100] to be truthy but was false
  fails "UnboundMethod#super_method after aliasing an inherited method returns the expected super_method" # NoMethodError: undefined method `super_method' for #<UnboundMethod: MethodSpecs::InheritedMethods::C#meow (defined in MethodSpecs::InheritedMethods::C in ruby/core/method/fixtures/classes.rb:233)>
  fails "UnboundMethod#super_method after changing an inherited methods visibility returns the expected super_method" # NoMethodError: undefined method `super_method' for #<UnboundMethod: MethodSpecs::InheritedMethods::C#derp (defined in MethodSpecs::InheritedMethods::B in ruby/core/method/fixtures/classes.rb:233)>
  fails "UnboundMethod#super_method returns nil when the parent's method is removed" # NoMethodError: undefined method `super_method' for #<UnboundMethod: #<Class:0x4b228>#foo (defined in #<Class:0x4b228> in ruby/core/unboundmethod/super_method_spec.rb:21)>
  fails "UnboundMethod#super_method returns nil when there's no super method in the parent" # NoMethodError: undefined method `super_method' for #<UnboundMethod: Kernel#method (defined in Kernel in <internal:corelib/kernel.rb>:32)>
  fails "UnboundMethod#super_method returns the method that would be called by super in the method" # NoMethodError: undefined method `super_method' for #<UnboundMethod: UnboundMethodSpecs::C#overridden (defined in UnboundMethodSpecs::C in ruby/core/unboundmethod/fixtures/classes.rb:91)>
  fails "UnboundMethod#to_s does not show the defining module if it is the same as the origin" # Expected "#<UnboundMethod:0x10a0c>".start_with? "#<UnboundMethod: UnboundMethodSpecs::A#baz" to be truthy but was false
  fails "UnboundMethod#to_s returns a String including all details" # Expected "#<UnboundMethod:0x10a92>".start_with? "#<UnboundMethod: UnboundMethodSpecs::Methods(UnboundMethodSpecs::Mod)#from_mod" to be truthy but was false
  fails "UnboundMethod#to_s the String shows the method name, Module defined in and Module extracted from" # Expected "#<UnboundMethod:0x10a48>" =~ /\bfrom_mod\b/ to be truthy but was nil
end
