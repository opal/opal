# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Marshal" do
  fails "Marshal.dump dumps subsequent appearances of a symbol as a link" # Expected "\x04\b[\a\"\x06a@\x06" == "\x04\b[\a:\x06a;\x00" to be truthy but was false
  fails "Marshal.dump raises a TypeError if dumping a IO/File instance" # Expected TypeError but got: Exception (Maximum call stack size exceeded)
  fails "Marshal.dump when passed an IO raises an Error when the IO-Object does not respond to #write" # Expected TypeError but got: ArgumentError ([Marshal.dump] wrong number of arguments (given 2, expected 1))
  fails "Marshal.dump when passed an IO returns the IO-Object" # ArgumentError: [Marshal.dump] wrong number of arguments (given 2, expected 1)
  fails "Marshal.dump when passed an IO writes the serialized data to the IO-Object" # ArgumentError: [Marshal.dump] wrong number of arguments (given 2, expected 1)
  fails "Marshal.dump with a Float dumps a Float" # Expected "\x04\bf\x060" to be computed by Marshal.dump from 0 (computed "\x04\bi\x00" instead)
  fails "Marshal.dump with a Regexp dumps a Regexp in another encoding" # NameError: uninitialized constant Regexp::FIXEDENCODING
  fails "Marshal.dump with a Regexp dumps a Regexp with flags" # Expected "\x04\b/\t(?:)\x00" == "\x04\bI/\x00\x05\x06:\x06EF" to be truthy but was false
  fails "Marshal.dump with a Regexp dumps a Regexp" # Expected "\x04\b/\t^.\\Z\x00" ==  "\x04\bI/ \\A.\\Z\x00\x06:\x06EF" to be truthy but was false
  fails "Marshal.dump with a Regexp dumps a UTF-8 Regexp" # NameError: uninitialized constant Regexp::FIXEDENCODING
  fails "Marshal.dump with a Regexp dumps a binary Regexp" # NameError: uninitialized constant Regexp::FIXEDENCODING
  fails "Marshal.dump with a Regexp dumps an extended Regexp" # Expected  "\x04\be: Meths/\t(?:)\x00" ==  "\x04\bIe: Meths/\x00\x00\x06:\x06EF" to be truthy but was false
  fails "Marshal.dump with a String dumps a String with instance variables" # Expected "\x04\b\"\x00" == "\x04\bI\"\x00\x06:\t@foo\"\bbar" to be truthy but was false
  fails "Marshal.dump with an object responding to #marshal_dump dumps the object returned by #marshal_dump" # Expected "\x04\bU:\x10UserMarshal\"\tdata" == "\x04\bU:\x10UserMarshal:\tdata" to be truthy but was false
  fails "Marshal.load for a Hash preserves hash ivars when hash contains a string having ivar" # Expected nil == "string ivar" to be truthy but was false
  fails "Marshal.load for a String loads a string through StringIO stream" # TypeError: incompatible marshal file format (can't be read)
  fails "Marshal.load for a wrapped C pointer loads" # NotImplementedError: Data type cannot be demarshaled
  fails "Marshal.load for a wrapped C pointer raises ArgumentError when the local class is a regular object" # Expected ArgumentError but got: NotImplementedError (Data type cannot be demarshaled)
  fails "Marshal.load for a wrapped C pointer raises TypeError when the local class is missing _load_data" # Expected TypeError but got: NotImplementedError (Data type cannot be demarshaled)
  fails "Marshal.load loads a Random" # ArgumentError: marshal data too short
  fails "Marshal.load raises EOFError on loading an empty file" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x444da @method="load" @object=nil @num_self_class=1 @data="\x04\bo:\x1ANamespaceTest::KaBoom\x00">
  fails "Marshal.load raises a TypeError with bad Marshal version" # NotImplementedError: String#[]= not supported. Mutable String methods are not supported in Opal.
end
