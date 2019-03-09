opal_filter "StrictMode" do
  fails " " # Exception: Cannot create property 'foo' on string 'stuff'
  fails " " # NameError: uninitialized constant MarshalSpec::DATA
  fails "Kernel#is_a? returns true if given a Module that is included in object's class" # Expected false to equal true
  fails "Kernel#is_a? returns true if given a Module that is included one of object's ancestors only" # Expected false to equal true
  fails "Kernel#is_a? returns true if given a Module that object has been prepended with" # Expected false to equal true
  fails "Kernel#is_a? returns true if given class is an ancestor of the object's class" # Expected false to equal true
  fails "Kernel#kind_of? returns true if given a Module that is included in object's class" # Expected false to equal true
  fails "Kernel#kind_of? returns true if given a Module that is included one of object's ancestors only" # Expected false to equal true
  fails "Kernel#kind_of? returns true if given a Module that object has been prepended with" # Expected false to equal true
  fails "Kernel#kind_of? returns true if given class is an ancestor of the object's class" # Expected false to equal true
  fails "Kernel#public_methods returns public methods for immediates" # Exception: Object.defineProperty called on non-object
  fails "Marshal.load assigns classes to nested subclasses of Array correctly" # NameError: uninitialized constant ArraySub
  fails "Marshal.load loads subclasses of Array with overridden << and push correctly" # NameError: uninitialized constant ArraySubPush
  fails "Marshal.dump with a String dumps a String subclass" # Expected "\u0004\be:\nMethse:\u001EStringSpecs::StringModuleC:\u000FUserString\"\u0000" to equal "\u0004\bC:\u000FUserString\"\u0000"
  fails "Marshal.dump with a String dumps a String subclass extended with a Module" # Expected "\u0004\be:\nMethse:\u001EStringSpecs::StringModuleC:\u000FUserString\"\u0000" to equal "\u0004\be:\nMethsC:\u000FUserString\"\u0000"
  fails "Marshal.dump with a String dumps a blank String" # Expected "\u0004\be:\nMethse:\u001EStringSpecs::StringModule\"\u0000" to equal "\u0004\b\"\u0000"
  fails "Marshal.dump with a String dumps a long String" # Expected "\u0004\be:\nMethse:\u001EStringSpecs::StringModule\"\u0002,\u0001bigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbig" to equal "\u0004\b\"\u0002,\u0001bigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbig"
  fails "Marshal.dump with a String dumps a short String" # Expected "\u0004\be:\nMethse:\u001EStringSpecs::StringModule\"\nshort" to equal "\u0004\b\"\nshort"
end
