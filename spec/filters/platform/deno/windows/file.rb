# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File#chmod with '0444' makes file readable and executable but not writable" # NotImplementedError: File#chmod is not available on deno
  fails "File#chmod with '0644' makes file readable and writable and also executable" # NotImplementedError: File#chmod is not available on deno
  fails "File.chmod with '0444' makes file readable and executable but not writable" # Expected true == false to be truthy but was false
  fails "File.chmod with '0644' makes file readable and writable and also executable" # Expected false == true to be truthy but was false
  fails "File.chown accepts an object that has a #to_path method" # Exception: chown '\\?\C:\Users\Administrator\workspace\opal\tmp\rubyspec_temp\file_chown_test'
  fails "File.chown returns the number of files processed" # Exception: chown '\\?\C:\Users\Administrator\workspace\opal\tmp\rubyspec_temp\file_chown_test'
  fails "File.executable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File.expand_path converts a pathname to an absolute pathname" # Expected "C:/Users/Administrator/workspace/opal/spec" == nil to be truthy but was false
  fails "File.expand_path converts a pathname to an absolute pathname, Ruby-Talk:18512" # TypeError: no implicit conversion of NilClass into String
  fails "File.expand_path converts a pathname to an absolute pathname, using a complete path" # Expected "C:/Users/Administrator/workspace/opal/spec" == "" to be truthy but was false
  fails "File.expand_path does not modify the string argument" # Expected "C:/Users/Administrator/workspace/opal/spec/a/c" == "/a/c" to be truthy but was false
  fails "File.expand_path expands a path with multi-byte characters" # Expected "C:/Users/Administrator/workspace/opal/spec/Ångsström" == "/Ångström" to be truthy but was false
  fails "File.expand_path returns a String in the same encoding as the argument" # FrozenError: can't modify frozen String
  fails "File.expand_path returns a String when passed a String subclass" # Expected "C:/Users/Administrator/workspace/opal/spec/a/c" == "/a/c" to be truthy but was false
  fails "File.grpowned? returns false if file the does not exist" # Exception: chown '\\?\C:\Users\Administrator\workspace\opal\tmp\rubyspec_temp\i_exist'
  fails "File.grpowned? returns false if the file exist" # Exception: chown '\\?\C:\Users\Administrator\workspace\opal\tmp\rubyspec_temp\i_exist'
  fails "File.identical? returns true if both named files are identical" # Expected true to be false
  fails "File.owned? returns true if the file exist and is owned by the user" # Expected false == true to be truthy but was false
  fails "File.umask returns the current umask value for this process (basic)" # Expected 18 == 0 to be truthy but was false
  fails "File.umask returns the current umask value for this process" # Expected 6 == 0 to be truthy but was false
  fails "File::Stat#atime returns the atime of a File::Stat object" # Expected 2025-04-15 13:07:05 -0700 <= 2025-04-15 13:07:05 -0700 to be truthy but was false
  fails "File::Stat#ctime returns the ctime of a File::Stat object" # Expected 2025-04-15 12:49:56 -0700 <= 2025-04-15 12:49:56 -0700 to be truthy but was false
  fails "File::Stat#dev_major returns nil" # Expected 0 to be nil
  fails "File::Stat#dev_minor returns nil" # Expected 159031 to be nil
  fails "File::Stat#executable_real? returns true if named file is readable by the real user id of the process, otherwise false" # Expected false == true to be truthy but was false
  fails "File::Stat#gid returns the group owner attribute of a File::Stat object" # Expected 0 == -1 to be truthy but was false
  fails "File::Stat#grpowned? returns false if the file exist" # Exception: chown '\\?\C:\Users\Administrator\workspace\opal\tmp\rubyspec_temp\i_exist'
  fails "File::Stat#ino returns BY_HANDLE_FILE_INFORMATION.nFileIndexHigh/Low of a File::Stat object" # Expected nil (NilClass) to be kind of Integer
  fails "File::Stat#mode returns the mode of a File::Stat object" # Expected 438 == 420 to be truthy but was false
  fails "File::Stat#owned? returns true if the file is owned by the user" # Expected #<File::Stat dev=0, ino=5066549581073667, mode=81b6, nlink=1, uid=0, gid=0, rdev=0, size=0, blksize=4096, blocks=0, atime=2025-04-10 19:06:24 -0000, mtime=2025-04-10 19:06:24 -0000, ctime=2025-04-10 19:06:24 -0000, birthtime=2025-04-10 18:46:44 -0000.owned? to be truthy but was false
  fails "File::Stat#rdev returns the number of the device this file represents which the file exists" # Expected nil (NilClass) to be kind of Integer
  fails "File::Stat#rdev_major returns nil" # Expected 0 to be nil
  fails "File::Stat#uid returns the owner attribute of a File::Stat object" # Expected 0 == -1 to be truthy but was false
end
