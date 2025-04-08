# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File#atime returns the last access time to self" # Errno::ENOENT: No such file or directory
  fails "File#chmod modifies the permission bits of the files specified" # Expected 0  == 33261  to be truthy but was false
  fails "File#chmod with '0111' makes file executable but not readable or writable" # Expected false  == true  to be truthy but was false
  fails "File#chmod with '0222' makes file writable but not readable or executable" # Expected false  == true  to be truthy but was false
  fails "File#chmod with '0444' makes file readable but not writable or executable" # Expected false  == true  to be truthy but was false
  fails "File#chmod with '0666' makes file readable and writable but not executable" # Expected false  == true  to be truthy but was false
  fails "File#ctime returns the change time for the named file (the time at which directory information about the file was changed, not the file itself)." # Errno::ENOENT: No such file or directory
  fails "File#initialize accepts encoding options as a hash parameter" # Errno::ENOENT: No such file or directory
  fails "File#initialize accepts encoding options in mode parameter" # Errno::ENOENT: No such file or directory
  fails "File#path calls to_str on argument and returns exact value" # Errno::ENOENT: No such file or directory
  fails "File#path does not absolute-ise the path it returns" # Errno::ENOENT: No such file or directory
  fails "File#path does not canonicalize the path it returns" # Errno::ENOENT: No such file or directory
  fails "File#path does not normalise the path it returns" # Errno::ENOENT: No such file or directory
  fails "File#path preserves the encoding of the path" # Errno::ENOENT: No such file or directory
  fails "File#path returns a String" # Errno::ENOENT: No such file or directory
  fails "File#reopen calls #to_path to convert an Object" # Errno::ENOENT: No such file or directory
  fails "File#reopen resets the stream to a new file path" # Errno::ENOENT: No such file or directory
  fails "File#size follows symlinks if necessary" # Errno::ENOENT: No such file or directory
  fails "File#size for an empty file returns 0" # Errno::ENOENT: No such file or directory
  fails "File#size is an instance method" # Errno::ENOENT: No such file or directory
  fails "File#size raises an IOError on a closed file" # Errno::ENOENT: No such file or directory
  fails "File#size returns the cached size of the file if subsequently deleted" # Errno::ENOENT: No such file or directory
  fails "File#size returns the file's current size even if modified" # Errno::ENOENT: No such file or directory
  fails "File#size returns the file's size as an Integer" # Errno::ENOENT: No such file or directory
  fails "File#size returns the file's size in bytes" # Errno::ENOENT: No such file or directory
  fails "File#to_path calls to_str on argument and returns exact value" # Errno::ENOENT: No such file or directory
  fails "File#to_path does not absolute-ise the path it returns" # Errno::ENOENT: No such file or directory
  fails "File#to_path does not canonicalize the path it returns" # Errno::ENOENT: No such file or directory
  fails "File#to_path does not normalise the path it returns" # Errno::ENOENT: No such file or directory
  fails "File#to_path preserves the encoding of the path" # Errno::ENOENT: No such file or directory
  fails "File#to_path returns a String" # Errno::ENOENT: No such file or directory
  fails "File#truncate truncates a file to a larger size than the original file" # Expected 10  == 12  to be truthy but was false
  fails "File.absolute_path? does not expand '~user' to a home directory." # Errno::ENOENT: No such file or directory
  fails "File.atime accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.atime raises an Errno::ENOENT exception if the file is not found" # Errno::ENOENT: No such file or directory
  fails "File.atime returns the last access time for the named file as a Time object" # Errno::ENOENT: No such file or directory
  fails "File.chmod accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.chmod invokes to_int on non-integer argument" # Errno::ENOENT: No such file or directory
  fails "File.chmod invokes to_str on non-string file names" # Errno::ENOENT: No such file or directory
  fails "File.chmod modifies the permission bits of the files specified" # Errno::ENOENT: No such file or directory
  fails "File.chmod raises RangeError with too large values" # Errno::ENOENT: No such file or directory
  fails "File.chmod raises an error for a non existent path" # Errno::ENOENT: No such file or directory
  fails "File.chmod returns the number of files modified" # Errno::ENOENT: No such file or directory
  fails "File.chmod throws a TypeError if the given path is not coercible into a string" # Errno::ENOENT: No such file or directory
  fails "File.chmod with '0111' makes file executable but not readable or writable" # Errno::ENOENT: No such file or directory
  fails "File.chmod with '0222' makes file writable but not readable or executable" # Errno::ENOENT: No such file or directory
  fails "File.chmod with '0444' makes file readable but not writable or executable" # Errno::ENOENT: No such file or directory
  fails "File.chmod with '0666' makes file readable and writable but not executable" # Errno::ENOENT: No such file or directory
  fails "File.chown accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.chown raises an error for a non existent path" # Errno::ENOENT: No such file or directory
  fails "File.chown returns the number of files processed" # Errno::ENOENT: No such file or directory
  fails "File.ctime accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.ctime returns the change time for the named file (the time at which directory information about the file was changed, not the file itself)." # Errno::ENOENT: No such file or directory
  fails "File.delete accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.delete coerces a given parameter into a string if possible" # Errno::ENOENT: No such file or directory
  fails "File.delete deletes a single file" # Errno::ENOENT: No such file or directory
  fails "File.delete deletes multiple files" # Errno::ENOENT: No such file or directory
  fails "File.delete raises a TypeError if not passed a String type" # Errno::ENOENT: No such file or directory
  fails "File.delete raises an Errno::ENOENT when the given file doesn't exist" # Errno::ENOENT: No such file or directory
  fails "File.delete returns 0 when called without arguments" # Errno::ENOENT: No such file or directory
  fails "File.directory? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.directory? raises a TypeError when passed an Integer" # Errno::ENOENT: No such file or directory
  fails "File.directory? raises a TypeError when passed nil" # Errno::ENOENT: No such file or directory
  fails "File.directory? returns false if the argument is not a directory" # Errno::ENOENT: No such file or directory
  fails "File.directory? returns true if the argument is a directory" # Errno::ENOENT: No such file or directory
  fails "File.directory? returns true if the argument is an IO that is a directory" # Errno::ENOENT: No such file or directory
  fails "File.empty? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.empty? raises a TypeError if not passed a String type" # Errno::ENOENT: No such file or directory
  fails "File.empty? raises an ArgumentError if not passed one argument" # Errno::ENOENT: No such file or directory
  fails "File.empty? returns false if the file does not exist" # Errno::ENOENT: No such file or directory
  fails "File.empty? returns false if the file is not empty" # Errno::ENOENT: No such file or directory
  fails "File.empty? returns true for /dev/null" # Errno::ENOENT: No such file or directory
  fails "File.empty? returns true if the file is empty" # Errno::ENOENT: No such file or directory
  fails "File.empty? returns true inside a block opening a file if it is empty" # Errno::ENOENT: No such file or directory
  fails "File.empty? returns true or false for a directory" # Errno::ENOENT: No such file or directory
  fails "File.executable? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.executable? raises a TypeError if not passed a String type" # Errno::ENOENT: No such file or directory
  fails "File.executable? raises an ArgumentError if not passed one argument" # Errno::ENOENT: No such file or directory
  fails "File.executable? returns false if the file does not exist" # Errno::ENOENT: No such file or directory
  fails "File.executable? returns true if named file is executable by the effective user id of the process, otherwise false" # Errno::ENOENT: No such file or directory
  fails "File.executable? returns true if the argument is an executable file" # Errno::ENOENT: No such file or directory
  fails "File.executable_real? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.executable_real? raises a TypeError if not passed a String type" # Errno::ENOENT: No such file or directory
  fails "File.executable_real? raises an ArgumentError if not passed one argument" # Errno::ENOENT: No such file or directory
  fails "File.executable_real? returns false if the file does not exist" # Errno::ENOENT: No such file or directory
  fails "File.executable_real? returns true if the file its an executable" # Errno::ENOENT: No such file or directory
  fails "File.exist? accepts an object that has a #to_path method" # Expected false  == true  to be truthy but was false
  fails "File.exist? returns true if the file exist" # Expected false  == true  to be truthy but was false
  fails "File.expand_path does not modify the string argument" # Expected "/a/c" == "//a/c" to be truthy but was false
  fails "File.expand_path expands a path with multi-byte characters" # Expected "/Ångström" == "//Ångström" to be truthy but was false
  fails "File.expand_path returns a String when passed a String subclass" # Expected "/a/c" == "//a/c" to be truthy but was false
  fails "File.file? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.file? raises a TypeError if not passed a String type" # Errno::ENOENT: No such file or directory
  fails "File.file? raises an ArgumentError if not passed one argument" # Errno::ENOENT: No such file or directory
  fails "File.file? returns true if the named file exists and is a regular file." # Errno::ENOENT: No such file or directory
  fails "File.file? returns true if the null device exists and is a regular file." # Errno::ENOENT: No such file or directory
  fails "File.ftype returns 'directory' when the file is a dir" # Errno::ENOENT: No such file or directory
  fails "File.ftype returns 'file' when the file is a file" # Errno::ENOENT: No such file or directory
  fails "File.ftype returns 'link' when the file is a link" # Errno::ENOENT: No such file or directory
  fails "File.ftype returns a String" # Errno::ENOENT: No such file or directory
  fails "File.ftype returns fifo when the file is a fifo" # NoMethodError: undefined method `~' for nil
  fails "File.ftype uses to_path to convert arguments" # Errno::ENOENT: No such file or directory
  fails "File.grpowned? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.grpowned? returns false if file the does not exist" # Errno::ENOENT: No such file or directory
  fails "File.grpowned? returns true if the file exist" # Errno::ENOENT: No such file or directory
  fails "File.grpowned? takes non primary groups into account" # Errno::ENOENT: No such file or directory
  fails "File.identical? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.identical? raises a TypeError if not passed String types" # Errno::ENOENT: No such file or directory
  fails "File.identical? raises an ArgumentError if not passed two arguments" # Errno::ENOENT: No such file or directory
  fails "File.identical? returns false if any of the files doesn't exist" # Errno::ENOENT: No such file or directory
  fails "File.identical? returns true for a file and its link" # Errno::ENOENT: No such file or directory
  fails "File.identical? returns true if both named files are identical" # Errno::ENOENT: No such file or directory
  fails "File.link link a file with another" # Errno::ENOENT: No such file or directory
  fails "File.link raises a TypeError if not passed String types" # Errno::ENOENT: No such file or directory
  fails "File.link raises an ArgumentError if not passed two arguments" # Errno::ENOENT: No such file or directory
  fails "File.link raises an Errno::EEXIST if the target already exists" # Errno::ENOENT: No such file or directory
  fails "File.lstat accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.lstat raises an Errno::ENOENT if the file does not exist" # Errno::ENOENT: No such file or directory
  fails "File.lstat returns a File::Stat object if the given file exists" # Errno::ENOENT: No such file or directory
  fails "File.lstat returns a File::Stat object when called on an instance of File" # Errno::ENOENT: No such file or directory
  fails "File.lstat returns a File::Stat object with symlink properties for a symlink" # Errno::ENOENT: No such file or directory
  fails "File.lutime sets the access and modification time for a regular file" # Errno::ENOENT: No such file or directory
  fails "File.lutime sets the access and modification time for a symlink" # Errno::ENOENT: No such file or directory
  fails "File.mkfifo creates a FIFO file at the passed path" # NoMethodError: undefined method `~' for nil
  fails "File.mkfifo creates a FIFO file with a default mode of 0666 & ~umask" # NoMethodError: undefined method `~' for nil
  fails "File.mkfifo returns 0 after creating the FIFO file" # NoMethodError: undefined method `~' for nil
  fails "File.mkfifo when path does not exist raises an Errno::ENOENT exception" # Expected Errno::ENOENT but got: NoMethodError (undefined method `~' for nil)
  fails "File.mkfifo when path passed responds to :to_path creates a FIFO file at the path specified" # NoMethodError: undefined method `~' for nil
  fails "File.mtime raises an Errno::ENOENT exception if the file is not found" # Errno::ENOENT: No such file or directory
  fails "File.mtime returns the modification Time of the file" # Errno::ENOENT: No such file or directory
  fails "File.new bitwise-ORs mode and flags option" # Errno::ENOENT: No such file or directory
  fails "File.new coerces filename using #to_path" # Errno::ENOENT: No such file or directory
  fails "File.new coerces filename using to_str" # Errno::ENOENT: No such file or directory
  fails "File.new creates a new file when use File::EXCL mode" # Errno::ENOENT: No such file or directory
  fails "File.new creates a new file when use File::WRONLY|File::APPEND mode" # Errno::ENOENT: No such file or directory
  fails "File.new creates a new file when use File::WRONLY|File::TRUNC mode" # Errno::ENOENT: No such file or directory
  fails "File.new creates the file and returns writable descriptor when called with 'w' mode and r-o permissions" # Errno::ENOENT: No such file or directory
  fails "File.new opens directories" # Errno::ENOENT: No such file or directory
  fails "File.new opens the existing file, does not change permissions even when they are specified" # Errno::ENOENT: No such file or directory
  fails "File.new raises a TypeError if the first parameter can't be coerced to a string" # Errno::ENOENT: No such file or directory
  fails "File.new raises a TypeError if the first parameter is nil" # Errno::ENOENT: No such file or directory
  fails "File.new raises an Errno::EBADF if the first parameter is an invalid file descriptor" # Errno::ENOENT: No such file or directory
  fails "File.new raises an Errorno::EEXIST if the file exists when create a new file with File::CREAT|File::EXCL" # Errno::ENOENT: No such file or directory
  fails "File.new returns a new File when use File::APPEND mode" # Errno::ENOENT: No such file or directory
  fails "File.new returns a new File when use File::RDONLY|File::APPEND mode" # Errno::ENOENT: No such file or directory
  fails "File.new returns a new File when use File::RDONLY|File::WRONLY mode" # Errno::ENOENT: No such file or directory
  fails "File.new returns a new File with mode num" # Errno::ENOENT: No such file or directory
  fails "File.new returns a new File with mode string" # Errno::ENOENT: No such file or directory
  fails "File.new returns a new File with modus fd" # Errno::ENOENT: No such file or directory
  fails "File.new returns a new File with modus num and permissions" # Errno::ENOENT: No such file or directory
  fails "File.new returns a new read-only File when mode is not specified but flags option is present" # Errno::ENOENT: No such file or directory
  fails "File.new returns a new read-only File when mode is not specified" # Errno::ENOENT: No such file or directory
  fails "File.new returns a new read-only File when use File::CREAT mode" # Errno::ENOENT: No such file or directory
  fails "File.new returns a new read-only File when use File::RDONLY|File::CREAT mode" # Errno::ENOENT: No such file or directory
  fails "File.open 'x' flag can't be used with 'r' and 'a' flags" # Errno::ENOENT: No such file or directory
  fails "File.open 'x' flag does nothing if the file doesn't exist" # Errno::ENOENT: No such file or directory
  fails "File.open 'x' flag throws a Errno::EEXIST error if the file exists" # Errno::ENOENT: No such file or directory
  fails "File.open accepts extra flags as a keyword argument and combine with a string mode" # Errno::ENOENT: No such file or directory
  fails "File.open accepts extra flags as a keyword argument and combine with an integer mode" # Errno::ENOENT: No such file or directory
  fails "File.open calls #to_hash to convert the second argument to a Hash" # Errno::ENOENT: No such file or directory
  fails "File.open can read and write in a block when call open with File::RDWR|File::EXCL mode" # Errno::ENOENT: No such file or directory
  fails "File.open can read and write in a block when call open with RDWR mode" # Errno::ENOENT: No such file or directory
  fails "File.open can read in a block when call open with 'r' mode" # Errno::ENOENT: No such file or directory
  fails "File.open can read in a block when call open with File::EXCL mode" # Errno::ENOENT: No such file or directory
  fails "File.open can read in a block when call open with RDONLY mode" # Errno::ENOENT: No such file or directory
  fails "File.open can write in a block when call open with 'w' mode" # Errno::ENOENT: No such file or directory
  fails "File.open can write in a block when call open with WRONLY mode" # Errno::ENOENT: No such file or directory
  fails "File.open can't read in a block when call open with File::EXCL mode" # Errno::ENOENT: No such file or directory
  fails "File.open can't read in a block when call open with File::TRUNC mode" # Errno::ENOENT: No such file or directory
  fails "File.open can't read in a block when call open with File::WRONLY||File::RDONLY mode" # Errno::ENOENT: No such file or directory
  fails "File.open can't write in a block when call open with File::TRUNC mode" # Errno::ENOENT: No such file or directory
  fails "File.open can't write in a block when call open with File::WRONLY||File::RDONLY mode" # Errno::ENOENT: No such file or directory
  fails "File.open creates a new file when use File::WRONLY|File::APPEND mode" # Errno::ENOENT: No such file or directory
  fails "File.open creates a new write-only file when invoked with 'w' and '0222'" # Errno::ENOENT: No such file or directory
  fails "File.open creates the file and returns writable descriptor when called with 'w' mode and r-o permissions" # Errno::ENOENT: No such file or directory
  fails "File.open defaults external_encoding to BINARY for binary modes" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file for binary read" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file for binary read-write and truncate the file" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file for binary read-write starting at the beginning of the file" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file for binary write" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file for read-write and truncate the file" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file that no exists when use 'a' mode" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file that no exists when use 'r' mode" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file that no exists when use 'w' mode" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file that no exists when use File::CREAT mode" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file that no exists when use File::EXCL mode" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file that no exists when use File::NOCTTY mode" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file that no exists when use File::NONBLOCK mode" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file that no exists when use File::RDONLY mode" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file that no exists when use File::TRUNC mode" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file that no exists when use File::WRONLY mode" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file when called with a block" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file when use File::WRONLY|File::APPEND mode" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file when use File::WRONLY|File::TRUNC mode" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file with mode and permission as nil" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file with mode num and block" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file with mode num" # Errno::ENOENT: No such file or directory
  fails "File.open opens a file with mode string and block" # Errno::ENOENT: No such file or directory
  fails "File.open opens directories" # Errno::EISDIR: Is a directory
  fails "File.open opens the existing file, does not change permissions even when they are specified" # Errno::ENOENT: No such file or directory
  fails "File.open opens the file (basic case)" # Errno::ENOENT: No such file or directory
  fails "File.open opens the file when call with fd" # Errno::ENOENT: No such file or directory
  fails "File.open opens the file when passed mode, num and permissions" # Errno::ENOENT: No such file or directory
  fails "File.open opens the file when passed mode, num, permissions and block" # Errno::ENOENT: No such file or directory
  fails "File.open opens the file with unicode characters" # Errno::ENOENT: No such file or directory
  fails "File.open opens with mode string" # Errno::ENOENT: No such file or directory
  fails "File.open raises ArgumentError if mixing :newline and binary mode" # Errno::ENOENT: No such file or directory
  fails "File.open raises a SystemCallError if passed an invalid Integer type" # Errno::ENOENT: No such file or directory
  fails "File.open raises a TypeError if passed a filename that is not a String or Integer type" # Errno::ENOENT: No such file or directory
  fails "File.open raises an ArgumentError exception when call with an unknown mode" # Errno::ENOENT: No such file or directory
  fails "File.open raises an ArgumentError if passed an invalid string for mode" # Errno::ENOENT: No such file or directory
  fails "File.open raises an Errno::EACCES when opening non-permitted file" # Errno::ENOENT: No such file or directory
  fails "File.open raises an Errno::EACCES when opening read-only file" # Errno::ENOENT: No such file or directory
  fails "File.open raises an Errorno::EEXIST if the file exists when open with File::CREAT|File::EXCL" # Errno::ENOENT: No such file or directory
  fails "File.open raises an Errorno::EEXIST if the file exists when open with File::RDONLY|File::TRUNC" # Errno::ENOENT: No such file or directory
  fails "File.open raises an IO exception when write in a block opened with 'r' mode" # Errno::ENOENT: No such file or directory
  fails "File.open raises an IO exception when write in a block opened with RDONLY mode" # Errno::ENOENT: No such file or directory
  fails "File.open raises an IOError if the file exists when open with File::RDONLY|File::APPEND" # Errno::ENOENT: No such file or directory
  fails "File.open raises an IOError when read in a block opened with 'a' mode" # Errno::ENOENT: No such file or directory
  fails "File.open raises an IOError when read in a block opened with 'w' mode" # Errno::ENOENT: No such file or directory
  fails "File.open raises an IOError when read in a block opened with File::WRONLY|File::APPEND mode" # Errno::ENOENT: No such file or directory
  fails "File.open raises an IOError when read in a block opened with WRONLY mode" # Errno::ENOENT: No such file or directory
  fails "File.open raises an IOError when write in a block opened with File::RDONLY|File::APPEND mode" # Errno::ENOENT: No such file or directory
  fails "File.open truncates the file when passed File::TRUNC mode" # Errno::ENOENT: No such file or directory
  fails "File.open uses the second argument as an options Hash" # Errno::ENOENT: No such file or directory
  fails "File.open with a block does not propagate IOError with 'closed stream' message produced by close" # Errno::ENOENT: No such file or directory
  fails "File.open with a block does not raise error when file is closed inside the block" # Errno::ENOENT: No such file or directory
  fails "File.open with a block invokes close on an opened file when exiting the block" # Errno::ENOENT: No such file or directory
  fails "File.open with a block propagates StandardErrors produced by close" # Errno::ENOENT: No such file or directory
  fails "File.open with a block propagates non-StandardErrors produced by close" # Errno::ENOENT: No such file or directory
  fails "File.owned? returns false if file does not exist" # Errno::ENOENT: No such file or directory
  fails "File.owned? returns false when the file is not owned by the user" # Errno::ENOENT: No such file or directory
  fails "File.owned? returns true if the file exist and is owned by the user" # Errno::ENOENT: No such file or directory
  fails "File.pipe? returns false if the file is not a pipe" # Errno::ENOENT: No such file or directory
  fails "File.pipe? returns true if the file is a pipe" # NoMethodError: undefined method `~' for nil
  fails "File.readable? accepts an object that has a #to_path method" # Expected false  == true  to be truthy but was false
  fails "File.readable? returns true if named file is readable by the effective user id of the process, otherwise false" # Expected false  == true  to be truthy but was false
  fails "File.readable_real? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.readable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.readlink when changing the working directory returns the name of the file referenced by the given link when the file does not exist" # Expected nil  == "readlink_file"  to be truthy but was false
  fails "File.readlink when changing the working directory returns the name of the file referenced by the given link" # Errno::ENOENT: No such file or directory
  fails "File.readlink with absolute paths raises an Errno::EINVAL if called with a normal file" # Errno::ENOENT: No such file or directory
  fails "File.readlink with absolute paths raises an Errno::ENOENT if there is no such file" # Expected Errno::ENOENT but no exception was raised (nil  was returned)
  fails "File.readlink with absolute paths returns the name of the file referenced by the given link when the file does not exist" # Expected nil  == "//tmp/rubyspec_temp/file_readlink.txt"  to be truthy but was false
  fails "File.readlink with absolute paths returns the name of the file referenced by the given link" # Errno::ENOENT: No such file or directory
  fails "File.readlink with paths containing unicode characters returns the name of the file referenced by the given link" # Errno::ENOENT: No such file or directory
  fails "File.realdirpath raises Errno::ENOENT if the directory is absent" # Errno::ENOENT: No such file or directory
  fails "File.realdirpath raises Errno::ENOENT if the symlink points to an absent directory" # Errno::ENOENT: No such file or directory
  fails "File.realdirpath raises an Errno::ELOOP if the symlink points to itself" # Errno::ENOENT: No such file or directory
  fails "File.realdirpath returns '/' when passed '/'" # Errno::ENOENT: No such file or directory
  fails "File.realdirpath returns the real (absolute) pathname if the file is absent" # Errno::ENOENT: No such file or directory
  fails "File.realdirpath returns the real (absolute) pathname if the symlink points to an absent file" # Errno::ENOENT: No such file or directory
  fails "File.realdirpath returns the real (absolute) pathname not containing symlinks" # Errno::ENOENT: No such file or directory
  fails "File.realdirpath uses base directory for interpreting relative pathname" # Errno::ENOENT: No such file or directory
  fails "File.realdirpath uses current directory for interpreting relative pathname" # Errno::ENOENT: No such file or directory
  fails "File.realdirpath uses link directory for expanding relative links" # Errno::ENOENT: No such file or directory
  fails "File.realpath converts the argument with #to_path" # Errno::ENOENT: No such file or directory
  fails "File.realpath raises Errno::ENOENT if the file is absent" # Errno::ENOENT: No such file or directory
  fails "File.realpath raises Errno::ENOENT if the symlink points to an absent file" # Errno::ENOENT: No such file or directory
  fails "File.realpath raises an Errno::ELOOP if the symlink points to itself" # Errno::ENOENT: No such file or directory
  fails "File.realpath removes the file element when going one level up" # Errno::ENOENT: No such file or directory
  fails "File.realpath returns '/' when passed '/'" # Errno::ENOENT: No such file or directory
  fails "File.realpath returns the real (absolute) pathname not containing symlinks" # Errno::ENOENT: No such file or directory
  fails "File.realpath uses base directory for interpreting relative pathname" # Errno::ENOENT: No such file or directory
  fails "File.realpath uses current directory for interpreting relative pathname" # Errno::ENOENT: No such file or directory
  fails "File.realpath uses link directory for expanding relative links" # Errno::ENOENT: No such file or directory
  fails "File.rename raises a TypeError if not passed String types" # Errno::ENOENT: No such file or directory
  fails "File.rename raises an ArgumentError if not passed two arguments" # Errno::ENOENT: No such file or directory
  fails "File.rename raises an Errno::ENOENT if the source does not exist" # Errno::ENOENT: No such file or directory
  fails "File.rename renames a file" # Errno::ENOENT: No such file or directory
  fails "File.setgid? returns false if the file does not exist" # Errno::ENOENT: No such file or directory
  fails "File.setgid? returns false if the file was just made" # Errno::ENOENT: No such file or directory
  fails "File.setuid? returns false if the file does not exist" # Errno::ENOENT: No such file or directory
  fails "File.setuid? returns false if the file was just made" # Errno::ENOENT: No such file or directory
  fails "File.setuid? returns true when the gid bit is set" # Errno::ENOENT: No such file or directory
  fails "File.size accepts a File argument" # Errno::ENOENT: No such file or directory
  fails "File.size accepts a String-like (to_str) parameter" # Errno::ENOENT: No such file or directory
  fails "File.size accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.size calls #to_io to convert the argument to an IO" # Errno::ENOENT: No such file or directory
  fails "File.size returns 0 if the file is empty" # Errno::ENOENT: No such file or directory
  fails "File.size returns the size of the file if it exists and is not empty" # Errno::ENOENT: No such file or directory
  fails "File.size? accepts a File argument" # Errno::ENOENT: No such file or directory
  fails "File.size? accepts a String-like (to_str) parameter" # Errno::ENOENT: No such file or directory
  fails "File.size? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.size? calls #to_io to convert the argument to an IO" # Errno::ENOENT: No such file or directory
  fails "File.size? returns nil if file_name is empty" # Errno::ENOENT: No such file or directory
  fails "File.size? returns the size of the file if it exists and is not empty" # Errno::ENOENT: No such file or directory
  fails "File.socket? returns false if the file is not a socket" # Errno::ENOENT: No such file or directory
  fails "File.stat accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.stat raises an Errno::ENOENT if the file does not exist" # Errno::ENOENT: No such file or directory
  fails "File.stat returns a File::Stat object if the given file exists" # Errno::ENOENT: No such file or directory
  fails "File.stat returns a File::Stat object when called on an instance of File" # Errno::ENOENT: No such file or directory
  fails "File.stat returns a File::Stat object with file properties for a symlink" # Errno::ENOENT: No such file or directory
  fails "File.stat returns an error when given missing non-ASCII path" # Errno::ENOENT: No such file or directory
  fails "File.stat returns information for a file that has been deleted but is still open" # Errno::ENOENT: No such file or directory
  fails "File.sticky? returns false if the file has not sticky bit set" # Errno::ENOENT: No such file or directory
  fails "File.sticky? returns true if the named file has the sticky bit, otherwise false" # Expected false == true to be truthy but was false
  fails "File.symlink accepts args that have #to_path methods" # Errno::ENOENT: No such file or directory
  fails "File.symlink creates a symbolic link" # Errno::ENOENT: No such file or directory
  fails "File.symlink creates a symlink between a source and target file" # Errno::ENOENT: No such file or directory
  fails "File.symlink raises a TypeError if not called with String types" # Errno::ENOENT: No such file or directory
  fails "File.symlink raises an ArgumentError if not called with two arguments" # Errno::ENOENT: No such file or directory
  fails "File.symlink raises an Errno::EEXIST if the target already exists" # Errno::ENOENT: No such file or directory
  fails "File.symlink? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.symlink? returns false if the file does not exist" # Errno::ENOENT: No such file or directory
  fails "File.symlink? returns true if the file is a link" # Errno::ENOENT: No such file or directory
  fails "File.truncate accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.truncate raises a TypeError if not passed a String type for the first argument" # Errno::ENOENT: No such file or directory
  fails "File.truncate raises a TypeError if not passed an Integer type for the second argument" # Errno::ENOENT: No such file or directory
  fails "File.truncate raises an ArgumentError if not passed two arguments" # Errno::ENOENT: No such file or directory
  fails "File.truncate raises an Errno::EINVAL if the length argument is not valid" # Errno::ENOENT: No such file or directory
  fails "File.truncate raises an Errno::ENOENT if the file does not exist" # Errno::ENOENT: No such file or directory
  fails "File.truncate truncate a file size to 0" # Errno::ENOENT: No such file or directory
  fails "File.truncate truncate a file size to 5" # Errno::ENOENT: No such file or directory
  fails "File.truncate truncates a file" # Errno::ENOENT: No such file or directory
  fails "File.truncate truncates to a larger file size than the original file" # Errno::ENOENT: No such file or directory
  fails "File.truncate truncates to the same size as the original file" # Errno::ENOENT: No such file or directory
  fails "File.umask invokes to_int on non-integer argument" # Errno::ENOENT: No such file or directory
  fails "File.umask raises ArgumentError when more than one argument is provided" # Errno::ENOENT: No such file or directory
  fails "File.umask raises RangeError with too large values" # Errno::ENOENT: No such file or directory
  fails "File.umask returns an Integer" # Errno::ENOENT: No such file or directory
  fails "File.umask returns the current umask value for the process" # Errno::ENOENT: No such file or directory
  fails "File.unlink accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.unlink coerces a given parameter into a string if possible" # Errno::ENOENT: No such file or directory
  fails "File.unlink deletes a single file" # Errno::ENOENT: No such file or directory
  fails "File.unlink deletes multiple files" # Errno::ENOENT: No such file or directory
  fails "File.unlink raises a TypeError if not passed a String type" # Errno::ENOENT: No such file or directory
  fails "File.unlink raises an Errno::ENOENT when the given file doesn't exist" # Errno::ENOENT: No such file or directory
  fails "File.unlink returns 0 when called without arguments" # Errno::ENOENT: No such file or directory
  fails "File.utime accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.utime accepts numeric atime and mtime arguments" # Errno::ENOENT: No such file or directory
  fails "File.utime returns the number of filenames in the arguments" # Errno::ENOENT: No such file or directory
  fails "File.utime sets the access and modification time of each file" # Errno::ENOENT: No such file or directory
  fails "File.utime uses the current times if two nil values are passed" # Errno::ENOENT: No such file or directory
  fails "File.world_readable? coerces the argument with #to_path" # Errno::ENOENT: No such file or directory
  fails "File.world_readable? returns an Integer if the file is a directory and chmod 644" # Errno::ENOENT: No such file or directory
  fails "File.world_readable? returns an Integer if the file is chmod 644" # Errno::ENOENT: No such file or directory
  fails "File.world_readable? returns nil if the file does not exist" # Errno::ENOENT: No such file or directory
  fails "File.world_readable? returns nil if the file is chmod 000" # Errno::ENOENT: No such file or directory
  fails "File.world_readable? returns nil if the file is chmod 600" # Errno::ENOENT: No such file or directory
  fails "File.world_readable? returns nil if the file is chmod 700" # Errno::ENOENT: No such file or directory
  fails "File.world_writable? coerces the argument with #to_path" # Errno::ENOENT: No such file or directory
  fails "File.world_writable? returns an Integer if the file is a directory and chmod 777" # Errno::ENOENT: No such file or directory
  fails "File.world_writable? returns an Integer if the file is chmod 777" # Errno::ENOENT: No such file or directory
  fails "File.world_writable? returns nil if the file does not exist" # Errno::ENOENT: No such file or directory
  fails "File.world_writable? returns nil if the file is chmod 000" # Errno::ENOENT: No such file or directory
  fails "File.world_writable? returns nil if the file is chmod 600" # Errno::ENOENT: No such file or directory
  fails "File.world_writable? returns nil if the file is chmod 700" # Errno::ENOENT: No such file or directory
  fails "File.writable_real? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.writable_real? returns true if named file is writable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.zero? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.zero? raises a TypeError if not passed a String type" # Errno::ENOENT: No such file or directory
  fails "File.zero? raises an ArgumentError if not passed one argument" # Errno::ENOENT: No such file or directory
  fails "File.zero? returns false if the file does not exist" # Errno::ENOENT: No such file or directory
  fails "File.zero? returns false if the file is not empty" # Errno::ENOENT: No such file or directory
  fails "File.zero? returns true for /dev/null" # Errno::ENOENT: No such file or directory
  fails "File.zero? returns true if the file is empty" # Errno::ENOENT: No such file or directory
  fails "File.zero? returns true inside a block opening a file if it is empty" # Errno::ENOENT: No such file or directory
  fails "File.zero? returns true or false for a directory" # Errno::ENOENT: No such file or directory
  fails "File::Stat#<=> includes Comparable and #== shows mtime equality between two File::Stat objects" # Errno::ENOENT: No such file or directory
  fails "File::Stat#<=> is able to compare files by different modification times" # Errno::ENOENT: No such file or directory
  fails "File::Stat#<=> is able to compare files by the same modification times" # Errno::ENOENT: No such file or directory
  fails "File::Stat#atime returns the atime of a File::Stat object" # Errno::ENOENT: No such file or directory
  fails "File::Stat#blksize returns the blksize of a File::Stat object" # Errno::ENOENT: No such file or directory
  fails "File::Stat#blocks returns a non-negative integer" # Errno::ENOENT: No such file or directory
  fails "File::Stat#ctime returns the ctime of a File::Stat object" # Errno::ENOENT: No such file or directory
  fails "File::Stat#dev returns the number of the device on which the file exists" # Errno::ENOENT: No such file or directory
  fails "File::Stat#dev_major returns the major part of File::Stat#dev" # Errno::ENOENT: No such file or directory
  fails "File::Stat#dev_minor returns the minor part of File::Stat#dev" # Errno::ENOENT: No such file or directory
  fails "File::Stat#directory? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File::Stat#directory? raises a TypeError when passed an Integer" # Errno::ENOENT: No such file or directory
  fails "File::Stat#directory? raises a TypeError when passed nil" # Errno::ENOENT: No such file or directory
  fails "File::Stat#directory? returns false if the argument is not a directory" # Errno::ENOENT: No such file or directory
  fails "File::Stat#directory? returns true if the argument is a directory" # Errno::ENOENT: No such file or directory
  fails "File::Stat#executable? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File::Stat#executable? raises a TypeError if not passed a String type" # Errno::ENOENT: No such file or directory
  fails "File::Stat#executable? raises an ArgumentError if not passed one argument" # Errno::ENOENT: No such file or directory
  fails "File::Stat#executable? returns true if named file is executable by the effective user id of the process, otherwise false" # Errno::ENOENT: No such file or directory
  fails "File::Stat#executable? returns true if the argument is an executable file" # Errno::ENOENT: No such file or directory
  fails "File::Stat#executable_real? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File::Stat#executable_real? raises a TypeError if not passed a String type" # Errno::ENOENT: No such file or directory
  fails "File::Stat#executable_real? raises an ArgumentError if not passed one argument" # Errno::ENOENT: No such file or directory
  fails "File::Stat#executable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Errno::ENOENT: No such file or directory
  fails "File::Stat#executable_real? returns true if the file its an executable" # Errno::ENOENT: No such file or directory
  fails "File::Stat#file? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File::Stat#file? raises a TypeError if not passed a String type" # Errno::ENOENT: No such file or directory
  fails "File::Stat#file? raises an ArgumentError if not passed one argument" # Errno::ENOENT: No such file or directory
  fails "File::Stat#file? returns true if the named file exists and is a regular file." # Errno::ENOENT: No such file or directory
  fails "File::Stat#file? returns true if the null device exists and is a regular file." # Errno::ENOENT: No such file or directory
  fails "File::Stat#ftype returns 'directory' when the file is a dir" # Errno::ENOENT: No such file or directory
  fails "File::Stat#ftype returns 'file' when the file is a file" # Errno::ENOENT: No such file or directory
  fails "File::Stat#ftype returns 'link' when the file is a link" # Errno::ENOENT: No such file or directory
  fails "File::Stat#ftype returns a String" # Errno::ENOENT: No such file or directory
  fails "File::Stat#ftype returns fifo when the file is a fifo" # NoMethodError: undefined method `~' for nil
  fails "File::Stat#grpowned? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File::Stat#grpowned? returns true if the file exist" # Errno::ENOENT: No such file or directory
  fails "File::Stat#grpowned? takes non primary groups into account" # Errno::ENOENT: No such file or directory
  fails "File::Stat#initialize calls #to_path on non-String arguments" # Errno::ENOENT: No such file or directory
  fails "File::Stat#initialize creates a File::Stat object for the given file" # Errno::ENOENT: No such file or directory
  fails "File::Stat#initialize raises an exception if the file doesn't exist" # Errno::ENOENT: No such file or directory
  fails "File::Stat#ino returns the ino of a File::Stat object" # Errno::ENOENT: No such file or directory
  fails "File::Stat#mode returns the mode of a File::Stat object" # Errno::ENOENT: No such file or directory
  fails "File::Stat#mtime returns the mtime of a File::Stat object" # Errno::ENOENT: No such file or directory
  fails "File::Stat#nlink returns the number of links to a file" # Errno::ENOENT: No such file or directory
  fails "File::Stat#owned? returns false if the file is not owned by the user" # Errno::ENOENT: No such file or directory
  fails "File::Stat#pipe? returns false if the file is not a pipe" # Errno::ENOENT: No such file or directory
  fails "File::Stat#pipe? returns true if the file is a pipe" # NoMethodError: undefined method `~' for nil
  fails "File::Stat#rdev returns the number of the device this file represents which the file exists" # Errno::ENOENT: No such file or directory
  fails "File::Stat#rdev_major returns the major part of File::Stat#rdev" # Errno::ENOENT: No such file or directory
  fails "File::Stat#rdev_minor returns the minor part of File::Stat#rdev" # Errno::ENOENT: No such file or directory
  fails "File::Stat#readable? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File::Stat#readable? returns true if named file is readable by the effective user id of the process, otherwise false" # Errno::ENOENT: No such file or directory
  fails "File::Stat#readable_real? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File::Stat#readable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#sticky? returns true if the named file has the sticky bit, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#symlink? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File::Stat#symlink? returns true if the file is a link" # Errno::ENOENT: No such file or directory
  fails "File::Stat#writable? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File::Stat#writable? returns true if named file is writable by the effective user id of the process, otherwise false" # Errno::ENOENT: No such file or directory
  fails "File::Stat#writable_real? accepts an object that has a #to_path method" # Expected false  == true  to be truthy but was false
  fails "File::Stat#writable_real? returns true if named file is writable by the real user id of the process, otherwise false" # Expected false  == true  to be truthy but was false
  fails "File::Stat#zero? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File::Stat#zero? raises a TypeError if not passed a String type" # Errno::ENOENT: No such file or directory
  fails "File::Stat#zero? raises an ArgumentError if not passed one argument" # Errno::ENOENT: No such file or directory
  fails "File::Stat#zero? returns false if the file is not empty" # Errno::ENOENT: No such file or directory
  fails "File::Stat#zero? returns true for /dev/null" # Errno::ENOENT: No such file or directory
  fails "File::Stat#zero? returns true if the file is empty" # Errno::ENOENT: No such file or directory
  fails "File::Stat#zero? returns true inside a block opening a file if it is empty" # Errno::ENOENT: No such file or directory
  fails "File::Stat#zero? returns true or false for a directory" # Errno::ENOENT: No such file or directory
  fails "File::Stat.size accepts a String-like (to_str) parameter" # Errno::ENOENT: No such file or directory
  fails "File::Stat.size accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File::Stat.size returns 0 if the file is empty" # Errno::ENOENT: No such file or directory
  fails "File::Stat.size returns the size of the file if it exists and is not empty" # Errno::ENOENT: No such file or directory
  fails "File::Stat.size? accepts a String-like (to_str) parameter" # Errno::ENOENT: No such file or directory
  fails "File::Stat.size? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File::Stat.size? returns nil if file_name is empty" # Errno::ENOENT: No such file or directory
  fails "File::Stat.size? returns the size of the file if it exists and is not empty" # Errno::ENOENT: No such file or directory
  fails "File::Stat.world_readable? coerces the argument with #to_path" # Errno::ENOENT: No such file or directory
  fails "File::Stat.world_readable? returns an Integer if the file is a directory and chmod 644" # Errno::ENOENT: No such file or directory
  fails "File::Stat.world_readable? returns an Integer if the file is chmod 644" # Errno::ENOENT: No such file or directory
  fails "File::Stat.world_readable? returns nil if the file is chmod 000" # Errno::ENOENT: No such file or directory
  fails "File::Stat.world_readable? returns nil if the file is chmod 600" # Errno::ENOENT: No such file or directory
  fails "File::Stat.world_readable? returns nil if the file is chmod 700" # Errno::ENOENT: No such file or directory
  fails "File::Stat.world_writable? coerces the argument with #to_path" # Errno::ENOENT: No such file or directory
  fails "File::Stat.world_writable? returns an Integer if the file is a directory and chmod 777" # Errno::ENOENT: No such file or directory
  fails "File::Stat.world_writable? returns an Integer if the file is chmod 777" # Errno::ENOENT: No such file or directory
  fails "File::Stat.world_writable? returns nil if the file is chmod 000" # Errno::ENOENT: No such file or directory
  fails "File::Stat.world_writable? returns nil if the file is chmod 600" # Errno::ENOENT: No such file or directory
  fails "File::Stat.world_writable? returns nil if the file is chmod 700" # Errno::ENOENT: No such file or directory
end
