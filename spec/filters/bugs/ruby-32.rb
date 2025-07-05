# NOTE: run bin/format-filters after changing this file
opal_filter "Ruby 3.2" do
  fails "A block yielded a single Array does not autosplat single argument to required arguments when a keyword rest argument is present" # ArgumentError: expected kwargs
  fails "Fixnum is no longer defined" # Expected Object.const_defined? "Fixnum" to be falsy but was true
  fails "Kernel#=~ is no longer defined" # Expected #<Object:0x11214>.respond_to? "=~" to be falsy but was true
  fails "Keyword arguments delegation does not work with call(*ruby2_keyword_args) with missing ruby2_keywords in between" # Expected [[], {}] == [[{}], {}] to be truthy but was false
  fails "Method#owner returns the class on which public was called for a private method in ancestor" # Expected MethodSpecs::InheritedMethods::B == MethodSpecs::InheritedMethods::C to be truthy but was false
  fails "Method#parameters adds * rest arg for \"star\" argument" # Expected [["rest"]] == [["rest", "*"]] to be truthy but was false
  fails "Module#const_added is a private instance method" # Expected Module to have private instance method 'const_added' but it does not
  fails "Module#const_added is called with a precise caller location with the line of definition" # Expected [] == [111, 113, 116, 120] to be truthy but was false
  fails "Module#ruby2_keywords makes a copy and unmark the Hash when calling a method taking (*args)" # Expected false == true to be truthy but was false
  fails "Proc#parameters adds * rest arg for \"star\" argument" # Expected [["req", "x"], ["rest"]] == [["req", "x"], ["rest", "*"]] to be truthy but was false
  fails "Random::DEFAULT is no longer defined" # Expected Random.const_defined? "DEFAULT" to be falsy but was true
  fails "Refinement#append_features is not called by Module#include" # Expected TypeError but no exception was raised (#<Class:0x2e61c> was returned)
  fails "Refinement#extend_object is not called by Object#extend" # Expected TypeError but no exception was raised (#<Class:0x28fcc> was returned)
  fails "Refinement#prepend_features is not called by Module#prepend" # Expected TypeError but no exception was raised (#<Class:0x70cf6> was returned)
  fails "Regexp.compile given a String accepts a String of supported flags as the second argument" # Expected 0 == 0 to be falsy but was true
  fails "Regexp.compile given a String raises an Argument error if the second argument contains unsupported chars" # Expected ArgumentError but no exception was raised (/Hi/i was returned)
  fails "Regexp.compile given a String warns any non-Integer, non-nil, non-false second argument" # Expected warning to match: /expected true or false as ignorecase/ but got: ""
  fails "Regexp.new given a String accepts a String of supported flags as the second argument" # Expected 0 == 0 to be falsy but was true
  fails "Regexp.new given a String raises an Argument error if the second argument contains unsupported chars" # Expected ArgumentError but no exception was raised (/Hi/i was returned)
  fails "Regexp.new given a String warns any non-Integer, non-nil, non-false second argument" # Expected warning to match: /expected true or false as ignorecase/ but got: ""
  fails "Regexp.timeout raises Regexp::TimeoutError after global timeout elapsed" # NoMethodError: undefined method `timeout=' for Regexp
  fails "Regexp.timeout raises Regexp::TimeoutError after timeout keyword value elapsed" # NoMethodError: undefined method `timeout=' for Regexp
  fails "Regexp.timeout returns global timeout" # NoMethodError: undefined method `timeout=' for Regexp
  fails "String#dedup deduplicates frozen strings" # Expected "this string is frozen" not to be identical to "this string is frozen"
  fails "String#dedup does not deduplicate a frozen string when it has instance variables" # Exception: Cannot create property 'a' on string 'this string is frozen'
  fails "String#dedup interns the provided string if it is frozen" # NoMethodError: undefined method `dedup' for "this string is unique and frozen 0.698166086070234"
  fails "String#dedup returns a frozen copy if the String is not frozen" # NoMethodError: undefined method `dedup' for "foo"
  fails "String#dedup returns self if the String is frozen" # NoMethodError: undefined method `dedup' for "foo"
  fails "String#dedup returns the same object for equal unfrozen strings" # Expected "this is a string" not to be identical to "this is a string"
  fails "String#dedup returns the same object when it's called on the same String literal" # NoMethodError: undefined method `dedup' for "unfrozen string"
  fails "Struct.new on subclasses accepts keyword arguments to initialize" # Expected #<struct  args={"args"=>42}> == #<struct  args=42> to be truthy but was false
  fails "Struct.new raises a TypeError if passed a Hash with an unknown key" # Expected TypeError but no exception was raised (#<Class:0x356> was returned)
  fails "Symbol#to_proc only calls public methods" # Expected NoMethodError (/protected method `pro' called/) but no exception was raised (#<MSpecEnv:0x146c8 @a=["pub", "pro"]> was returned)
  fails "The module keyword does not reopen a module included in Object" # Expected ModuleSpecs::IncludedInObject::IncludedModuleSpecs == ModuleSpecs::IncludedInObject::IncludedModuleSpecs to be falsy but was true
  fails "UnboundMethod#owner returns the class on which public was called for a private method in ancestor" # Expected MethodSpecs::InheritedMethods::B == MethodSpecs::InheritedMethods::C to be truthy but was false
  fails "main.using does not raise error when wrapped with module" # Expected to not get Exception but got: ArgumentError ([MSpecEnv#load] wrong number of arguments (given 2, expected 1))
end
