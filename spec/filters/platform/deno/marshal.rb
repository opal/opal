# NOTE: run bin/format-filters after changing this file
opal_filter "Marshal" do
  fails "Marshal.dump String big returns a binary string" # Exception: Cannot create property '$$meta' on string 'bigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbig'
  fails "Marshal.dump Symbol big returns a binary string" # Exception: Cannot create property '$$meta' on string 'bigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbigbig'
  fails "Marshal.dump Symbol returns a binary string" # Exception: Cannot create property '$$meta' on string 'symbol'
  fails "Marshal.dump Symbol small returns a binary string" # Exception: Cannot create property '$$meta' on string 'big'
  fails "Marshal.dump _dump object extended returns a binary string" # Exception: Cannot create property '$$meta' on string 'stuff'
  fails "Marshal.dump _dump object returns a binary string" # Exception: Cannot create property '$$meta' on string 'stuff'
  fails "Marshal.dump marshal_dump object returns a binary string" # Exception: Cannot create property '$$meta' on string 'data'
  fails "Marshal.dump with a String dumps a long String" # FrozenError: can't modify frozen String
  fails "Marshal.dump with an object responding to #marshal_dump does not use Class#name" # Exception: Cannot create property '$$meta' on string 'data'
  fails "Marshal.load for a Hash allocates an instance of the proper class when Hash subclass with compare_by_identity behaviour" # Exception: Cannot create property '$$meta' on string 'a'
  fails "Marshal.load loads a String extended" # Exception: Cannot create property '$$meta' on string ''
  fails "Marshal.load raises an ArgumentError when the dumped data is truncated" # Expected ArgumentError (marshal data too short) but got: Exception (Cannot create property '$$meta' on string 'first')
  fails "SimpleDelegator can be marshalled with its instance variables intact" # Exception: Cannot create property '$$meta' on string '__v2__'
end
