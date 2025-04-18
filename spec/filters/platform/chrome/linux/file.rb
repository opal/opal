# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File#chmod modifies the permission bits of the files specified" # Expected 0 == 33261 to be truthy but was false
  fails "File#chmod with '0111' makes file executable but not readable or writable" # Expected false == true to be truthy but was false
  fails "File#chmod with '0222' makes file writable but not readable or executable" # Expected false == true to be truthy but was false
  fails "File#chmod with '0444' makes file readable but not writable or executable" # Expected false == true to be truthy but was false
  fails "File#chmod with '0666' makes file readable and writable but not executable" # Expected false == true to be truthy but was false
  fails "File#size follows symlinks if necessary" # Errno::ENOENT: No such file or directory
  fails "File#size returns the cached size of the file if subsequently deleted" # Errno::ENOENT: No such file or directory
  fails "File.chmod modifies the permission bits of the files specified" # Expected 0 == 33261 to be truthy but was false
  fails "File.chmod with '0111' makes file executable but not readable or writable" # Expected false == true to be truthy but was false
  fails "File.chmod with '0222' makes file writable but not readable or executable" # Expected false == true to be truthy but was false
  fails "File.chmod with '0444' makes file readable but not writable or executable" # Expected false == true to be truthy but was false
  fails "File.chmod with '0666' makes file readable and writable but not executable" # Expected false == true to be truthy but was false
  fails "File.directory? returns true if the argument is an IO that is a directory" # Errno::EISDIR: Is a directory
  fails "File.empty? returns true for /dev/null" # Expected false == true to be truthy but was false
  fails "File.executable? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.executable? returns true if named file is executable by the effective user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.executable? returns true if the argument is an executable file" # Expected false == true to be truthy but was false
  fails "File.executable_real? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.executable_real? returns true if the file its an executable" # Expected false == true to be truthy but was false
  fails "File.expand_path when HOME is not set raises an ArgumentError when passed '~' if HOME == ''" # Expected ArgumentError but no exception was raised ("/" was returned)
  fails "File.ftype returns 'link' when the file is a link" # Errno::ENOENT: No such file or directory
  fails "File.ftype returns fifo when the file is a fifo" # NoMethodError: undefined method `~' for nil
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
  fails "File.new opens directories" # Errno::EISDIR: Is a directory
  fails "File.new returns a new File with modus num and permissions" # Expected "0" == "100744" to be truthy but was false
  fails "File.open creates a new write-only file when invoked with 'w' and '0222'" # Expected false == true to be truthy but was false
  fails "File.open opens directories" # Errno::EISDIR: Is a directory
  fails "File.open opens the file when passed mode, num and permissions" # Expected "0" == "100744" to be truthy but was false
  fails "File.open opens the file when passed mode, num, permissions and block" # Expected "0" == "100755" to be truthy but was false
  fails "File.open raises an Errno::EACCES when opening non-permitted file" # Expected Errno::EACCES but no exception was raised (nil was returned)
  fails "File.pipe? returns true if the file is a pipe" # NoMethodError: undefined method `~' for nil
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
  fails "File.setuid? returns true when the gid bit is set" # Exception: Cannot read properties of undefined (reading '$==')
  fails "File.stat returns a File::Stat object with file properties for a symlink" # Errno::ENOENT: No such file or directory
  fails "File.stat returns an error when given missing non-ASCII path" # Expected "No such file or directory" to include "/missingfilepath\xE3E4"
  fails "File.stat returns information for a file that has been deleted but is still open" # Errno::ENOENT: No such file or directory
  fails "File.sticky? returns true if the file has sticky bit set" # Exception: Cannot read properties of undefined (reading '$==')
  fails "File.sticky? returns true if the named file has the sticky bit, otherwise false" # Expected false == true to be truthy but was false
  fails "File.symlink accepts args that have #to_path methods" # Expected false == true to be truthy but was false
  fails "File.symlink creates a symbolic link" # Expected false == true to be truthy but was false
  fails "File.symlink creates a symlink between a source and target file" # Expected false == true to be truthy but was false
  fails "File.symlink raises an Errno::EEXIST if the target already exists" # Expected Errno::EEXIST but no exception was raised (0 was returned)
  fails "File.symlink? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File.symlink? returns true if the file is a link" # Expected false == true to be truthy but was false
  fails "File.umask invokes to_int on non-integer argument" # Expected nil == 18 to be truthy but was false
  fails "File.umask returns the current umask value for the process" # Expected nil == 18 to be truthy but was false
  fails "File.world_writable? returns an Integer if the file is a directory and chmod 777" # Expected nil (NilClass) to be an instance of Integer
  fails "File.world_writable? returns an Integer if the file is chmod 777" # Expected nil (NilClass) to be an instance of Integer
  fails "File.zero? returns true for /dev/null" # Expected false == true to be truthy but was false
  fails "File::Stat#dev_major returns the major part of File::Stat#dev" # Expected nil (NilClass) to be kind of Integer
  fails "File::Stat#dev_minor returns the minor part of File::Stat#dev" # Expected nil (NilClass) to be kind of Integer
  fails "File::Stat#executable? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File::Stat#executable? returns true if named file is executable by the effective user id of the process, otherwise false" # Errno::ENOENT: No such file or directory
  fails "File::Stat#executable? returns true if the argument is an executable file" # Expected false == true to be truthy but was false
  fails "File::Stat#executable_real? accepts an object that has a #to_path method" # Expected false == true to be truthy but was false
  fails "File::Stat#executable_real? returns true if the file its an executable" # Expected false == true to be truthy but was false
  fails "File::Stat#file? returns true if the null device exists and is a regular file." # Errno::ENOENT: No such file or directory
  fails "File::Stat#ftype returns 'link' when the file is a link" # Errno::ENOENT: No such file or directory
  fails "File::Stat#ftype returns fifo when the file is a fifo" # NoMethodError: undefined method `~' for nil
  fails "File::Stat#ino returns the ino of a File::Stat object" # Expected nil (NilClass) to be kind of Integer
  fails "File::Stat#nlink returns the number of links to a file" # Expected 0 == 1 to be truthy but was false
  fails "File::Stat#owned? returns false if the file is not owned by the user" # Errno::ENOENT: No such file or directory
  fails "File::Stat#pipe? returns true if the file is a pipe" # NoMethodError: undefined method `~' for nil
  fails "File::Stat#rdev_major returns the major part of File::Stat#rdev" # Expected nil (NilClass) to be kind of Integer
  fails "File::Stat#rdev_minor returns the minor part of File::Stat#rdev" # Expected nil (NilClass) to be kind of Integer
  fails "File::Stat#sticky? returns true if the named file has the sticky bit, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#symlink? accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File::Stat#symlink? returns true if the file is a link" # Errno::ENOENT: No such file or directory
  fails "File::Stat#zero? returns true for /dev/null" # Errno::ENOENT: No such file or directory
  fails "File::Stat.world_writable? returns an Integer if the file is a directory and chmod 777" # Expected nil (NilClass) to be an instance of Integer
  fails "File::Stat.world_writable? returns an Integer if the file is chmod 777" # Expected nil (NilClass) to be an instance of Integer
end
