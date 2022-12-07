# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "freezing" do
  fails "Date constants freezes MONTHNAMES, DAYNAMES, ABBR_MONTHNAMES, ABBR_DAYSNAMES"
  fails "FalseClass#to_s returns a frozen string" # Expected "false".frozen? to be truthy but was false
  fails "File.basename returns a new unfrozen String" # Expected "foo.rb" not to be identical to "foo.rb"
  fails "FrozenError#receiver should return frozen object that modification was attempted on" # RuntimeError: RuntimeError
  fails "Hash literal does not change encoding of literal string keys during creation"
  fails "Hash literal freezes string keys on initialization"
  fails "Kernel#clone with freeze: anything else raises ArgumentError when passed not true/false/nil" # Expected ArgumentError (/unexpected value for freeze: Integer/) but got: ArgumentError (unexpected value for freeze: Number)
  fails "Kernel#clone with freeze: false calls #initialize_clone with kwargs freeze: false even if #initialize_clone only takes a single argument" # Expected ArgumentError (wrong number of arguments (given 2, expected 1)) but got: ArgumentError ([Clone#initialize_clone] wrong number of arguments (given 2, expected 1))
  fails "Kernel#clone with freeze: nil copies frozen?" # Fails because of "".freeze.clone(freeze: nil)
  fails "Kernel#clone with freeze: true calls #initialize_clone with kwargs freeze: true even if #initialize_clone only takes a single argument" # Expected ArgumentError (wrong number of arguments (given 2, expected 1)) but got: ArgumentError ([Clone#initialize_clone] wrong number of arguments (given 2, expected 1))
  fails "Kernel#freeze causes mutative calls to raise RuntimeError" # Setting the value fails, but no Exception is raised
  fails "Kernel#freeze on a Symbol has no effect since it is already frozen" # currently cant destinguish between Symbol and String as Symbol = String
  fails "Kernel#frozen? on a Symbol returns true" # currently cant destinguish between Symbol and String as Symbol = String
  fails "Literal Ranges is frozen" # Expected 42...frozen? to be truthy but was false
  fails "Literal Regexps is frozen" # Expected /Hello/.frozen? to be truthy but was false
  fails "Marshal.load when called with freeze: true does not freeze classes" # ArgumentError: [Marshal.load] wrong number of arguments(2 for 1)
  fails "Marshal.load when called with freeze: true does not freeze modules" # ArgumentError: [Marshal.load] wrong number of arguments(2 for 1)
  fails "Marshal.load when called with freeze: true returns frozen arrays" # ArgumentError: [Marshal.load] wrong number of arguments(2 for 1)
  fails "Marshal.load when called with freeze: true returns frozen hashes" # ArgumentError: [Marshal.load] wrong number of arguments(2 for 1)
  fails "Marshal.load when called with freeze: true returns frozen objects" # ArgumentError: [Marshal.load] wrong number of arguments(2 for 1)
  fails "Marshal.load when called with freeze: true returns frozen regexps" # ArgumentError: [Marshal.load] wrong number of arguments(2 for 1)
  fails "Marshal.load when called with freeze: true returns frozen strings" # ArgumentError: [Marshal.load] wrong number of arguments(2 for 1)
  fails "Marshal.load when called with freeze: true when called with a proc call the proc with frozen objects" # ArgumentError: [Marshal.load] wrong number of arguments(3 for 1)
  fails "Marshal.load when called with freeze: true when called with a proc does not freeze the object returned by the proc" # ArgumentError: [Marshal.load] wrong number of arguments(3 for 1)
  fails "MatchData#string returns a frozen copy of the match string"
  fails "Module#name returns a frozen String" # Expected "ModuleSpecs".frozen? to be truthy but was false due to Javascript automatic conversion of primitives into String 'object' when calling methods on the primitive
  fails "NilClass#to_s returns a frozen string" # Expected "".frozen? to be truthy but was false
  fails "OpenStruct#method_missing when called with a method name ending in '=' raises a TypeError when self is frozen"
  fails "Proc#[] with frozen_string_literals doesn't duplicate frozen strings" # Expected false to be true
  fails "Regexp#initialize raises a FrozenError on a Regexp literal" # Expected FrozenError but no exception was raised (nil was returned)
  fails "String#+@ returns an unfrozen copy of a frozen String"
  fails "String#+@ returns self if the String is not frozen"
  fails "String#-@ deduplicates frozen strings" # Expected "this string is frozen" not to be identical to "this string is frozen"
  fails "String#-@ returns a frozen copy if the String is not frozen"
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
  fails "Time#localtime on a frozen time does not raise an error if already in the right time zone"
  fails "Time#localtime on a frozen time raises a RuntimeError if the time has a different time zone"
  fails "TrueClass#to_s returns a frozen string" # Expected "true".frozen? to be truthy but was false
end
