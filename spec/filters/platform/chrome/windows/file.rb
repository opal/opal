# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File#birthtime returns the birth time for self" # Errno::ENOENT: No such file or directory
  fails "File#chmod with '0444' makes file readable and executable but not writable" # Expected false == true to be truthy but was false
  fails "File#chmod with '0644' makes file readable and writable and also executable" # Expected false == true to be truthy but was false
  fails "File.absolute_path? calls #to_path on its argument" # Expected false to be true
  fails "File.absolute_path? returns true if it's an absolute pathname" # Expected false to be true
  fails "File.birthtime accepts an object that has a #to_path method" # Errno::ENOENT: No such file or directory
  fails "File.birthtime returns the birth time for the named file as a Time object" # Errno::ENOENT: No such file or directory
  fails "File.chmod with '0444' makes file readable and executable but not writable" # Expected false == true to be truthy but was false
  fails "File.chmod with '0644' makes file readable and writable and also executable" # Expected false == true to be truthy but was false
  fails "File.expand_path converts a pathname to an absolute pathname" # Expected "/" == nil to be truthy but was false
  fails "File.expand_path converts a pathname to an absolute pathname, Ruby-Talk:18512" # TypeError: no implicit conversion of NilClass into String
  fails "File.expand_path converts a pathname to an absolute pathname, using a complete path" # Expected "/" == "" to be truthy but was false
  fails "File.grpowned? returns false if the file exist" # Expected true to be false
  fails "File.readable? returns false if the file does not exist" # TypeError: no implicit conversion of NilClass into String
  fails "File.umask returns the current umask value for this process (basic)" # Expected nil == 0 to be truthy but was false
  fails "File.umask returns the current umask value for this process" # Expected nil == 128 to be truthy but was false
  fails "File::Stat#grpowned? returns false if the file exist" # Expected true to be false
  fails "File::Stat#ino returns BY_HANDLE_FILE_INFORMATION.nFileIndexHigh/Low of a File::Stat object" # Expected nil (NilClass) to be kind of Integer
end
