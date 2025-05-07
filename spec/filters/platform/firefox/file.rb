# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File#atime returns the last access time to self" # Errno::ENOENT: No such file or directory
  fails "File#ctime returns the change time for the named file (the time at which directory information about the file was changed, not the file itself)." # Errno::ENOENT: No such file or directory
  fails "File#initialize accepts encoding options as a hash parameter" # Errno::ENOENT: No such file or directory
  fails "File#initialize accepts encoding options in mode parameter" # Errno::ENOENT: No such file or directory
  fails "File#path does not canonicalize the path it returns" # Errno::ENOENT: No such file or directory
  fails "File#path does not normalise the path it returns" # Errno::ENOENT: No such file or directory
  fails "File#size returns the file's current size even if modified" # Expected 8 == 9 to be truthy but was false
  fails "File#to_path does not canonicalize the path it returns" # Errno::ENOENT: No such file or directory
  fails "File#to_path does not normalise the path it returns" # Errno::ENOENT: No such file or directory
  fails "File#truncate truncates a file to a larger size than the original file" # Expected 10 == 12 to be truthy but was false
  fails "File.absolute_path does not expand '~user' to a home directory." # Errno::ENOENT: No such file or directory
  fails "File.absolute_path resolves paths relative to the current working directory" # Errno::ENOENT: No such file or directory
  fails "File.absolute_path? does not expand '~user' to a home directory." # Errno::ENOENT: No such file or directory
  fails "File.chmod raises an error for a non existent path" # Expected Errno::ENOENT but no exception was raised (1 was returned)
  fails "File.ctime accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.ctime returns the change time for the named file (the time at which directory information about the file was changed, not the file itself)." # Errno::ENOENT: No such file or directory
  fails "File.delete raises an Errno::ENOENT when the given file doesn't exist" # Expected Errno::ENOENT but no exception was raised (1 was returned)
  fails "File.executable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.exist? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.exist? returns true if the file exist" # Expected false == true to be truthy but was false
  fails "File.expand_path does not modify the string argument" # Expected "/a/c" == "//a/c" to be truthy but was false
  fails "File.expand_path expands a path with multi-byte characters" # Expected "/Ångström" == "//Ångström" to be truthy but was false
  fails "File.expand_path returns a String when passed a String subclass" # Expected "/a/c" == "//a/c" to be truthy but was false
  fails "File.identical? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.identical? returns true for a file and its link" # Expected false == true to be truthy but was false
  fails "File.identical? returns true if both named files are identical" # Expected false to be true
  fails "File.mtime returns the modification Time of the file" # Expected 1970-01-01 01:00:00 +0100 to be within 2025-04-18 05:23:30 +0200 +/- 20
  fails "File.new creates a new file when use File::EXCL mode" # Errno::EEXIST: File exists
  fails "File.open can read and write in a block when call open with File::RDWR|File::EXCL mode" # Errno::EEXIST: File exists
  fails "File.open can read in a block when call open with File::EXCL mode" # Errno::EEXIST: File exists
  fails "File.open can't read in a block when call open with File::EXCL mode" # Expected IOError but got: Errno::EEXIST (File exists)
  fails "File.open opens a file when use File::WRONLY|File::APPEND mode" # Expected  "bye file " ==  "hello file " to be truthy but was false
  fails "File.open raises an Errno::EACCES when opening read-only file" # Expected Errno::EACCES but no exception was raised (<File:fd 114> was returned)
  fails "File.readable? accepts an object that has a #to_path method" # TypeError: no implicit conversion of NilClass into String
  fails "File.readable? returns true if named file is readable by the effective user id of the process, otherwise false" # TypeError: no implicit conversion of NilClass into String
  fails "File.readable_real? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.readable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.rename raises an Errno::ENOENT if the source does not exist" # Expected Errno::ENOENT but no exception was raised (0 was returned)
  fails "File.rename renames a file" # Expected File.exist? "//tmp/rubyspec_temp/file_rename.txt" to be falsy but was true
  fails "File.truncate truncates to a larger file size than the original file" # Expected 10 == 12 to be truthy but was false
  fails "File.umask returns an Integer" # Expected nil (NilClass) to be kind of Integer
  fails "File.unlink raises an Errno::ENOENT when the given file doesn't exist" # Expected Errno::ENOENT but no exception was raised (1 was returned)
  fails "File.utime accepts numeric atime and mtime arguments" # Expected 1970-01-01 01:00:00 +0100 to be within 2025-04-18 05:23:22 +0200 +/- 0.0001
  fails "File.utime sets the access and modification time of each file" # Expected 1970-01-01 01:00:00 +0100 to be within 2025-04-18 05:23:22 +0200 +/- 0.0001
  fails "File.utime uses the current times if two nil values are passed" # Expected 1970-01-01 01:00:00 +0100 to be within 2025-04-18 05:23:22 +0200 +/- 0.05
  fails "File.world_readable? returns an Integer if the file is a directory and chmod 644" # Expected nil (NilClass) to be an instance of Integer
  fails "File.world_readable? returns an Integer if the file is chmod 644" # Expected nil (NilClass) to be an instance of Integer
  fails "File.writable? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.writable? returns true if named file is writable by the effective user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.writable_real? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.writable_real? returns true if named file is writable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#<=> includes Comparable and #== shows mtime equality between two File::Stat objects" # Expected true == false to be truthy but was false
  fails "File::Stat#<=> is able to compare files by different modification times" # Expected 0 == -1 to be truthy but was false
  fails "File::Stat#dev returns the number of the device on which the file exists" # Expected nil (NilClass) to be kind of Integer
  fails "File::Stat#executable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#file? returns true if the named file exists and is a regular file." # Errno::ENOENT: No such file or directory
  fails "File::Stat#mode returns the mode of a File::Stat object" # Expected 0 == 420 to be truthy but was false
  fails "File::Stat#rdev returns the number of the device this file represents which the file exists" # Expected nil (NilClass) to be kind of Integer
  fails "File::Stat#readable? accepts an object that has a #to_path method" # TypeError: no implicit conversion of NilClass into String
  fails "File::Stat#readable? returns true if named file is readable by the effective user id of the process, otherwise false" # TypeError: no implicit conversion of NilClass into String
  fails "File::Stat#readable_real? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File::Stat#readable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#writable? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File::Stat#writable? returns true if named file is writable by the effective user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#writable_real? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File::Stat#writable_real? returns true if named file is writable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat.world_readable? returns an Integer if the file is a directory and chmod 644" # Expected nil (NilClass) to be an instance of Integer
  fails "File::Stat.world_readable? returns an Integer if the file is chmod 644" # Expected nil (NilClass) to be an instance of Integer
end
