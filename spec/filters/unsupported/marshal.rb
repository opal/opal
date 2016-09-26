opal_unsupported_filter "Marshal" do
  # Marshal.load
  fails "Marshal.load loads a Random" # depends on the reading from the filesystem
  fails "Marshal.load when source is tainted returns a tainted object"
  fails "Marshal.load when source is tainted does not taint Symbols"
  fails "Marshal.load when source is tainted does not taint Fixnums"
  fails "Marshal.load when source is tainted does not taint Floats"
  fails "Marshal.load when source is tainted does not taint Bignums"
  fails "Marshal.load returns an untainted object if source is untainted"
  fails "Marshal.load preserves taintedness of nested structure"
  fails "Marshal.load returns a trusted object if source is trusted"
  fails "Marshal.load returns an untrusted object if source is untrusted"
  fails "Marshal.load for a String loads a string through StringIO stream"
  fails "Marshal.load raises EOFError on loading an empty file"
  fails "Marshal.load for a String loads a string with an ivar" # depends on string mutation
  fails "Marshal.load for a String loads a string having ivar with ref to self" # depends on string mutation
  fails "Marshal.load for a wrapped C pointer loads"
  fails "Marshal.load for a wrapped C pointer raises TypeError when the local class is missing _load_data"
  fails "Marshal.load for a wrapped C pointer raises ArgumentError when the local class is a regular object"
  fails "Marshal.load for an Array loads an array having ivar" # for some reason depends on String#instance_variable_set which is not supported. replaced with test in spec/opal
  fails "Marshal.load raises a TypeError with bad Marshal version" # depends on String#[]=
  fails "Marshal.load for a Hash preserves hash ivars when hash contains a string having ivar" # depends on String#instance_variable_set

  # Marshal.dump
  fails "Marshal.dump returns a tainted string if object is tainted"
  fails "Marshal.dump returns a tainted string if nested object is tainted"
  fails "Marshal.dump returns a trusted string if object is trusted"
  fails "Marshal.dump returns an untrusted string if object is untrusted"
  fails "Marshal.dump returns an untrusted string if nested object is untrusted"
  fails "Marshal.dump returns an untainted string if object is untainted"
  fails "Marshal.dump when passed an IO writes the serialized data to the IO-Object"
  fails "Marshal.dump when passed an IO returns the IO-Object"
  fails "Marshal.dump when passed an IO raises an Error when the IO-Object does not respond to #write"
  fails "Marshal.dump raises a TypeError if dumping a IO/File instance"
  fails "Marshal.dump with a Regexp dumps a Regexp" # depends on utf-8 encoding which is not required, replaced with test in spec/opal
  fails "Marshal.dump with a String dumps a String with instance variables"  # depends on string mutation
  fails "Marshal.dump with a Float dumps a Float" # depends on the string mutating, replaced with test in spec/opal
  fails "Marshal.dump with a Regexp dumps a Regexp with flags" # depends on string encoding, replaced with test in spec/opal
  fails "Marshal.dump with a Regexp dumps an extended Regexp" # depends on string encoding, replaced with test in spec/opal
  fails "Marshal.dump with a String dumps a String extended with a Module" # depends on string mutation
  fails "Marshal.dump dumps subsequent appearances of a symbol as a link" # depends on Symbol-s
  fails "Marshal.dump with an object responding to #marshal_dump dumps the object returned by #marshal_dump" # depends on Symbol-s, replaced with test in spec/opal
  fails "Marshal.dump with a Regexp dumps a binary Regexp"
  fails "Marshal.dump with a Regexp dumps a UTF-8 Regexp"
  fails "Marshal.dump with a Regexp dumps a Regexp in another encoding"
end
