# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "freezing" do
  fails "FalseClass#to_s returns a frozen string" # Expected "false".frozen? to be truthy but was false
  fails "File.basename returns a new unfrozen String" # Expected "foo.rb" not to be identical to "foo.rb"
  fails "Frozen properties is frozen if the object it is created from is frozen" # Expected false == true to be truthy but was false
  fails "Frozen properties will be frozen if the object it is created from becomes frozen" # Expected false == true to be truthy but was false
  fails "FrozenError#receiver should return frozen object that modification was attempted on" # Expected #<Class:#<Object:0x19582>> to be identical to #<Object:0x19582>
  fails "Hash literal freezes string keys on initialization" # NotImplementedError: String#reverse! not supported. Mutable String methods are not supported in Opal.
  fails "Kernel#clone with freeze: anything else raises ArgumentError when passed not true/false/nil" # Expected ArgumentError (/unexpected value for freeze: Integer/) but got: ArgumentError (unexpected value for freeze: Number)
  fails "Kernel#clone with freeze: false calls #initialize_clone with kwargs freeze: false even if #initialize_clone only takes a single argument" # Expected ArgumentError (wrong number of arguments (given 2, expected 1)) but got: ArgumentError ([Clone#initialize_clone] wrong number of arguments (given 2, expected 1))
  fails "Kernel#clone with freeze: true calls #initialize_clone with kwargs freeze: true even if #initialize_clone only takes a single argument" # Expected ArgumentError (wrong number of arguments (given 2, expected 1)) but got: ArgumentError ([Clone#initialize_clone] wrong number of arguments (given 2, expected 1))
  fails "Kernel#freeze causes mutative calls to raise RuntimeError" # Expected RuntimeError but no exception was raised (1 was returned)
  fails "Kernel#freeze on a Symbol has no effect since it is already frozen" # Expected false to be true
  fails "Kernel#frozen? on a Symbol returns true" # Expected false to be true
  fails "Literal Regexps is frozen" # Expected /Hello/.frozen? to be truthy but was false
  fails "Marshal.load when called with freeze: true does not freeze classes" # ArgumentError: [Marshal.load] wrong number of arguments (given 2, expected 1)
  fails "Marshal.load when called with freeze: true does not freeze modules" # ArgumentError: [Marshal.load] wrong number of arguments (given 2, expected 1)
  fails "Marshal.load when called with freeze: true returns frozen arrays" # ArgumentError: [Marshal.load] wrong number of arguments (given 2, expected 1)
  fails "Marshal.load when called with freeze: true returns frozen hashes" # ArgumentError: [Marshal.load] wrong number of arguments (given 2, expected 1)
  fails "Marshal.load when called with freeze: true returns frozen objects" # ArgumentError: [Marshal.load] wrong number of arguments (given 2, expected 1)
  fails "Marshal.load when called with freeze: true returns frozen regexps" # ArgumentError: [Marshal.load] wrong number of arguments (given 2, expected 1)
  fails "Marshal.load when called with freeze: true returns frozen strings" # ArgumentError: [Marshal.load] wrong number of arguments (given 2, expected 1)
  fails "Marshal.load when called with freeze: true when called with a proc call the proc with frozen objects" # ArgumentError: [Marshal.load] wrong number of arguments (given 3, expected 1)
  fails "Marshal.load when called with freeze: true when called with a proc does not freeze the object returned by the proc" # ArgumentError: [Marshal.load] wrong number of arguments (given 3, expected 1)
  fails "MatchData#string returns a frozen copy of the match string" # Expected "THX1138.".frozen? to be truthy but was false
  fails "Module#name returns a frozen String" # Expected "ModuleSpecs".frozen? to be truthy but was false
  fails "NilClass#to_s returns a frozen string" # Expected "".frozen? to be truthy but was false
  fails "Proc#[] with frozen_string_literals doesn't duplicate frozen strings" # Expected false to be true
  fails "Regexp#initialize raises a FrozenError on a Regexp literal" # Expected FrozenError but no exception was raised (nil was returned)
  fails "String#-@ deduplicates frozen strings" # Expected "this string is frozen" not to be identical to "this string is frozen"
  fails "String#-@ returns a frozen copy if the String is not frozen" # Expected "foo".frozen? to be truthy but was false
  fails "String#initialize with an argument raises a FrozenError on a frozen instance that is modified" # Expected FrozenError but no exception was raised (nil was returned)
  fails "String#initialize with an argument raises a FrozenError on a frozen instance when self-replacing" # Expected FrozenError but no exception was raised (nil was returned)
  fails "String#next! raises a FrozenError if self is frozen" # Expected FrozenError but got: NotImplementedError (String#next! not supported. Mutable String methods are not supported in Opal.)
  fails "String#replace raises a FrozenError on a frozen instance that is modified" # Expected FrozenError but got: NoMethodError (undefined method `replace' for "hello")
  fails "String#replace raises a FrozenError on a frozen instance when self-replacing" # Expected FrozenError but got: NoMethodError (undefined method `replace' for "hello")
  fails "String#succ! raises a FrozenError if self is frozen" # Expected FrozenError but got: NotImplementedError (String#succ! not supported. Mutable String methods are not supported in Opal.)
  fails "Time#localtime on a frozen time does not raise an error if already in the right time zone" # NoMethodError: undefined method `localtime' for 2023-09-20 23:47:50 +0200
  fails "TrueClass#to_s returns a frozen string" # Expected "true".frozen? to be truthy but was false
end
