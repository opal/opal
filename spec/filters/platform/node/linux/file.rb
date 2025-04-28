# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File.atime returns the last access time for the named file with microseconds" # Expected 122000 == 123000 to be truthy but was false
  fails "File.expand_path raises an ArgumentError if the path is not valid" # Expected ArgumentError but no exception was raised ("/home/jan" was returned)
  fails "File.expand_path raises an Encoding::CompatibilityError if the external encoding is not compatible" # Expected CompatibilityError but no exception was raised ("/home/jan/workspace/opal/spec/a" was returned)
  fails "File.extname for a filename ending with a dot returns '.'" # Expected "" == "." to be truthy but was false
  fails "File.ftype returns 'characterSpecial' when the file is a char" # RuntimeError: Could not find a character device
  fails "File.ftype returns 'socket' when the file is a socket" # NameError: uninitialized constant SocketSpecs::Socket
  fails "File.mkfifo creates a FIFO file with passed mode & ~umask" # Expected 4589 == 4580 to be truthy but was false
  fails "File.mkfifo when path passed is not a String value raises a TypeError" # Expected TypeError but got: Errno::ENOENT (No such file or directory - No such file or directory /tmp/fifo)
  fails "File.mtime returns the modification Time of the file with microseconds" # Expected 122000 == 123000 to be truthy but was false
  fails "File.new can't alter mode or permissions when opening a file" # Expected Errno::EINVAL but no exception was raised (false was returned)
  fails "File.open on a FIFO opens it as a normal file" # NotImplementedError: Thread creation not available
  fails "File.socket? returns true if the file is a socket" # NameError: uninitialized constant UNIXServer
  fails "File::Stat#birthtime raises an NotImplementedError" # Expected NotImplementedError but no exception was raised (2025-04-18 04:54:15 -0000 was returned)
  fails "File::Stat#ftype returns 'characterSpecial' when the file is a char" # RuntimeError: Could not find a character device
  fails "File::Stat#ftype returns 'socket' when the file is a socket" # NameError: uninitialized constant FileSpecs::UNIXServer
end
