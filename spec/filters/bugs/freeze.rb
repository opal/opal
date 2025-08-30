# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "freezing" do
  fails "Marshal.load when called with freeze: true does not freeze classes" # ArgumentError: [Marshal.load] wrong number of arguments (given 2, expected 1)
  fails "Marshal.load when called with freeze: true does not freeze modules" # ArgumentError: [Marshal.load] wrong number of arguments (given 2, expected 1)
  fails "Marshal.load when called with freeze: true returns frozen arrays" # ArgumentError: [Marshal.load] wrong number of arguments (given 2, expected 1)
  fails "Marshal.load when called with freeze: true returns frozen hashes" # ArgumentError: [Marshal.load] wrong number of arguments (given 2, expected 1)
  fails "Marshal.load when called with freeze: true returns frozen objects" # ArgumentError: [Marshal.load] wrong number of arguments (given 2, expected 1)
  fails "Marshal.load when called with freeze: true returns frozen regexps" # ArgumentError: [Marshal.load] wrong number of arguments (given 2, expected 1)
  fails "Marshal.load when called with freeze: true returns frozen strings" # ArgumentError: [Marshal.load] wrong number of arguments (given 2, expected 1)
  fails "Marshal.load when called with freeze: true when called with a proc call the proc with frozen objects" # ArgumentError: [Marshal.load] wrong number of arguments (given 3, expected 1)
  fails "Marshal.load when called with freeze: true when called with a proc does not freeze the object returned by the proc" # ArgumentError: [Marshal.load] wrong number of arguments (given 3, expected 1)
  fails "String#-@ deduplicates frozen strings" # Expected "this string is frozen" not to be identical to "this string is frozen"
  fails "String#-@ returns a frozen copy if the String is not frozen" # Expected "foo".frozen? to be truthy but was false
  fails "String#<< raises a FrozenError when self is frozen" # Expected FrozenError but got: NotImplementedError (String#<< not supported. Mutable String methods are not supported in Opal.)
  fails "String#<< with Integer raises a FrozenError when self is frozen" # Expected FrozenError but got: NotImplementedError (String#<< not supported. Mutable String methods are not supported in Opal.)
  fails "String#concat raises a FrozenError when self is frozen" # Expected FrozenError but got: NoMethodError (undefined method `concat' for "hello")
  fails "String#concat with Integer raises a FrozenError when self is frozen" # Expected FrozenError but got: NoMethodError (undefined method `concat' for "hello")
  fails "String#initialize with an argument raises a FrozenError on a frozen instance that is modified" # Expected FrozenError but no exception was raised (nil was returned)
  fails "String#initialize with an argument raises a FrozenError on a frozen instance when self-replacing" # Expected FrozenError but no exception was raised (nil was returned)
  fails "String#next! raises a FrozenError if self is frozen" # Expected FrozenError but got: NotImplementedError (String#next! not supported. Mutable String methods are not supported in Opal.)
  fails "String#replace raises a FrozenError on a frozen instance that is modified" # Expected FrozenError but got: NoMethodError (undefined method `replace' for "hello")
  fails "String#replace raises a FrozenError on a frozen instance when self-replacing" # Expected FrozenError but got: NoMethodError (undefined method `replace' for "hello")
  fails "String#succ! raises a FrozenError if self is frozen" # Expected FrozenError but got: NotImplementedError (String#succ! not supported. Mutable String methods are not supported in Opal.)
end
