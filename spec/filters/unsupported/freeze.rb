# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "freezing" do
  fails "A method definition inside a metaclass scope raises FrozenError if frozen" # Expected FrozenError but no exception was raised ("foo" was returned)
  fails "A method definition inside a metaclass scope raises RuntimeError if frozen"
  fails "A singleton method definition raises FrozenError if frozen" # Expected FrozenError but no exception was raised ("foo" was returned)
  fails "A singleton method definition raises RuntimeError if frozen"
  fails "Array#<< raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised ([1, 2, 3, 5] was returned)
  fails "Array#[]= raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised ([] was returned)
  fails "Array#append raises a FrozenError on a frozen array" # NoMethodError: undefined method `append' for [1, 2, 3]:Array
  fails "Array#clear raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised ([] was returned)
  fails "Array#collect! when frozen raises a FrozenError when calling #each on the returned Enumerator when empty" # Expected FrozenError but no exception was raised ([] was returned)
  fails "Array#collect! when frozen raises a FrozenError when calling #each on the returned Enumerator" # Expected FrozenError but no exception was raised ([1, 2, 3] was returned)
  fails "Array#collect! when frozen raises a FrozenError when empty" # Expected FrozenError but no exception was raised ([] was returned)
  fails "Array#collect! when frozen raises a FrozenError" # Expected FrozenError but no exception was raised ([nil, nil, nil] was returned)
  fails "Array#compact! raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Array#concat raises a FrozenError when Array is frozen and modification occurs" # Expected FrozenError but no exception was raised ([1, 2, 3, 1] was returned)
  fails "Array#concat raises a FrozenError when Array is frozen and no modification occurs" # Expected FrozenError but no exception was raised ([1, 2, 3] was returned)
  fails "Array#delete raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised (1 was returned)
  fails "Array#delete returns nil on a frozen array if a modification does not take place"
  fails "Array#delete_at raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised (1 was returned)
  fails "Array#delete_if raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised ([1, 2, 3] was returned)
  fails "Array#delete_if raises a FrozenError on an empty frozen array" # Expected FrozenError but no exception was raised ([] was returned)
  fails "Array#dup does not copy frozen status from the original"
  fails "Array#fill raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised (["x", "x", "x"] was returned)
  fails "Array#fill raises a FrozenError on an empty frozen array" # Expected FrozenError but no exception was raised ([] was returned)
  fails "Array#filter! on frozen objects returns an Enumerator if no block is given" # NoMethodError: undefined method `filter!' for [true, false]
  fails "Array#filter! on frozen objects with falsy block raises a FrozenError" # Expected FrozenError but got: NoMethodError (undefined method `filter!' for [true, false])
  fails "Array#filter! on frozen objects with truthy block raises a FrozenError" # Expected FrozenError but got: NoMethodError (undefined method `filter!' for [true, false])
  fails "Array#flatten! raises a FrozenError on frozen arrays when the array is modified" # Expected FrozenError but no exception was raised ([1, 2] was returned)
  fails "Array#flatten! raises a FrozenError on frozen arrays when the array would not be modified" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Array#initialize raises a FrozenError on frozen arrays" # Expected FrozenError but no exception was raised ([] was returned)
  fails "Array#insert raises a FrozenError on frozen arrays when the array is modified" # Expected FrozenError but no exception was raised (["x", 1, 2, 3] was returned)
  fails "Array#insert raises a FrozenError on frozen arrays when the array would not be modified" # Expected FrozenError but no exception was raised ([1, 2, 3] was returned)
  fails "Array#keep_if on frozen objects with falsy block raises a FrozenError" # Expected FrozenError but no exception was raised ([] was returned)
  fails "Array#keep_if on frozen objects with truthy block raises a FrozenError" # Expected FrozenError but no exception was raised ([true, false] was returned)
  fails "Array#map! when frozen raises a FrozenError when calling #each on the returned Enumerator when empty" # Expected FrozenError but no exception was raised ([] was returned)
  fails "Array#map! when frozen raises a FrozenError when calling #each on the returned Enumerator" # Expected FrozenError but no exception was raised ([1, 2, 3] was returned)
  fails "Array#map! when frozen raises a FrozenError when empty" # Expected FrozenError but no exception was raised ([] was returned)
  fails "Array#map! when frozen raises a FrozenError" # Expected FrozenError but no exception was raised ([nil, nil, nil] was returned)
  fails "Array#pop passed a number n as an argument raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised ([2, 3] was returned)
  fails "Array#pop raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised (3 was returned)
  fails "Array#pop raises a FrozenError on an empty frozen array" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Array#prepend raises a FrozenError on a frozen array when the array is modified" # NoMethodError: undefined method `prepend' for [1, 2, 3]:Array
  fails "Array#prepend raises a FrozenError on a frozen array when the array would not be modified" # NoMethodError: undefined method `prepend' for [1, 2, 3]:Array
  fails "Array#push raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised ([1, 2, 3, 1] was returned)
  fails "Array#reject! raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Array#reject! raises a FrozenError on an empty frozen array" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Array#replace raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised ([1, 2, 3] was returned)
  fails "Array#reverse! raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised ([3, 2, 1] was returned)
  fails "Array#rotate does not mutate the receiver"
  fails "Array#rotate! raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised ([1, 2, 3] was returned)
  fails "Array#rotate! raises a RuntimeError on a frozen array"
  fails "Array#select! on frozen objects returns an Enumerator if no block is given"
  fails "Array#select! on frozen objects with falsy block raises a FrozenError" # Expected FrozenError but no exception was raised ([] was returned)
  fails "Array#select! on frozen objects with truthy block raises a FrozenError" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Array#shift raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised (1 was returned)
  fails "Array#shift raises a FrozenError on an empty frozen array" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Array#shuffle! raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised ([1, 2, 3] was returned)
  fails "Array#slice! raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised ([] was returned)
  fails "Array#sort does not freezes self during being sorted"
  fails "Array#sort! raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised ([1, 2, 3] was returned)
  fails "Array#sort_by! raises a FrozenError on a frozen array" # Expected FrozenError but no exception was raised ([1, 2, 3] was returned)
  fails "Array#sort_by! raises a FrozenError on an empty frozen array" # Expected FrozenError but no exception was raised ([] was returned)
  fails "Array#sort_by! raises a RuntimeError on a frozen array"
  fails "Array#sort_by! raises a RuntimeError on an empty frozen array"
  fails "Array#uniq! raises a FrozenError on a frozen array when the array is modified" # Expected FrozenError but no exception was raised ([1, 2] was returned)
  fails "Array#uniq! raises a FrozenError on a frozen array when the array would not be modified" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Array#unshift raises a FrozenError on a frozen array when the array is modified" # Expected FrozenError but no exception was raised ([1, 1, 2, 3] was returned)
  fails "Array#unshift raises a FrozenError on a frozen array when the array would not be modified" # Expected FrozenError but no exception was raised ([1, 2, 3] was returned)
  fails "Date constants freezes MONTHNAMES, DAYNAMES, ABBR_MONTHNAMES, ABBR_DAYSNAMES"
  fails "Enumerable#sort doesn't raise an error if #to_a returns a frozen Array"
  fails "Enumerator#initialize on frozen instance raises a RuntimeError"
  fails "FalseClass#to_s returns a frozen string" # Expected "false".frozen? to be truthy but was false
  fails "FrozenError#receiver should return frozen object that modification was attempted on" # RuntimeError: RuntimeError
  fails "FrozenError.new should take optional receiver argument" # NoMethodError: undefined method `receiver' for #<FrozenError: msg>
  fails "Hash literal does not change encoding of literal string keys during creation"
  fails "Hash literal freezes string keys on initialization"
  fails "Hash#== compares keys with matching hash codes via eql?"
  fails "Hash#[]= doesn't duplicate and freeze already frozen string keys"
  fails "Hash#[]= raises a FrozenError if called on a frozen instance" # Expected FrozenError but no exception was raised (2 was returned)
  fails "Hash#clear raises a FrozenError if called on a frozen instance" # Expected FrozenError but no exception was raised ({} was returned)
  fails "Hash#compact! on frozen instance keeps pairs and raises a FrozenError" # Expected FrozenError but no exception was raised ({"truthy"=>true, "false"=>false, nil=>true} was returned)
  fails "Hash#compact! on frozen instance keeps pairs and raises a RuntimeError"
  fails "Hash#compare_by_identity raises a FrozenError on frozen hashes" # Expected FrozenError but no exception was raised ({} was returned)
  fails "Hash#default= raises a FrozenError if called on a frozen instance" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Hash#default_proc= raises a FrozenError if self is frozen" # Expected FrozenError but no exception was raised (main was returned)
  fails "Hash#delete raises a FrozenError if called on a frozen instance" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Hash#delete_if raises a FrozenError if called on a frozen instance" # Expected FrozenError but no exception was raised ({1=>2, 3=>4} was returned)
  fails "Hash#delete_if returns an Enumerator if called on a frozen instance"
  fails "Hash#each returns an Enumerator if called on a frozen instance"
  fails "Hash#each_key returns an Enumerator if called on a frozen instance"
  fails "Hash#each_pair returns an Enumerator if called on a frozen instance"
  fails "Hash#each_value returns an Enumerator if called on a frozen instance"
  fails "Hash#eql? compares keys with matching hash codes via eql?"
  fails "Hash#filter returns an Enumerator if called on a frozen instance" # NoMethodError: undefined method `filter' for {1=>2, 3=>4, 5=>6}
  fails "Hash#filter! raises a FrozenError if called on a frozen instance that would not be modified" # Expected FrozenError but got: NoMethodError (undefined method `filter!' for {1=>2, 3=>4})
  fails "Hash#filter! raises a FrozenError if called on an empty frozen instance" # Expected FrozenError but got: NoMethodError (undefined method `filter!' for {})
  fails "Hash#filter! returns an Enumerator if called on a frozen instance" # NoMethodError: undefined method `filter!' for {1=>2, 3=>4, 5=>6}
  fails "Hash#initialize raises a FrozenError if called on a frozen instance" # Expected FrozenError but no exception was raised ({1=>2, 3=>4} was returned)
  fails "Hash#keep_if raises a FrozenError if called on a frozen instance" # Expected FrozenError but no exception was raised ({} was returned)
  fails "Hash#keep_if returns an Enumerator if called on a frozen instance"
  fails "Hash#merge! raises a FrozenError on a frozen instance that is modified" # Expected FrozenError but no exception was raised ({1=>2} was returned)
  fails "Hash#merge! raises a FrozenError on a frozen instance that would not be modified" # Expected FrozenError but no exception was raised ({1=>2} was returned)
  fails "Hash#rehash raises a FrozenError if called on a frozen instance" # Expected FrozenError but no exception was raised ({} was returned)
  fails "Hash#reject returns an Enumerator if called on a frozen instance"
  fails "Hash#reject! raises a FrozenError if called on a frozen instance that is modified" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Hash#reject! raises a FrozenError if called on a frozen instance that would not be modified" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Hash#replace raises a FrozenError if called on a frozen instance that is modified" # Expected FrozenError but no exception was raised ({} was returned)
  fails "Hash#replace raises a FrozenError if called on a frozen instance that would not be modified" # Expected FrozenError but no exception was raised ({} was returned)
  fails "Hash#select returns an Enumerator if called on a frozen instance"
  fails "Hash#select! raises a FrozenError if called on a frozen instance that would not be modified" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Hash#select! raises a FrozenError if called on an empty frozen instance" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Hash#select! returns an Enumerator if called on a frozen instance"
  fails "Hash#shift raises a FrozenError if called on a frozen instance" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Hash#store doesn't duplicate and freeze already frozen string keys"
  fails "Hash#store raises a FrozenError if called on a frozen instance" # Expected FrozenError but no exception was raised (2 was returned)
  fails "Hash#transform_keys! on frozen instance keeps pairs and raises a FrozenError" # NoMethodError: undefined method `transform_keys!' for {"a"=>1, "b"=>2, "c"=>3, "d"=>4}
  fails "Hash#transform_keys! on frozen instance raises a FrozenError on an empty hash" # NoMethodError: undefined method `transform_keys!' for {}
  fails "Hash#transform_values! on frozen instance keeps pairs and raises a FrozenError" # Expected FrozenError but no exception was raised ({"a"=>2, "b"=>3, "c"=>4} was returned)
  fails "Hash#transform_values! on frozen instance keeps pairs and raises a RuntimeError"
  fails "Hash#transform_values! on frozen instance raises a FrozenError on an empty hash" # Expected FrozenError but no exception was raised ({} was returned)
  fails "Hash#transform_values! on frozen instance when no block is given does not raise an exception"
  fails "Hash#update raises a FrozenError on a frozen instance that is modified" # Expected FrozenError but no exception was raised ({1=>2} was returned)
  fails "Hash#update raises a FrozenError on a frozen instance that would not be modified" # Expected FrozenError but no exception was raised ({} was returned)
  fails "Kernel#clone copies frozen state from the original"
  fails "Kernel#clone copies frozen? and tainted?" # Expected false to be true
  fails "Kernel#clone takes an freeze: true option to frozen copy" # Expected #<KernelSpecs::Duplicate:0x25158>.frozen? to be truthy but was false
  fails "Kernel#clone takes an option to copy freeze state or not" # TODO: move to unsupported/freeze
  fails "Kernel#extend on frozen instance raises a FrozenError" # Expected FrozenError but no exception was raised (main was returned)
  fails "Kernel#extend on frozen instance raises a RuntimeError"
  fails "Kernel#extend on frozen instance raises an ArgumentError when no arguments given"
  fails "Kernel#freeze causes instance_variable_set to raise RuntimeError"
  fails "Kernel#freeze causes mutative calls to raise RuntimeError"
  fails "Kernel#freeze on a Complex has no effect since it is already frozen" # Expected false to be true
  fails "Kernel#freeze on a Float has no effect since it is already frozen"
  fails "Kernel#freeze on a Rational has no effect since it is already frozen" # Expected false to be true
  fails "Kernel#freeze on a Symbol has no effect since it is already frozen"
  fails "Kernel#freeze on integers has no effect since they are already frozen"
  fails "Kernel#freeze on true, false and nil has no effect since they are already frozen"
  fails "Kernel#freeze prevents self from being further modified"
  fails "Kernel#freeze returns self"
  fails "Kernel#frozen? on a Complex literal returns true" # Expected false to be true
  fails "Kernel#frozen? on a Complex returns true" # Expected false to be true
  fails "Kernel#frozen? on a Float returns true"
  fails "Kernel#frozen? on a Rational literal returns true" # Expected false to be true
  fails "Kernel#frozen? on a Rational returns true" # Expected false to be true
  fails "Kernel#frozen? on a Symbol returns true"
  fails "Kernel#frozen? on integers returns true"
  fails "Kernel#frozen? on true, false and nil returns true"
  fails "Kernel#frozen? returns true if self is frozen"
  fails "Kernel#instance_variable_set on frozen objects keeps stored object after any exceptions"
  fails "Kernel#instance_variable_set on frozen objects raises a FrozenError when passed replacement is different from stored object" # Expected FrozenError but no exception was raised ("replacement" was returned)
  fails "Kernel#instance_variable_set on frozen objects raises a FrozenError when passed replacement is identical to stored object" # Expected FrozenError but no exception was raised ("origin" was returned)
  fails "Kernel#instance_variable_set on frozen objects raises a RuntimeError when passed replacement is different from stored object"
  fails "Kernel#instance_variable_set on frozen objects raises a RuntimeError when passed replacement is identical to stored object"
  fails "Literal Regexps is frozen" # Expected /Hello/.frozen? to be truthy but was false
  fails "MatchData#string returns a frozen copy of the match string"
  fails "Module#alias_method raises FrozenError if frozen" # Expected FrozenError but no exception was raised (#<Class:0x39d44> was returned)
  fails "Module#alias_method raises RuntimeError if frozen"
  fails "Module#append_features when other is frozen raises a FrozenError before appending self" # Expected FrozenError but no exception was raised (#<Module:0x3fbfa> was returned)
  fails "Module#append_features when other is frozen raises a RuntimeError before appending self"
  fails "Module#autoload on a frozen module raises a FrozenError before setting the name" # Exception: Cannot read property '$pretty_inspect' of undefined
  fails "Module#autoload on a frozen module raises a RuntimeError before setting the name"
  fails "Module#class_variable_set raises a FrozenError when self is frozen" # Expected FrozenError but no exception was raised ("test" was returned)
  fails "Module#class_variable_set raises a RuntimeError when self is frozen"
  fails "Module#const_set on a frozen module raises a FrozenError before setting the name" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Module#const_set on a frozen module raises a RuntimeError before setting the name"
  fails "Module#define_method raises a FrozenError if frozen" # Expected FrozenError but no exception was raised (#<Class:0x13e2> was returned)
  fails "Module#define_method raises a RuntimeError if frozen"
  fails "Module#extend_object when given a frozen object raises a RuntimeError before extending the object"
  fails "Module#name returns a frozen String" # Expected "ModuleSpecs".frozen? to be truthy but was false
  fails "Module#name returns a mutable string that when mutated does not modify the original module name" # NotImplementedError: String#<< not supported. Mutable String methods are not supported in Opal.
  fails "Module#remove_method on frozen instance does not raise exceptions when no arguments given"
  fails "Module#remove_method on frozen instance raises a FrozenError when passed a missing name" # NameError: method 'not_exist' not defined in
  fails "Module#remove_method on frozen instance raises a FrozenError when passed a name" # NameError: method 'method_to_remove' not defined in
  fails "Module#remove_method on frozen instance raises a RuntimeError when passed a missing name"
  fails "Module#remove_method on frozen instance raises a RuntimeError when passed a name"
  fails "Module#remove_method on frozen instance raises a TypeError when passed a not name"
  fails "Module#undef_method on frozen instance does not raise exceptions when no arguments given"
  fails "Module#undef_method on frozen instance raises a FrozenError when passed a missing name" # NameError: method 'not_exist' not defined in
  fails "Module#undef_method on frozen instance raises a FrozenError when passed a name" # NameError: method 'method_to_undef' not defined in
  fails "Module#undef_method on frozen instance raises a RuntimeError when passed a missing name"
  fails "Module#undef_method on frozen instance raises a RuntimeError when passed a name"
  fails "Module#undef_method on frozen instance raises a TypeError when passed a not name"
  fails "NilClass#to_s returns a frozen string" # Expected "".frozen? to be truthy but was false
  fails "OpenStruct#method_missing when called with a method name ending in '=' raises a TypeError when self is frozen"
  fails "Proc#[] with frozen_string_literals doesn't duplicate frozen strings" # Expected false to be true
  fails "Regexp#initialize raises a FrozenError on a Regexp literal" # Expected FrozenError but no exception was raised (nil was returned)
  fails "Set#compare_by_identity raises a FrozenError on frozen sets" # NoMethodError: undefined method `compare_by_identity' for #<Set: {}>
  fails "String#+@ returns an unfrozen copy of a frozen String"
  fails "String#+@ returns self if the String is not frozen"
  fails "String#-@ deduplicates frozen strings" # Expected "this string is frozen" not to be identical to "this string is frozen"
  fails "String#-@ interns the provided string if it is frozen" # NoMethodError: undefined method `-@' for "this string is unique and frozen 0.5421131713191049"
  fails "String#-@ returns a frozen copy if the String is not frozen"
  fails "String#-@ returns self if the String is frozen"
  fails "String#<< raises a FrozenError when self is frozen" # NotImplementedError: String#<< not supported. Mutable String methods are not supported in Opal.
  fails "String#<< with Integer raises a FrozenError when self is frozen" # NotImplementedError: String#<< not supported. Mutable String methods are not supported in Opal.
  fails "String#[]= with Fixnum index raises a FrozenError when self is frozen" # NoMethodError: undefined method `[]=' for "hello":String
  fails "String#capitalize! raises a FrozenError when self is frozen" # NotImplementedError: String#capitalize! not supported. Mutable String methods are not supported in Opal.
  fails "String#chomp! raises a FrozenError on a frozen instance when it is modified" # NotImplementedError: String#chomp! not supported. Mutable String methods are not supported in Opal.
  fails "String#chomp! raises a FrozenError on a frozen instance when it would not be modified" # NotImplementedError: String#chomp! not supported. Mutable String methods are not supported in Opal.
  fails "String#chop! raises a FrozenError on a frozen instance that is modified" # NotImplementedError: String#chop! not supported. Mutable String methods are not supported in Opal.
  fails "String#chop! raises a FrozenError on a frozen instance that would not be modified" # NotImplementedError: String#chop! not supported. Mutable String methods are not supported in Opal.
  fails "String#clear raises a FrozenError if self is frozen" # NoMethodError: undefined method `clear' for "Jolene":String
  fails "String#clone copies frozen state"
  fails "String#concat raises a FrozenError when self is frozen" # NoMethodError: undefined method `concat' for "hello":String
  fails "String#concat with Integer raises a FrozenError when self is frozen" # NoMethodError: undefined method `concat' for "hello":String
  fails "String#delete! raises a FrozenError when self is frozen" # NoMethodError: undefined method `delete!' for "hello":String
  fails "String#delete_prefix! raises a FrozenError when self is frozen" # NoMethodError: undefined method `delete_prefix!' for "hello":String
  fails "String#delete_suffix! raises a FrozenError when self is frozen" # NoMethodError: undefined method `delete_suffix!' for "hello":String
  fails "String#downcase! raises a FrozenError when self is frozen" # NotImplementedError: String#downcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#encode! raises a FrozenError when called on a frozen String when it's a no-op" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#encode! raises a FrozenError when called on a frozen String" # NoMethodError: undefined method `default_internal' for Encoding
  fails "String#force_encoding raises a FrozenError if self is frozen" # Expected FrozenError but no exception was raised ("abcd" was returned)
  fails "String#freeze doesn't produce the same object for different instances of literals in the source"
  fails "String#gsub! with pattern and block raises a FrozenError when self is frozen" # NotImplementedError: String#gsub! not supported. Mutable String methods are not supported in Opal.
  fails "String#gsub! with pattern and replacement raises a FrozenError when self is frozen" # NotImplementedError: String#gsub! not supported. Mutable String methods are not supported in Opal.
  fails "String#initialize with an argument raises a FrozenError on a frozen instance that is modified" # NotImplementedError: Mutable strings are not supported in Opal.
  fails "String#initialize with an argument raises a FrozenError on a frozen instance when self-replacing" # NotImplementedError: Mutable strings are not supported in Opal.
  fails "String#initialize with no arguments does not raise an exception when frozen"
  fails "String#insert with index, other raises a FrozenError if self is frozen" # NoMethodError: undefined method `insert' for "abcd":String
  fails "String#lstrip! raises a FrozenError on a frozen instance that is modified" # NotImplementedError: String#lstrip! not supported. Mutable String methods are not supported in Opal.
  fails "String#lstrip! raises a FrozenError on a frozen instance that would not be modified" # NotImplementedError: String#lstrip! not supported. Mutable String methods are not supported in Opal.
  fails "String#next! raises a FrozenError if self is frozen" # NotImplementedError: String#next! not supported. Mutable String methods are not supported in Opal.
  fails "String#prepend raises a FrozenError when self is frozen" # NoMethodError: undefined method `prepend' for "hello":String
  fails "String#replace raises a FrozenError on a frozen instance that is modified" # NoMethodError: undefined method `replace' for "hello":String
  fails "String#replace raises a FrozenError on a frozen instance when self-replacing" # NoMethodError: undefined method `replace' for "hello":String
  fails "String#reverse! raises a FrozenError on a frozen instance that is modified" # NotImplementedError: String#reverse! not supported. Mutable String methods are not supported in Opal.
  fails "String#reverse! raises a FrozenError on a frozen instance that would not be modified" # NotImplementedError: String#reverse! not supported. Mutable String methods are not supported in Opal.
  fails "String#rstrip! raises a FrozenError on a frozen instance that is modified" # NoMethodError: undefined method `rstrip!' for "  hello  ":String
  fails "String#rstrip! raises a FrozenError on a frozen instance that would not be modified" # NoMethodError: undefined method `rstrip!' for "hello":String
  fails "String#setbyte raises a FrozenError if self is frozen" # Expected false to be true
  fails "String#slice! Range raises a FrozenError on a frozen instance that is modified" # NotImplementedError: String#slice! not supported. Mutable String methods are not supported in Opal.
  fails "String#slice! Range raises a FrozenError on a frozen instance that would not be modified" # NotImplementedError: String#slice! not supported. Mutable String methods are not supported in Opal.
  fails "String#slice! with Regexp raises a FrozenError on a frozen instance that is modified" # NotImplementedError: String#slice! not supported. Mutable String methods are not supported in Opal.
  fails "String#slice! with Regexp raises a FrozenError on a frozen instance that would not be modified" # NotImplementedError: String#slice! not supported. Mutable String methods are not supported in Opal.
  fails "String#slice! with Regexp, index raises a FrozenError if self is frozen" # NotImplementedError: String#slice! not supported. Mutable String methods are not supported in Opal.
  fails "String#slice! with String raises a FrozenError if self is frozen" # NotImplementedError: String#slice! not supported. Mutable String methods are not supported in Opal.
  fails "String#slice! with index raises a FrozenError if self is frozen" # NotImplementedError: String#slice! not supported. Mutable String methods are not supported in Opal.
  fails "String#slice! with index, length raises a FrozenError if self is frozen" # NotImplementedError: String#slice! not supported. Mutable String methods are not supported in Opal.
  fails "String#squeeze! raises a FrozenError when self is frozen" # NotImplementedError: String#squeeze! not supported. Mutable String methods are not supported in Opal.
  fails "String#strip! raises a FrozenError on a frozen instance that is modified" # NotImplementedError: String#strip! not supported. Mutable String methods are not supported in Opal.
  fails "String#strip! raises a FrozenError on a frozen instance that would not be modified" # NotImplementedError: String#strip! not supported. Mutable String methods are not supported in Opal.
  fails "String#sub! with pattern and block raises a FrozenError when self is frozen" # NotImplementedError: String#sub! not supported. Mutable String methods are not supported in Opal.
  fails "String#sub! with pattern, replacement raises a FrozenError when self is frozen" # NotImplementedError: String#sub! not supported. Mutable String methods are not supported in Opal.
  fails "String#succ! raises a FrozenError if self is frozen" # NotImplementedError: String#succ! not supported. Mutable String methods are not supported in Opal.
  fails "String#swapcase! raises a FrozenError when self is frozen" # NotImplementedError: String#swapcase! not supported. Mutable String methods are not supported in Opal.
  fails "String#tr! raises a FrozenError if self is frozen" # NotImplementedError: String#tr! not supported. Mutable String methods are not supported in Opal.
  fails "String#tr_s! raises a FrozenError if self is frozen" # NotImplementedError: String#tr_s! not supported. Mutable String methods are not supported in Opal.
  fails "String#upcase! raises a FrozenError when self is frozen" # NotImplementedError: String#upcase! not supported. Mutable String methods are not supported in Opal.
  fails "StringScanner#initialize returns an instance of StringScanner"
  fails "Time#gmtime on a frozen time raises a RuntimeError if the time is not UTC"
  fails "Time#localtime on a frozen time does not raise an error if already in the right time zone"
  fails "Time#localtime on a frozen time raises a RuntimeError if the time has a different time zone"
  fails "Time#utc on a frozen time raises a RuntimeError if the time is not UTC"
  fails "TrueClass#to_s returns a frozen string" # Expected "true".frozen? to be truthy but was false
end
