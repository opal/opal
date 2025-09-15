# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File#chmod with '0444' makes file readable and executable but not writable" # Expected false == true to be truthy but was false
  fails "File#chmod with '0644' makes file readable and writable and also executable" # Expected false == true to be truthy but was false
  fails "File.atime returns the last access time for the named file with microseconds" # Errno::ENOENT: No such file or directory - stat -c%x 'ruby/core/file/atime_spec.rb'
  fails "File.chmod with '0444' makes file readable and executable but not writable" # Expected false == true to be truthy but was false
  fails "File.chmod with '0644' makes file readable and writable and also executable" # Expected false == true to be truthy but was false
  fails "File.ctime returns the change time for the named file (the time at which directory information about the file was changed, not the file itself) with microseconds." # Errno::ENOENT: No such file or directory - stat -c%z 'ruby/core/file/ctime_spec.rb'
  fails "File.executable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.mtime returns the modification Time of the file with microseconds" # Errno::ENOENT: No such file or directory - stat -c%y 'ruby/core/file/mtime_spec.rb'
  fails "File.owned? returns true if the file exist and is owned by the user" # Expected false == true to be truthy but was false
  fails "File.umask returns the current umask value for this process (basic)" # Expected 18 == 0 to be truthy but was false
  fails "File.umask returns the current umask value for this process" # Expected 6 == 0 to be truthy but was false
  fails "File::Stat#atime returns the atime of a File::Stat object" # Expected 2025-04-22 19:44:50 -0000 <= 2025-04-22 19:44:50 -0000 to be truthy but was false
  fails "File::Stat#birthtime returns the birthtime of a File::Stat object" # Expected 2025-05-26 18:38:53 -0600 <= 2025-05-26 18:38:53 -0600 to be truthy but was false
  fails "File::Stat#ctime returns the ctime of a File::Stat object" # Expected 2025-04-15 20:15:43 -0000 <= 2025-04-15 20:15:43 -0000 to be truthy but was false
  fails "File::Stat#dev_major returns nil" # Expected 0 to be nil
  fails "File::Stat#dev_minor returns nil" # Expected 0 to be nil
  fails "File::Stat#executable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#gid returns the group owner attribute of a File::Stat object" # Expected 0 == -1 to be truthy but was false
  fails "File::Stat#mode returns the mode of a File::Stat object" # Expected 438 == 420 to be truthy but was false
  fails "File::Stat#mtime returns the mtime of a File::Stat object" # Expected 2025-04-15 19:04:17 -0000 <= 2025-04-15 19:04:17 -0000 to be truthy but was false
  fails "File::Stat#owned? returns true if the file is owned by the user" # Expected #<File::Stat dev=0, ino=5066549581073667, mode=81b6, nlink=1, uid=0, gid=0, rdev=0, size=0, blksize=4096, blocks=0, atime=2025-04-10 19:06:24 -0000, mtime=2025-04-10 19:06:24 -0000, ctime=2025-04-10 19:06:24 -0000, birthtime=2025-04-10 18:46:44 -0000.owned? to be truthy but was false
  fails "File::Stat#rdev_major returns nil" # Expected 0 to be nil
  fails "File::Stat#rdev_minor returns nil" # Expected 0 to be nil
  fails "File::Stat#uid returns the owner attribute of a File::Stat object" # Expected 0 == -1 to be truthy but was false
  fails "FileTest.executable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "FileTest.zero? returns true for NUL" # Expected false == true to be truthy but was false
end
