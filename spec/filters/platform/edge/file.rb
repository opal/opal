# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File#atime returns the last access time to self" # Errno::ENOENT: No such file or directory
  fails "File#birthtime returns the birth time for self" # Errno::ENOENT: No such file or directory
  fails "File#chmod modifies the permission bits of the files specified" # Expected 0 == 33261 to be truthy but was false
  fails "File#chmod with '0111' makes file executable but not readable or writable" # Expected false == true to be truthy but was false
  fails "File#chmod with '0222' makes file writable but not readable or executable" # Expected false == true to be truthy but was false
  fails "File#chmod with '0444' makes file readable and executable but not writable" # Expected false == true to be truthy but was false
  fails "File#chmod with '0444' makes file readable but not writable or executable" # Expected false == true to be truthy but was false
  fails "File#chmod with '0644' makes file readable and writable and also executable" # Expected false == true to be truthy but was false
  fails "File#chmod with '0666' makes file readable and writable but not executable" # Expected false == true to be truthy but was false
  fails "File#ctime returns the change time for the named file (the time at which directory information about the file was changed, not the file itself)." # Errno::ENOENT: No such file or directory
  fails "File#initialize accepts encoding options as a hash parameter" # Errno::ENOENT: No such file or directory
  fails "File#initialize accepts encoding options in mode parameter" # Errno::ENOENT: No such file or directory
  fails "File#path does not canonicalize the path it returns" # Errno::ENOENT: No such file or directory
  fails "File#path does not normalise the path it returns" # Errno::ENOENT: No such file or directory
  fails "File#size follows symlinks if necessary" # Errno::ENOENT: No such file or directory
  fails "File#size returns the cached size of the file if subsequently deleted" # Errno::ENOENT: No such file or directory
  fails "File#size returns the file's current size even if modified" # Expected 8 == 9 to be truthy but was false
  fails "File#to_path does not canonicalize the path it returns" # Errno::ENOENT: No such file or directory
  fails "File#to_path does not normalise the path it returns" # Errno::ENOENT: No such file or directory
  fails "File#truncate truncates a file to a larger size than the original file" # Expected 10 == 12 to be truthy but was false
  fails "File.absolute_path does not expand '~user' to a home directory." # Errno::ENOENT: No such file or directory
  fails "File.absolute_path resolves paths relative to the current working directory" # Errno::ENOENT: No such file or directory
  fails "File.absolute_path? calls #to_path on its argument" # Expected false to be true
  fails "File.absolute_path? does not expand '~user' to a home directory." # Errno::ENOENT: No such file or directory
  fails "File.absolute_path? returns true if it's an absolute pathname" # Expected false to be true
  fails "File.birthtime accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.birthtime returns the birth time for the named file as a Time object" # Errno::ENOENT: No such file or directory
  fails "File.chmod modifies the permission bits of the files specified" # Expected 0 == 33261 to be truthy but was false
  fails "File.chmod raises an error for a non existent path" # Expected Errno::ENOENT but no exception was raised (1 was returned)
  fails "File.chmod with '0111' makes file executable but not readable or writable" # Expected false == true to be truthy but was false
  fails "File.chmod with '0222' makes file writable but not readable or executable" # Expected false == true to be truthy but was false
  fails "File.chmod with '0444' makes file readable and executable but not writable" # Expected false == true to be truthy but was false
  fails "File.chmod with '0444' makes file readable but not writable or executable" # Expected false == true to be truthy but was false
  fails "File.chmod with '0644' makes file readable and writable and also executable" # Expected false == true to be truthy but was false
  fails "File.chmod with '0666' makes file readable and writable but not executable" # Expected false == true to be truthy but was false
  fails "File.ctime accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.ctime returns the change time for the named file (the time at which directory information about the file was changed, not the file itself)." # Errno::ENOENT: No such file or directory
  fails "File.delete raises an Errno::ENOENT when the given file doesn't exist" # Expected Errno::ENOENT but no exception was raised (1 was returned)
  fails "File.directory? returns true if the argument is an IO that is a directory" # Errno::EISDIR: Is a directory
  fails "File.empty? returns true for /dev/null" # Expected false == true to be truthy but was false
  fails "File.executable? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.executable? returns true if named file is executable by the effective user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.executable? returns true if the argument is an executable file" # Expected false == true to be truthy but was false
  fails "File.executable_real? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.executable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.executable_real? returns true if the file its an executable" # Expected false == true to be truthy but was false
  fails "File.exist? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.exist? returns true if the file exist" # Expected false == true to be truthy but was false
  fails "File.expand_path converts a pathname to an absolute pathname" # Expected "/" == nil to be truthy but was false
  fails "File.expand_path converts a pathname to an absolute pathname, Ruby-Talk:18512" # TypeError: no implicit conversion of NilClass into String
  fails "File.expand_path converts a pathname to an absolute pathname, using a complete path" # Expected "/" == "" to be truthy but was false
  fails "File.expand_path does not modify the string argument" # Expected "/a/c" == "//a/c" to be truthy but was false
  fails "File.expand_path expands a path with multi-byte characters" # Expected "/Ångström" == "//Ångström" to be truthy but was false
  fails "File.expand_path returns a String when passed a String subclass" # Expected "/a/c" == "//a/c" to be truthy but was false
  fails "File.ftype returns 'link' when the file is a link" # Errno::ENOENT: No such file or directory
  fails "File.ftype returns fifo when the file is a fifo" # NoMethodError: undefined method `~' for nil
  fails "File.grpowned? returns false if the file exist" # Expected true to be false
  fails "File.identical? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.identical? returns true for a file and its link" # Expected false == true to be truthy but was false
  fails "File.identical? returns true if both named files are identical" # Exception: Cannot read properties of undefined (reading '$==')
  fails "File.link link a file with another" # Expected File.exist? "//tmp/rubyspec_temp/file_link.lnk" to be truthy but was false
  fails "File.link raises an Errno::EEXIST if the target already exists" # Expected Errno::EEXIST but no exception was raised (0 was returned)
  fails "File.lstat returns a File::Stat object with symlink properties for a symlink" # Errno::ENOENT: No such file or directory
  fails "File.lutime sets the access and modification time for a regular file" # Expected 1970-01-01 01:00:00 +0100 == 2000-01-01 00:00:00 UTC to be truthy but was false
  fails "File.lutime sets the access and modification time for a symlink" # Errno::ENOENT: No such file or directory
  fails "File.mkfifo creates a FIFO file at the passed path" # NoMethodError: undefined method `~' for nil
  fails "File.mkfifo creates a FIFO file with a default mode of 0666 & ~umask" # NoMethodError: undefined method `~' for nil
  fails "File.mkfifo returns 0 after creating the FIFO file" # NoMethodError: undefined method `~' for nil
  fails "File.mkfifo when path does not exist raises an Errno::ENOENT exception" # Expected Errno::ENOENT but got: NoMethodError (undefined method `~' for nil)
  fails "File.mkfifo when path passed responds to :to_path creates a FIFO file at the path specified" # NoMethodError: undefined method `~' for nil
  fails "File.mtime returns the modification Time of the file" # Expected 1970-01-01 01:00:00 +0100 to be within 2025-04-10 03:14:44 +0200 +/- 20
  fails "File.new creates a new file when use File::EXCL mode" # Errno::EEXIST: File exists
  fails "File.new opens directories" # Errno::EISDIR: Is a directory
  fails "File.new returns a new File with modus num and permissions" # Expected "0" == "100744" to be truthy but was false
  fails "File.open can read and write in a block when call open with File::RDWR|File::EXCL mode" # Errno::EEXIST: File exists
  fails "File.open can read in a block when call open with File::EXCL mode" # Errno::EEXIST: File exists
  fails "File.open can't read in a block when call open with File::EXCL mode" # Expected IOError but got: Errno::EEXIST (File exists)
  fails "File.open creates a new write-only file when invoked with 'w' and '0222'" # Expected false == true to be truthy but was false
  fails "File.open opens a file when use File::WRONLY|File::APPEND mode" # Expected  "bye file " ==  "hello file " to be truthy but was false
  fails "File.open opens directories" # Errno::EISDIR: Is a directory
  fails "File.open opens the file when passed mode, num and permissions" # Expected "0" == "100744" to be truthy but was false
  fails "File.open opens the file when passed mode, num, permissions and block" # Expected "0" == "100755" to be truthy but was false
  fails "File.open raises an Errno::EACCES when opening non-permitted file" # Expected Errno::EACCES but no exception was raised (nil was returned)
  fails "File.open raises an Errno::EACCES when opening read-only file" # Expected Errno::EACCES but no exception was raised (<File:fd 4317> was returned)
  fails "File.pipe? returns true if the file is a pipe" # NoMethodError: undefined method `~' for nil
  fails "File.readable? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.readable? returns false if the file does not exist" # TypeError: no implicit conversion of NilClass into String
  fails "File.readable? returns true if named file is readable by the effective user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.readable_real? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.readable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.readlink when changing the working directory returns the name of the file referenced by the given link when the file does not exist" # ArgumentError: /tmp/rubyspec_temp/readlink/readlink_file is not prefixed by //tmp/rubyspec_temp
  fails "File.readlink when changing the working directory returns the name of the file referenced by the given link" # ArgumentError: /tmp/rubyspec_temp/readlink/readlink_file is not prefixed by //tmp/rubyspec_temp
  fails "File.readlink with absolute paths raises an Errno::EINVAL if called with a normal file" # Expected Errno::EINVAL but no exception was raised (nil was returned)
  fails "File.readlink with absolute paths raises an Errno::ENOENT if there is no such file" # Expected Errno::ENOENT but no exception was raised (nil was returned)
  fails "File.readlink with absolute paths returns the name of the file referenced by the given link when the file does not exist" # Expected nil == "//tmp/rubyspec_temp/file_readlink.txt" to be truthy but was false
  fails "File.readlink with absolute paths returns the name of the file referenced by the given link" # Expected nil == "//tmp/rubyspec_temp/file_readlink.txt" to be truthy but was false
  fails "File.readlink with paths containing unicode characters returns the name of the file referenced by the given link" # NoMethodError: undefined method `encoding' for nil
  fails "File.realdirpath raises Errno::ENOENT if the directory is absent" # Expected Errno::ENOENT but no exception was raised ("//tmp/rubyspec_temp/dir_realdirpath_fake/fake_file_in_fake_dir" was returned)
  fails "File.realdirpath raises Errno::ENOENT if the symlink points to an absent directory" # Expected Errno::ENOENT but no exception was raised ("//tmp/rubyspec_temp/dir_realdirpath_link/fake_link_to_fake_dir" was returned)
  fails "File.realdirpath raises an Errno::ELOOP if the symlink points to itself" # Errno::ENOENT: No such file or directory
  fails "File.realdirpath returns the real (absolute) pathname if the symlink points to an absent file" # Expected "//tmp/rubyspec_temp/dir_realdirpath_link/fake_link_to_real_dir" == "//tmp/rubyspec_temp/dir_realdirpath_real/fake_file_in_real_dir" to be truthy but was false
  fails "File.realdirpath returns the real (absolute) pathname not containing symlinks" # Expected "//tmp/rubyspec_temp/dir_realdirpath_link/link" == "//tmp/rubyspec_temp/dir_realdirpath_real/file" to be truthy but was false
  fails "File.realdirpath uses base directory for interpreting relative pathname" # Expected "//tmp/rubyspec_temp/dir_realdirpath_link/link" == "//tmp/rubyspec_temp/dir_realdirpath_real/file" to be truthy but was false
  fails "File.realdirpath uses current directory for interpreting relative pathname" # Errno::ENOENT: No such file or directory
  fails "File.realdirpath uses link directory for expanding relative links" # Expected "//tmp/rubyspec_temp/dir_realdirpath_real/dir1/link" == "//tmp/rubyspec_temp/dir_realdirpath_real/file" to be truthy but was false
  fails "File.realpath raises Errno::ENOENT if the file is absent" # Expected Errno::ENOENT but no exception was raised ("//tmp/rubyspec_temp/dir_realpath_real/fake_file" was returned)
  fails "File.realpath raises Errno::ENOENT if the symlink points to an absent file" # Expected Errno::ENOENT but no exception was raised ("//tmp/rubyspec_temp/dir_realpath_link/fake_link" was returned)
  fails "File.realpath raises an Errno::ELOOP if the symlink points to itself" # Errno::ENOENT: No such file or directory
  fails "File.realpath removes the file element when going one level up" # Expected "//tmp/rubyspec_temp/dir_realpath_real/file/../" == "//tmp/rubyspec_temp/dir_realpath_real" to be truthy but was false
  fails "File.realpath returns the real (absolute) pathname not containing symlinks" # Expected "//tmp/rubyspec_temp/dir_realpath_link/link" == "//tmp/rubyspec_temp/dir_realpath_real/file" to be truthy but was false
  fails "File.realpath uses base directory for interpreting relative pathname" # Expected "//tmp/rubyspec_temp/dir_realpath_link/link" == "//tmp/rubyspec_temp/dir_realpath_real/file" to be truthy but was false
  fails "File.realpath uses current directory for interpreting relative pathname" # Errno::ENOENT: No such file or directory
  fails "File.realpath uses link directory for expanding relative links" # Expected "//tmp/rubyspec_temp/dir_realpath_real/dir1/link" == "//tmp/rubyspec_temp/dir_realpath_real/file" to be truthy but was false
  fails "File.rename raises an Errno::ENOENT if the source does not exist" # Expected Errno::ENOENT but no exception was raised (0 was returned)
  fails "File.rename renames a file" # Expected File.exist? "//tmp/rubyspec_temp/file_rename.txt" to be falsy but was true
  fails "File.setuid? returns true when the gid bit is set" # Exception: Cannot read properties of undefined (reading '$==')
  fails "File.stat returns a File::Stat object with file properties for a symlink" # Errno::ENOENT: No such file or directory
  fails "File.stat returns an error when given missing non-ASCII path" # Expected "No such file or directory" to include "/missingfilepath\xE3E4"
  fails "File.stat returns information for a file that has been deleted but is still open" # Errno::ENOENT: No such file or directory
  fails "File.sticky? returns true if the named file has the sticky bit, otherwise false" # Expected false == true to be truthy but was false
  fails "File.symlink accepts args that have #to_path methods" # Expected false == true to be truthy but was false
  fails "File.symlink creates a symbolic link" # Expected false == true to be truthy but was false
  fails "File.symlink creates a symlink between a source and target file" # Expected false == true to be truthy but was false
  fails "File.symlink raises an Errno::EEXIST if the target already exists" # Expected Errno::EEXIST but no exception was raised (0 was returned)
  fails "File.symlink? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.symlink? returns true if the file is a link" # Expected false == true to be truthy but was false
  fails "File.truncate truncates to a larger file size than the original file" # Expected 10 == 12 to be truthy but was false
  fails "File.umask invokes to_int on non-integer argument" # Expected nil == 18 to be truthy but was false
  fails "File.umask returns an Integer" # Expected nil (NilClass) to be kind of Integer
  fails "File.umask returns the current umask value for the process" # Expected nil == 18 to be truthy but was false
  fails "File.umask returns the current umask value for this process (basic)" # Expected nil == 0 to be truthy but was false
  fails "File.umask returns the current umask value for this process" # Expected nil == 128 to be truthy but was false
  fails "File.unlink raises an Errno::ENOENT when the given file doesn't exist" # Expected Errno::ENOENT but no exception was raised (1 was returned)
  fails "File.utime accepts numeric atime and mtime arguments" # Expected 0 to be within 1744247689 +/- 20
  fails "File.utime sets the access and modification time of each file" # Expected 0 to be within 1744247689 +/- 20
  fails "File.utime uses the current times if two nil values are passed" # Expected 0 to be within 1744247689 +/- 20
  fails "File.world_readable? returns an Integer if the file is a directory and chmod 644" # Expected nil (NilClass) to be an instance of Integer
  fails "File.world_readable? returns an Integer if the file is chmod 644" # Expected nil (NilClass) to be an instance of Integer
  fails "File.world_writable? returns an Integer if the file is a directory and chmod 777" # Expected nil (NilClass) to be an instance of Integer
  fails "File.world_writable? returns an Integer if the file is chmod 777" # Expected nil (NilClass) to be an instance of Integer
  fails "File.writable? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.writable? returns true if named file is writable by the effective user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.writable_real? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.writable_real? returns true if named file is writable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.zero? returns true for /dev/null" # Expected false == true to be truthy but was false
  fails "File::Stat#<=> includes Comparable and #== shows mtime equality between two File::Stat objects" # Expected true == false to be truthy but was false
  fails "File::Stat#<=> is able to compare files by different modification times" # Expected 0 == -1 to be truthy but was false
  fails "File::Stat#dev returns the number of the device on which the file exists" # Exception: Cannot read properties of undefined (reading '$should')
  fails "File::Stat#dev_major returns the major part of File::Stat#dev" # Exception: Cannot read properties of undefined (reading '$>>')
  fails "File::Stat#dev_minor returns the minor part of File::Stat#dev" # Exception: Cannot read properties of undefined (reading '$&')
  fails "File::Stat#executable? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File::Stat#executable? returns true if named file is executable by the effective user id of the process, otherwise false" # Errno::ENOENT: No such file or directory
  fails "File::Stat#executable? returns true if the argument is an executable file" # Expected false == true to be truthy but was false
  fails "File::Stat#executable_real? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File::Stat#executable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#executable_real? returns true if the file its an executable" # Expected false == true to be truthy but was false
  fails "File::Stat#file? returns true if the named file exists and is a regular file." # Errno::ENOENT: No such file or directory
  fails "File::Stat#file? returns true if the null device exists and is a regular file." # Errno::ENOENT: No such file or directory
  fails "File::Stat#ftype returns 'link' when the file is a link" # Errno::ENOENT: No such file or directory
  fails "File::Stat#ftype returns fifo when the file is a fifo" # NoMethodError: undefined method `~' for nil
  fails "File::Stat#grpowned? returns false if the file exist" # Expected true to be false
  fails "File::Stat#ino returns BY_HANDLE_FILE_INFORMATION.nFileIndexHigh/Low of a File::Stat object" # Expected nil (NilClass) to be kind of Integer
  fails "File::Stat#ino returns the ino of a File::Stat object" # Exception: Cannot read properties of undefined (reading '$should')
  fails "File::Stat#mode returns the mode of a File::Stat object" # Expected 0 == 420 to be truthy but was false
  fails "File::Stat#nlink returns the number of links to a file" # Expected 0 == 1 to be truthy but was false
  fails "File::Stat#owned? returns false if the file is not owned by the user" # Errno::ENOENT: No such file or directory
  fails "File::Stat#pipe? returns true if the file is a pipe" # NoMethodError: undefined method `~' for nil
  fails "File::Stat#rdev returns the number of the device this file represents which the file exists" # Exception: Cannot read properties of undefined (reading '$should')
  fails "File::Stat#rdev_major returns the major part of File::Stat#rdev" # Exception: Cannot read properties of undefined (reading '$>>')
  fails "File::Stat#rdev_minor returns the minor part of File::Stat#rdev" # Exception: Cannot read properties of undefined (reading '$&')
  fails "File::Stat#readable? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File::Stat#readable? returns true if named file is readable by the effective user id of the process, otherwise false" # Errno::ENOENT: No such file or directory
  fails "File::Stat#readable_real? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File::Stat#readable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#sticky? returns true if the named file has the sticky bit, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#symlink? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File::Stat#symlink? returns true if the file is a link" # Errno::ENOENT: No such file or directory
  fails "File::Stat#writable? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File::Stat#writable? returns true if named file is writable by the effective user id of the process, otherwise false" # Errno::ENOENT: No such file or directory
  fails "File::Stat#writable_real? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File::Stat#writable_real? returns true if named file is writable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#zero? returns true for /dev/null" # Errno::ENOENT: No such file or directory
  fails "File::Stat.world_readable? returns an Integer if the file is a directory and chmod 644" # Expected nil (NilClass) to be an instance of Integer
  fails "File::Stat.world_readable? returns an Integer if the file is chmod 644" # Expected nil (NilClass) to be an instance of Integer
  fails "File::Stat.world_writable? returns an Integer if the file is a directory and chmod 777" # Expected nil (NilClass) to be an instance of Integer
  fails "File::Stat.world_writable? returns an Integer if the file is chmod 777" # Expected nil (NilClass) to be an instance of Integer
end
