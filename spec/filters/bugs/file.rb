# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File#flock blocks if trying to lock an exclusively locked file" # NotImplementedError: File#flock is not available on nodejs and compatible platforms
  fails "File#flock exclusively locks a file" # NotImplementedError: File#flock is not available on nodejs and compatible platforms
  fails "File#flock non-exclusively locks a file" # NotImplementedError: File#flock is not available on nodejs and compatible platforms
  fails "File#flock returns 0 if trying to lock a non-exclusively locked file" # NotImplementedError: File#flock is not available on nodejs and compatible platforms
  fails "File#flock returns false if trying to lock an exclusively locked file" # NotImplementedError: File#flock is not available on nodejs and compatible platforms
  fails "File#path returns a different String on every call" # Expected "/home/jan/workspace/opal/tmp/rubyspec_temp/file_to_path".equal? "/home/jan/workspace/opal/tmp/rubyspec_temp/file_to_path" to be falsy but was true
  fails "File#path returns a mutable String" # NotImplementedError: String#<< not supported. Mutable String methods are currently not supported in Opal.
  fails "File#printf integer formats d works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "File#printf integer formats i works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "File#printf integer formats u works well with large numbers" # Expected "1234567890987654400" == "1234567890987654321" to be truthy but was false
  fails "File#printf other formats c raises TypeError if argument is nil" # Expected TypeError (no implicit conversion from nil to integer) but got: TypeError (no implicit conversion of NilClass into Integer)
  fails "File#printf other formats c raises TypeError if converting to Integer with to_int returns non-Integer" # Expected TypeError (can't convert BasicObject to Integer) but got: TypeError (no implicit conversion of BasicObject into Integer)
  fails "File#printf other formats c raises TypeError if converting to String with to_str returns non-String" # Expected TypeError (can't convert BasicObject to String) but no exception was raised ("f" was returned)
  fails "File#to_path returns a different String on every call" # Expected "/home/jan/workspace/opal/tmp/rubyspec_temp/file_to_path".equal? "/home/jan/workspace/opal/tmp/rubyspec_temp/file_to_path" to be falsy but was true
  fails "File#to_path returns a mutable String" # NotImplementedError: String#<< not supported. Mutable String methods are currently not supported in Opal.
  fails "File.absolute_path accepts a second argument of a directory from which to resolve the path" # Expected "./ruby/core/file/ruby/core/file/absolute_path_spec.rb" == "/home/jan/workspace/opal/spec/ruby/core/file/absolute_path_spec.rb" to be truthy but was false
  fails "File.absolute_path does not expand '~user' to a home directory." # Expected "./ruby/core/file/~user" == "ruby/core/file/~user" to be truthy but was false
  fails "File.absolute_path resolves paths relative to the current working directory" # Expected "./ruby/core/file/hello.txt" == "ruby/core/file/hello.txt" to be truthy but was false
  fails "File.absolute_path? calls #to_path on its argument" # Mock 'path' expected to receive to_path("any_args") exactly 1 times but received it 0 times
  fails "File.basename returns a new unfrozen String" # Expected "foo.rb" not to be identical to "foo.rb"
  fails "File.directory? calls #to_io to convert a non-IO object" # TypeError: no implicit conversion of MockObject into String
  fails "File.directory? returns false if the argument is an IO that's not a directory" # TypeError: no implicit conversion of NilClass into String
  fails "File.dirname when level is passed calls #to_int if passed not numeric value" # NoMethodError: undefined method `<' for #<Object:0x56914>
  fails "File.dirname when level is passed raises ArgumentError if the level is negative" # Expected ArgumentError (negative level: -1) but got: ArgumentError (level can't be negative)
  fails "File.empty? returns true for NUL" # Expected false == true to be truthy but was false
  fails "File.executable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.expand_path accepts objects that have a #to_path method" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path converts a pathname to an absolute pathname" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path converts a pathname to an absolute pathname, Ruby-Talk:18512" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path converts a pathname to an absolute pathname, using a complete path" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path does not expand ~ENV['USER'] when it's not at the start" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path does not modify a HOME string argument" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path does not modify the string argument" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path does not replace multiple '/' at the beginning of the path" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path expand path with" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path expand_path for common unix path gives a full path" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path expands ../foo with ~/dir as base dir to /path/to/user/home/foo" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path expands /./dir to /dir" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path expands a path when the default external encoding is BINARY" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path expands a path with multi-byte characters" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path expands ~ENV['USER'] to the user's home directory" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path expands ~ENV['USER']/a to a in the user's home directory" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path keeps trailing dots on absolute pathname" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path raises a TypeError if not passed a String type" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path raises an ArgumentError if the path is not valid" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path raises an Encoding::CompatibilityError if the external encoding is not compatible" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path replaces multiple '/' with a single '/'" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path returns a String in the same encoding as the argument" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path returns a String when passed a String subclass" # ArgumentError: [Dir.home] wrong number of arguments (given 1, expected 0)
  fails "File.expand_path when HOME is not set raises an ArgumentError when passed '~' if HOME == ''" # Expected ArgumentError but no exception was raised ("/" was returned)
  fails "File.expand_path with a non-absolute HOME raises an ArgumentError" # Expected ArgumentError (non-absolute home) but no exception was raised ("non-absolute" was returned)
  fails "File.extname for a filename ending with a dot returns '.'" # Expected "" == "." to be truthy but was false
  fails "File.ftype returns 'characterSpecial' when the file is a char" # RuntimeError: Could not find a character device
  fails "File.ftype returns 'socket' when the file is a socket" # NameError: uninitialized constant SocketSpecs::Socket
  fails "File.identical? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.identical? returns true for a file and its link" # Expected false == true to be truthy but was false
  fails "File.join inserts the separator in between empty strings and arrays" # Expected "" == "/" to be truthy but was false
  fails "File.join respects the given separator if only one part has a boundary separator" # Expected "usr/bin" == "usr//bin" to be truthy but was false
  fails "File.join returns a duplicate string when given a single argument" # Expected "usr" not to be identical to "usr"
  fails "File.lchmod changes the file mode of the link and not of the file" # NotImplementedError: File#lchmod is not available on nodejs and compatible platforms
  fails "File.mkfifo when path passed is not a String value raises a TypeError" # Expected TypeError but got: Errno::ENOENT (No such file or directory - No such file or directory /tmp/fifo)
  fails "File.new accepts options as a keyword argument" # Expected ArgumentError (wrong number of arguments (given 4, expected 1..3)) but no exception was raised (<File:fd 3> was returned)
  fails "File.new can't alter mode or permissions when opening a file" # Expected Errno::EINVAL but no exception was raised (false was returned)
  fails "File.open accepts options as a keyword argument" # Expected ArgumentError (wrong number of arguments (given 4, expected 1..3)) but no exception was raised (<File:fd 37> was returned)
  fails "File.open on a FIFO opens it as a normal file" # NotImplementedError: Thread creation not available
  fails "File.open raises an ArgumentError if passed the wrong number of arguments" # Expected ArgumentError but no exception was raised (<File:fd 35> was returned)
  fails "File.readable? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.readable? returns true if named file is readable by the effective user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.socket? returns true if the file is a socket" # NameError: uninitialized constant UNIXServer
  fails "File.utime may set nanosecond precision" # NoMethodError: undefined method `nsec' for 2007-11-01 16:25:00 +0100
  fails "File.writable? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.writable? returns true if named file is writable by the effective user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.writable_real? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.writable_real? returns true if named file is writable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.zero? returns true for NUL" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, stat 'C:\Users\jan\workspace\opal\spec\NUL'
  fails "File::Stat#birthtime raises an NotImplementedError" # Expected NotImplementedError but no exception was raised (2025-02-13 00:39:45 +0100 was returned)
  fails "File::Stat#blksize returns nil" # Expected 4096 == nil to be truthy but was false
  fails "File::Stat#blocks returns nil" # Expected 0 to be nil
  fails "File::Stat#executable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#ftype returns 'characterSpecial' when the file is a char" # RuntimeError: Could not find a character device
  fails "File::Stat#ftype returns 'socket' when the file is a socket" # NameError: uninitialized constant SocketSpecs::Socket
  fails "File::Stat#gid returns the group owner attribute of a File::Stat object" # Expected 0 == -1 to be truthy but was false
  fails "File::Stat#inspect produces a nicely formatted description of a File::Stat object" # NotImplementedError: String#<< not supported. Mutable String methods are currently not supported in Opal.
  fails "File::Stat#mode returns the mode of a File::Stat object" # Expected 438 == 420 to be truthy but was false
  fails "File::Stat#owned? returns true if the file is owned by the user" # Expected #<File::Stat dev=0, ino=23925373021887260, mode=81b6, nlink=1, uid=0, gid=0, rdev=0, size=0, blksize=4096, blocks=0, atime=2025-02-05 05:42:51 +0100, mtime=2025-02-05 05:42:51 +0100, ctime=2025-02-05 05:42:51 +0100, birthtime=2025-02-05 05:42:51 +0100.owned? to be truthy but was false
  fails "File::Stat#uid returns the owner attribute of a File::Stat object" # Expected 0 == -1 to be truthy but was false
  fails "File::Stat#zero? returns true for NUL" # Errno::ENOENT: No such file or directory - ENOENT: no such file or directory, lstat 'C:\Users\jan\workspace\opal\spec\NUL'
end
