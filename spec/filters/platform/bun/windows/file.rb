# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File#chmod with '0444' makes file readable and executable but not writable" # Expected false == true to be truthy but was false
  fails "File#chmod with '0644' makes file readable and writable and also executable" # Expected false == true to be truthy but was false
  fails "File.chmod with '0444' makes file readable and executable but not writable" # Expected false == true to be truthy but was false
  fails "File.chmod with '0644' makes file readable and writable and also executable" # Expected false == true to be truthy but was false
  fails "File.executable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.expand_path converts a pathname to an absolute pathname" # Expected "C:/Users/Administrator/workspace/opal/spec" == nil to be truthy but was false
  fails "File.expand_path converts a pathname to an absolute pathname, Ruby-Talk:18512" # TypeError: no implicit conversion of NilClass into String
  fails "File.expand_path converts a pathname to an absolute pathname, using a complete path" # Expected "C:/Users/Administrator/workspace/opal/spec" == "" to be truthy but was false
  fails "File.expand_path does not modify the string argument" # Expected "C:/Users/Administrator/workspace/opal/spec/a/c" == "/a/c" to be truthy but was false
  fails "File.expand_path expands a path with multi-byte characters" # Expected "C:/Users/Administrator/workspace/opal/spec/Ångsström" == "/Ångström" to be truthy but was false
  fails "File.expand_path returns a String when passed a String subclass" # Expected "C:/Users/Administrator/workspace/opal/spec/a/c" == "/a/c" to be truthy but was false
  fails "File.open accepts extra flags as a keyword argument and combine with a string mode" # Errno::EACCES: Permission denied
  fails "File.open accepts extra flags as a keyword argument and combine with an integer mode" # Errno::EACCES: Permission denied
  fails "File.open calls #to_hash to convert the second argument to a Hash" # Errno::EACCES: Permission denied
  fails "File.open can read and write in a block when call open with File::RDWR|File::EXCL mode" # Errno::EACCES: Permission denied
  fails "File.open can read and write in a block when call open with RDWR mode" # Errno::EACCES: Permission denied
  fails "File.open can read in a block when call open with 'r' mode" # Errno::EACCES: Permission denied
  fails "File.open can read in a block when call open with File::EXCL mode" # Errno::EACCES: Permission denied
  fails "File.open can read in a block when call open with RDONLY mode" # Errno::EACCES: Permission denied
  fails "File.open can write in a block when call open with 'w' mode" # Errno::EACCES: Permission denied
  fails "File.open can write in a block when call open with WRONLY mode" # Errno::EACCES: Permission denied
  fails "File.open can't read in a block when call open with File::EXCL mode" # Errno::EACCES: Permission denied
  fails "File.open can't read in a block when call open with File::WRONLY||File::RDONLY mode" # Errno::EACCES: Permission denied
  fails "File.open can't write in a block when call open with File::TRUNC mode" # Errno::EACCES: Permission denied
  fails "File.open can't write in a block when call open with File::WRONLY||File::RDONLY mode" # Errno::EACCES: Permission denied
  fails "File.open creates a new file when use File::WRONLY|File::APPEND mode" # Errno::EACCES: Permission denied
  fails "File.open creates the file and returns writable descriptor when called with 'w' mode and r-o permissions" # Errno::EACCES: Permission denied
  fails "File.open defaults external_encoding to BINARY for binary modes" # Errno::EACCES: Permission denied
  fails "File.open does not open a file that does no exists when using File::TRUNC mode" # Errno::EACCES: Permission denied
  fails "File.open opens a file for binary read" # Errno::EACCES: Permission denied
  fails "File.open opens a file for binary read-write and truncate the file" # Errno::EACCES: Permission denied
  fails "File.open opens a file for binary read-write starting at the beginning of the file" # Errno::EACCES: Permission denied
  fails "File.open opens a file for binary write" # Errno::EACCES: Permission denied
  fails "File.open opens a file for read-write and truncate the file" # Errno::EACCES: Permission denied
  fails "File.open opens a file that no exists when use 'a' mode" # Errno::EACCES: Permission denied
  fails "File.open opens a file that no exists when use 'r' mode" # Errno::EACCES: Permission denied
  fails "File.open opens a file that no exists when use 'w' mode" # Errno::EACCES: Permission denied
  fails "File.open opens a file that no exists when use File::CREAT mode" # Errno::EACCES: Permission denied
  fails "File.open opens a file that no exists when use File::EXCL mode" # Errno::EACCES: Permission denied
  fails "File.open opens a file that no exists when use File::NONBLOCK mode" # Errno::EACCES: Permission denied
  fails "File.open opens a file that no exists when use File::RDONLY mode" # Errno::EACCES: Permission denied
  fails "File.open opens a file that no exists when use File::WRONLY mode" # Errno::EACCES: Permission denied
  fails "File.open opens a file when called with a block" # Errno::EACCES: Permission denied
  fails "File.open opens a file when use File::WRONLY|File::APPEND mode" # Errno::EACCES: Permission denied
  fails "File.open opens a file when use File::WRONLY|File::TRUNC mode" # Errno::EACCES: Permission denied
  fails "File.open opens a file with mode and permission as nil" # Errno::EACCES: Permission denied
  fails "File.open opens a file with mode num and block" # Errno::EACCES: Permission denied
  fails "File.open opens a file with mode num" # Errno::EACCES: Permission denied
  fails "File.open opens a file with mode string and block" # Errno::EACCES: Permission denied
  fails "File.open opens the file (basic case)" # Errno::EACCES: Permission denied
  fails "File.open opens the file when call with fd" # Errno::EACCES: Permission denied
  fails "File.open opens the file when passed mode, num and permissions" # Errno::EACCES: Permission denied
  fails "File.open opens the file when passed mode, num, permissions and block" # Errno::EACCES: Permission denied
  fails "File.open opens the file with unicode characters" # Errno::EACCES: Permission denied
  fails "File.open opens with mode string" # Errno::EACCES: Permission denied
  fails "File.open raises a SystemCallError if passed an invalid Integer type" # Errno::EACCES: Permission denied
  fails "File.open raises a TypeError if passed a filename that is not a String or Integer type" # Errno::EACCES: Permission denied
  fails "File.open raises an ArgumentError exception when call with an unknown mode" # Errno::EACCES: Permission denied
  fails "File.open raises an ArgumentError if passed an invalid string for mode" # Errno::EACCES: Permission denied
  fails "File.open raises an Errno::EACCES when opening read-only file" # Errno::EACCES: Permission denied
  fails "File.open raises an Errorno::EEXIST if the file exists when open with File::CREAT|File::EXCL" # Errno::EACCES: Permission denied
  fails "File.open raises an Errorno::EEXIST if the file exists when open with File::RDONLY|File::TRUNC" # Errno::EACCES: Permission denied
  fails "File.open raises an IO exception when write in a block opened with 'r' mode" # Errno::EACCES: Permission denied
  fails "File.open raises an IO exception when write in a block opened with RDONLY mode" # Errno::EACCES: Permission denied
  fails "File.open raises an IOError if the file exists when open with File::RDONLY|File::APPEND" # Errno::EACCES: Permission denied
  fails "File.open raises an IOError when read in a block opened with 'a' mode" # Errno::EACCES: Permission denied
  fails "File.open raises an IOError when read in a block opened with 'w' mode" # Errno::EACCES: Permission denied
  fails "File.open raises an IOError when read in a block opened with File::WRONLY|File::APPEND mode" # Errno::EACCES: Permission denied
  fails "File.open raises an IOError when read in a block opened with WRONLY mode" # Errno::EACCES: Permission denied
  fails "File.open raises an IOError when write in a block opened with File::RDONLY|File::APPEND mode" # Errno::EACCES: Permission denied
  fails "File.open uses the second argument as an options Hash" # Errno::EACCES: Permission denied
  fails "File.owned? returns true if the file exist and is owned by the user" # Expected false == true to be truthy but was false
  fails "File.umask returns the current umask value for this process (basic)" # Expected 18 == 0 to be truthy but was false
  fails "File.umask returns the current umask value for this process" # Expected 6 == 0 to be truthy but was false
  fails "File::Stat#dev_major returns nil" # Expected 652197810 to be nil
  fails "File::Stat#dev_minor returns nil" # Expected 159031 to be nil
  fails "File::Stat#executable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#gid returns the group owner attribute of a File::Stat object" # Expected 0 == -1 to be truthy but was false
  fails "File::Stat#mode returns the mode of a File::Stat object" # Expected 438 == 420 to be truthy but was false
  fails "File::Stat#owned? returns true if the file is owned by the user" # Expected #<File::Stat dev=26dfb237, ino=279504651873764670, mode=81b6, nlink=1, uid=0, gid=0, rdev=0, size=0, blksize=4096, blocks=0, atime=2025-04-15 20:28:20 -0000, mtime=2025-04-15 20:28:20 -0000, ctime=2025-04-15 20:28:20 -0000, birthtime=2025-04-15 20:27:44 -0000.owned? to be truthy but was false
  fails "File::Stat#rdev_major returns nil" # Expected 0 to be nil
  fails "File::Stat#rdev_minor returns nil" # Expected 0 to be nil
  fails "File::Stat#uid returns the owner attribute of a File::Stat object" # Expected 0 == -1 to be truthy but was false
  fails "FileTest.executable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
end
