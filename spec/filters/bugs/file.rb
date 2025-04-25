# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File#flock blocks if trying to lock an exclusively locked file" # NotImplementedError: NotImplementedError
  fails "File#flock exclusively locks a file" # Expected nil == 0 to be truthy but was false
  fails "File#flock non-exclusively locks a file" # Expected nil == 0 to be truthy but was false
  fails "File#flock returns 0 if trying to lock a non-exclusively locked file" # Expected nil == 0 to be truthy but was false
  fails "File#flock returns false if trying to lock an exclusively locked file" # NotImplementedError: NotImplementedError
  fails "File#path returns a different String on every call" # Expected "C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/file_to_path".equal? "C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/file_to_path" to be falsy but was true
  fails "File#path returns a mutable String" # NotImplementedError: String#<< not supported. Mutable String methods are currently not supported in Opal.
  fails "File#printf integer formats d works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "File#printf integer formats i works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "File#printf integer formats u works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "File#printf other formats c raises TypeError if argument is nil" # Expected TypeError (no implicit conversion from nil to integer) but got: TypeError (no implicit conversion of NilClass into Integer)
  fails "File#printf other formats c raises TypeError if converting to Integer with to_int returns non-Integer" # Expected TypeError (can't convert BasicObject to Integer) but got: TypeError (can't convert BasicObject into Integer (BasicObject#to_int gives String))
  fails "File#printf other formats c raises TypeError if converting to String with to_str returns non-String" # Expected TypeError (can't convert BasicObject to String) but no exception was raised ("f" was returned)
  fails "File#to_path returns a different String on every call" # Expected "C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/file_to_path".equal? "C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/file_to_path" to be falsy but was true
  fails "File#to_path returns a mutable String" # NotImplementedError: String#<< not supported. Mutable String methods are currently not supported in Opal.
  fails "File.absolute_path accepts a second argument of a directory from which to resolve the path" # Expected "C:/Users/Administrator/workspace/opal/spec/ruby/core/file/ruby/core/file/absolute_path_spec.rb" == "C:/Users/Administrator/workspace/opal/spec/ruby/core/file/absolute_path_spec.rb" to be truthy but was false
  fails "File.basename returns a new unfrozen String" # Expected "foo.rb" not to be identical to "foo.rb"
  fails "File.empty? returns true for NUL" # Expected false == true to be truthy but was false
  fails "File.join inserts the separator in between empty strings and arrays" # Expected "" == "/" to be truthy but was false
  fails "File.join respects the given separator if only one part has a boundary separator" # Expected "usr/bin" == "usr//bin" to be truthy but was false
  fails "File.join returns a duplicate string when given a single argument" # Expected "usr" not to be identical to "usr"
  fails "File.new accepts options as a keyword argument" # Expected ArgumentError (wrong number of arguments (given 4, expected 1..3)) but no exception was raised (<File:fd 14> was returned)
  fails "File.open accepts options as a keyword argument" # Expected ArgumentError (wrong number of arguments (given 4, expected 1..3)) but no exception was raised (<File:fd 8> was returned)
  fails "File.open raises an ArgumentError if passed the wrong number of arguments" # Expected ArgumentError but no exception was raised (<File:fd 6> was returned)
  fails "File.zero? returns true for NUL" # Expected false == true to be truthy but was false
  fails "File::Stat#blksize returns nil" # Expected 4096 == nil to be truthy but was false
  fails "File::Stat#blocks returns nil" # Expected 0 to be nil
  fails "File::Stat#inspect produces a nicely formatted description of a File::Stat object" # NotImplementedError: String#<< not supported. Mutable String methods are currently not supported in Opal.
  fails "File::Stat#zero? returns true for NUL" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, lstat 'C:\Users\Administrator\workspace\opal\spec\NUL'
end
