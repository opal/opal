# NOTE: run bin/format-filters after changing this file
opal_filter "Method" do
  fails "Method#<< does not try to coerce argument with #to_proc" # Expected TypeError (callable object is expected) but no exception was raised (#<Proc:0x3c64> was returned)
  fails "Method#<< raises TypeError if passed not callable object" # Expected TypeError (callable object is expected) but no exception was raised (#<Proc:0x3ca0> was returned)
  fails "Method#== missing methods returns true for the same method missing" # NameError: undefined method `handled_via_method_missing' for class `MethodSpecs::Methods'
  fails "Method#== returns true if a method was defined using the other one" # Expected false to be true
  fails "Method#== returns true if methods are the same" # Expected false to be true
  fails "Method#== returns true if the two core methods are aliases" # Expected false to be true
  fails "Method#== returns true on aliased methods" # Expected false to be true
  fails "Method#>> composition is a lambda" # Expected #<Proc:0x3d52>.lambda? to be truthy but was false
  fails "Method#>> does not try to coerce argument with #to_proc" # Expected TypeError (callable object is expected) but no exception was raised (#<Proc:0x3cee> was returned)
  fails "Method#>> raises TypeError if passed not callable object" # Expected TypeError (callable object is expected) but no exception was raised (#<Proc:0x3d2a> was returned)
  fails "Method#clone returns a copy of the method" # Expected #<Method: MethodSpecs::Methods#foo (defined in MethodSpecs::Methods in ruby/core/method/fixtures/classes.rb:24)> == #<Method: MethodSpecs::Methods#foo (defined in MethodSpecs::Methods in ruby/core/method/fixtures/classes.rb:24)> to be truthy but was false
  fails "Method#curry with optional arity argument raises ArgumentError when the method requires less arguments than the given arity" # Expected ArgumentError but no exception was raised (#<Proc:0x7c68a> was returned)
  fails "Method#curry with optional arity argument raises ArgumentError when the method requires more arguments than the given arity" # Expected ArgumentError but no exception was raised (#<Proc:0x7c66a> was returned)
  fails "Method#define_method when passed a Proc object and a method is defined inside defines the nested method in the default definee where the Proc was created" # Expected #<#<Class:0x51aa0>:0x51a9c> NOT to have method 'nested_method_in_proc_for_define_method' but it does
  fails "Method#eql? missing methods returns true for the same method missing" # NameError: undefined method `handled_via_method_missing' for class `MethodSpecs::Methods'
  fails "Method#eql? returns true if a method was defined using the other one" # Expected false to be true
  fails "Method#eql? returns true if methods are the same" # Expected false to be true
  fails "Method#eql? returns true if the two core methods are aliases" # Expected false to be true
  fails "Method#eql? returns true on aliased methods" # Expected false to be true
  fails "Method#hash returns the same value for builtin methods that are eql?" # Expected 282998 == 283002 to be truthy but was false
  fails "Method#hash returns the same value for user methods that are eql?" # Expected 283044 == 283048 to be truthy but was false
  fails "Method#inspect returns a String containing method arguments" # Expected "#<Method: MethodSpecs::Methods#zero (defined in MethodSpecs::Methods in ruby/core/method/fixtures/classes.rb:49)>".include? "()" to be truthy but was false
  fails "Method#inspect returns a String containing the Module containing the method if object has a singleton class but method is not defined in the singleton class" # Expected "#<Method: MethodSpecs::MySub#bar (defined in MethodSpecs::MyMod in ruby/core/method/fixtures/classes.rb:105)>".start_with? "#<Method: MethodSpecs::MySub(MethodSpecs::MyMod)#bar" to be truthy but was false
  fails "Method#inspect returns a String containing the singleton class if method is defined in the singleton class" # Expected "#<Method: MethodSpecs::MySub#bar (defined in #<Class:#<MethodSpecs::MySub:0x50826>> in ruby/core/method/shared/to_s.rb:74)>".start_with? "#<Method: #<MethodSpecs::MySub:0xXXXXXX>.bar" to be truthy but was false
  fails "Method#inspect returns a String including all details" # Expected "#<Method: MethodSpecs::MySub#bar (defined in MethodSpecs::MyMod in ruby/core/method/fixtures/classes.rb:105)>".start_with? "#<Method: MethodSpecs::MySub(MethodSpecs::MyMod)#bar" to be truthy but was false
  fails "Method#inspect shows the metaclass and the owner for a Module instance method retrieved from a class" # Expected "#<Method: Class#include (defined in Module in <internal:corelib/module.rb>:464)>".start_with? "#<Method: #<Class:String>(Module)#include" to be truthy but was false
  fails "Method#original_name returns the name of the method" # NoMethodError: undefined method `original_name' for #<Method: String#upcase (defined in String in <internal:corelib/string.rb>:1685)>
  fails "Method#original_name returns the original name even when aliased twice" # NoMethodError: undefined method `original_name' for #<Method: MethodSpecs::Methods#foo (defined in MethodSpecs::Methods in ruby/core/method/fixtures/classes.rb:24)>
  fails "Method#original_name returns the original name when aliased" # NoMethodError: undefined method `original_name' for #<Method: MethodSpecs::Methods#foo (defined in MethodSpecs::Methods in ruby/core/method/fixtures/classes.rb:24)>
  fails "Method#parameters returns [[:req]] for each parameter for core methods with fixed-length argument lists" # Expected [["req", "other"]] == [["req"]] to be truthy but was false
  fails "Method#parameters returns [[:rest]] for core methods with variable-length argument lists" # NameError: undefined method `delete!' for class `String'
  fails "Method#parameters returns [[:rest]] or [[:opt]] for core methods with optional arguments" # Expected [[["rest"]], [["opt"]]] to include [["opt", "count"]]
  fails "Method#source_location for a Method generated by respond_to_missing? returns nil" # NameError: undefined method `handled_via_method_missing' for class `MethodSpecs::Methods'
  fails "Method#source_location sets the first value to the path of the file in which the method was defined" # Expected "ruby/core/method/fixtures/classes.rb" == "./ruby/core/method/fixtures/classes.rb" to be truthy but was false
  fails "Method#source_location works for eval with a given line" # Expected ["(eval)", 0] == ["foo", 100] to be truthy but was false
  fails "Method#super_method after aliasing an inherited method returns the expected super_method" # NoMethodError: undefined method `super_method' for #<Method: MethodSpecs::InheritedMethods::C#meow (defined in MethodSpecs::InheritedMethods::C in ruby/core/method/fixtures/classes.rb:233)>
  fails "Method#super_method after changing an inherited methods visibility returns the expected super_method" # NoMethodError: undefined method `super_method' for #<Method: MethodSpecs::InheritedMethods::C#derp (defined in MethodSpecs::InheritedMethods::B in ruby/core/method/fixtures/classes.rb:233)>
  fails "Method#super_method returns nil when the parent's method is removed" # NoMethodError: undefined method `super_method' for #<Method: #<Class:0x50682>#overridden (defined in #<Class:0x50682> in ruby/core/method/super_method_spec.rb:36)>
  fails "Method#super_method returns nil when there's no super method in the parent" # NoMethodError: undefined method `super_method' for #<Method: Object#method (defined in Kernel in <internal:corelib/kernel.rb>:32)>
  fails "Method#super_method returns the method that would be called by super in the method" # NoMethodError: undefined method `super_method' for #<Method: MethodSpecs::C#overridden (defined in MethodSpecs::OverrideAgain in ruby/core/method/fixtures/classes.rb:135)>
  fails "Method#to_proc returns a proc that can be used by define_method" # Exception: Cannot create property '$$meta' on string 'test'
  fails "Method#to_proc returns a proc that can receive a block" # LocalJumpError: no block given
  fails "Method#to_proc returns a proc whose binding has the same receiver as the method" # Expected #<MethodSpecs::Methods:0x6f2d6> == nil to be truthy but was false
  fails "Method#to_s does not show the defining module if it is the same as the receiver class" # Expected "#<Method:0x458aa>".start_with? "#<Method: MethodSpecs::A#baz" to be truthy but was false
  fails "Method#to_s returns a String containing method arguments" # Expected "#<Method:0x4583e>".include? "()" to be truthy but was false
  fails "Method#to_s returns a String containing the Module containing the method if object has a singleton class but method is not defined in the singleton class" # Expected "#<Method:0x45952>".start_with? "#<Method: MethodSpecs::MySub(MethodSpecs::MyMod)#bar" to be truthy but was false
  fails "Method#to_s returns a String containing the Module the method is defined in" # Expected "#<Method:0x45870>" =~ /MethodSpecs::MyMod/ to be truthy but was nil
  fails "Method#to_s returns a String containing the Module the method is referenced from" # Expected "#<Method:0x4590e>" =~ /MethodSpecs::MySub/ to be truthy but was nil
  fails "Method#to_s returns a String containing the method name" # Expected "#<Method:0x45804>" =~ /\#bar/ to be truthy but was nil
  fails "Method#to_s returns a String containing the singleton class if method is defined in the singleton class" # Expected "#<Method:0x45988>".start_with? "#<Method: #<MethodSpecs::MySub:0xXXXXXX>.bar" to be truthy but was false
  fails "Method#to_s returns a String including all details" # Expected "#<Method:0x458dc>".start_with? "#<Method: MethodSpecs::MySub(MethodSpecs::MyMod)#bar" to be truthy but was false
  fails "Method#to_s shows the metaclass and the owner for a Module instance method retrieved from a class" # Expected "#<Method: Class#include (defined in Module in <internal:corelib/module.rb>:464)>".start_with? "#<Method: #<Class:String>(Module)#include" to be truthy but was false
  fails "Method#unbind keeps the origin singleton class if there is one" # Expected "#<UnboundMethod: Object#foo (defined in #<Class:#<Object:0x30684>> in ruby/core/method/unbind_spec.rb:37)>".start_with? "#<UnboundMethod: #<Class:#<Object:0x30684>>#foo" to be truthy but was false
  fails "Method#unbind rebinding UnboundMethod to Method's obj produces exactly equivalent Methods" # Expected #<Method: MethodSpecs::Methods#foo (defined in MethodSpecs::Methods in ruby/core/method/fixtures/classes.rb:24)> == #<Method: MethodSpecs::Methods#foo (defined in MethodSpecs::Methods in ruby/core/method/fixtures/classes.rb:24)> to be truthy but was false
  fails_badly "Method#define_method when passed a block behaves exactly like a lambda for break" # Exception: unexpected break
end
