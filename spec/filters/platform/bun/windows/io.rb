# NOTE: run bin/format-filters after changing this file
opal_filter "IO" do
  fails "IO#initialize raises IOError on closed stream" # Errno::EPERM: Operation not permitted - EPERM: operation not permitted, open 'C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/io_initialize.txt'
  fails "IO#initialize raises a TypeError when passed a String" # Errno::EPERM: Operation not permitted - EPERM: operation not permitted, open 'C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/io_initialize.txt'
  fails "IO#initialize raises a TypeError when passed an IO" # Errno::EPERM: Operation not permitted - EPERM: operation not permitted, open 'C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/io_initialize.txt'
  fails "IO#initialize raises a TypeError when passed nil" # Errno::EPERM: Operation not permitted - EPERM: operation not permitted, open 'C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/io_initialize.txt'
  fails "IO#initialize reassociates the IO instance with the new descriptor when passed an Integer" # Errno::EPERM: Operation not permitted - EPERM: operation not permitted, open 'C:/Users/Administrator/workspace/opal/tmp/rubyspec_temp/io_initialize.txt'
  fails "IO#reopen with an IO always resets the close-on-exec flag to true on non-STDIO objects" # Errno::EACCES: Permission denied
  fails "IO#reopen with an IO associates the IO instance with the other IO's stream" # Errno::EACCES: Permission denied
  fails "IO#reopen with an IO does not change the object_id" # Errno::EACCES: Permission denied
  fails "IO#reopen with an IO may change the class of the instance" # Errno::EACCES: Permission denied
  fails "IO#reopen with an IO reads from the beginning if the other IO has not been read from" # Errno::EACCES: Permission denied
  fails "IO#reopen with an IO sets path equals to the other IO's path if other IO is File" # Errno::EACCES: Permission denied
  fails "IO.binwrite accepts a :flags option without :mode one" # Errno::EACCES: Permission denied
  fails "IO.binwrite accepts a :mode option" # Errno::EACCES: Permission denied
  fails "IO.binwrite coerces the argument to a string using to_s" # Errno::EACCES: Permission denied
  fails "IO.binwrite creates a file if missing" # Errno::EACCES: Permission denied
  fails "IO.binwrite creates file if missing even if offset given" # Errno::EACCES: Permission denied
  fails "IO.binwrite doesn't truncate and writes at the given offset after passing empty opts" # Errno::EACCES: Permission denied
  fails "IO.binwrite doesn't truncate the file and writes the given string if an offset is given" # Errno::EACCES: Permission denied
  fails "IO.binwrite raises an error if readonly mode is specified" # Errno::EACCES: Permission denied
  fails "IO.binwrite returns the number of bytes written" # Errno::EACCES: Permission denied
  fails "IO.binwrite truncates if empty :opts provided and offset skipped" # Errno::EACCES: Permission denied
  fails "IO.binwrite truncates the file and writes the given string" # Errno::EACCES: Permission denied
  fails "IO.write disregards other options if :open_args is given" # Expected "01hi" == "\u0000\u0000hi" to be truthy but was false
  fails "IO.write writes the file with the permissions in the :perm parameter" # Errno::EACCES: Permission denied
end
