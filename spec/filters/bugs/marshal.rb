opal_filter "Marshal" do
  # Marshal.load
  fails "Marshal.load loads an array containing objects having _dump method, and with proc"
  fails "Marshal.load loads an array containing objects having marshal_dump method, and with proc"
  fails "Marshal.load assigns classes to nested subclasses of Array correctly"
  fails "Marshal.load loads subclasses of Array with overridden << and push correctly"
  fails "Marshal.load loads a _dump object"
  fails "Marshal.load loads a _dump object extended"
  fails "Marshal.load raises an ArgumentError with full constant name when the dumped constant is missing"
  fails "Marshal.load when called with a proc returns the value of the proc"
  fails "Marshal.load when called with a proc calls the proc for recursively visited data"
  fails "Marshal.load when called with a proc loads an Array with proc"
  fails "Marshal.load when called on objects with custom _dump methods does not set instance variables of an object with user-defined _dump/_load"
  fails "Marshal.load when called on objects with custom _dump methods that return an immediate value loads an array containing an instance of the object, followed by multiple instances of another object"
  fails "Marshal.load when called on objects with custom _dump methods that return an immediate value loads any structure with multiple references to the same object, followed by multiple instances of another object"
  fails "Marshal.load when called on objects with custom _dump methods that return an immediate value loads an array containing references to multiple instances of the object, followed by multiple instances of another object"
  fails "Marshal.load for an Array loads an extended Array object containing a user-marshaled object"
  fails "Marshal.load for a String loads a String subclass with custom constructor"
  fails "Marshal.load for a Struct loads a extended_struct having fields with same objects"
  fails "Marshal.load for a Struct does not call initialize on the unmarshaled struct"
  fails "Marshal.load for an Exception loads a marshalled exception with no message"
  fails "Marshal.load for an Exception loads a marshalled exception with a message"
  fails "Marshal.load for an Exception loads a marshalled exception with a backtrace"
  fails "Marshal.load for a user Class raises ArgumentError if the object from an 'o' stream is not dumpable as 'o' type user class"
  fails "Marshal.load for a user Class loads an object having ivar"
  fails "Marshal.load for a user Class that extends a core type other than Object or BasicObject raises ArgumentError if the resulting class does not extend the same type"
  fails "Marshal.load for a Regexp loads a extended_user_regexp having ivar"
  fails "Marshal.load for a Hash loads an extended_user_hash with a parameter to initialize"
  fails "Marshal.load for a Rational loads"
  fails "Marshal.load for a Complex loads"
  fails "Marshal.load for a Time loads"
  fails "Marshal.load for a Time loads serialized instance variables"
  fails "Marshal.load for a Time loads Time objects stored as links"
  fails "Marshal.load for a Time loads nanoseconds"
  fails "Marshal.load for a Module loads an old module"
  fails "Marshal.load when a class does not exist in the namespace raises an ArgumentError" # an issue with constant resolving, e.g. String::Array

  # Marshal.dump
  fails "Marshal.dump dumps an object that has had an ivar added and removed as though the ivar never was set" # depends on Kernel#remove_instance_variable
  fails "Marshal.dump with an Object dumps an Object that has had an instance variable added and removed as though it was never set" # depends on Kernel#remove_instance_variable
  fails "Marshal.dump ignores the recursion limit if the limit is negative" # no support yet
  fails "Marshal.dump with an object responding to #_dump dumps the object returned by #marshal_dump"
  fails "Marshal.dump with a Time dumps the zone and the offset"
  fails "Marshal.dump with a Time dumps the zone and the offset"
  fails "Marshal.dump with a Regexp dumps a Regexp with instance variables" # //.source.should == ''
  fails "Marshal.dump with a Regexp dumps a Regexp subclass" # requires Class.new(Regexp).new("").class != Regexp
  fails "Marshal.dump with a Hash dumps an Hash subclass with a parameter to initialize"
  fails "Marshal.dump with an Object dumps a BasicObject subclass if it defines respond_to?"
  fails "Marshal.dump with a Time dumps the zone, but not the offset if zone is UTC"
  fails "Marshal.dump with an Exception dumps an empty Exception"
  fails "Marshal.dump with an Exception dumps the message for the exception"
  fails "Marshal.dump with an Exception contains the filename in the backtrace"
end
