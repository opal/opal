# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "File#chmod invokes to_int on non-integer argument" # NotImplementedError: File#chmod is not available on deno
  fails "File#chmod modifies the permission bits of the files specified" # NotImplementedError: File#chmod is not available on deno
  fails "File#chmod returns 0 if successful" # NotImplementedError: File#chmod is not available on deno
  fails "File#chmod with '0111' makes file executable but not readable or writable" # NotImplementedError: File#chmod is not available on deno
  fails "File#chmod with '0222' makes file writable but not readable or executable" # NotImplementedError: File#chmod is not available on deno
  fails "File#chmod with '0444' makes file readable but not writable or executable" # NotImplementedError: File#chmod is not available on deno
  fails "File#chmod with '0666' makes file readable and writable but not executable" # NotImplementedError: File#chmod is not available on deno
  fails "File#chown returns 0" # NotImplementedError: File#chown is not available on deno
  fails "File.expand_path returns a String in the same encoding as the argument" # FrozenError: can't modify frozen String
  fails "File.expand_path when HOME is not set raises an ArgumentError when passed '~' if HOME == ''" # Expected ArgumentError but no exception was raised ("/home/jan" was returned)
  fails "File.ftype returns fifo when the file is a fifo" # Expected "unknown" == "fifo" to be truthy but was false
  fails "File.mkfifo creates a FIFO file at the passed path" # Expected "unknown" == "fifo" to be truthy but was false
  fails "File.mkfifo when path passed responds to :to_path creates a FIFO file at the path specified" # Expected "unknown" == "fifo" to be truthy but was false
  fails "File.new returns a new File with modus num and permissions" # Expected "100755" == "100744" to be truthy but was false
  fails "File.open opens the file when passed mode, num and permissions" # Expected "100755" == "100744" to be truthy but was false
  fails "File.open raises an Errno::EACCES when opening non-permitted file" # NotImplementedError: File#chmod is not available on deno
  fails "File.open raises an Errno::EACCES when opening read-only file" # NotImplementedError: File#chmod is not available on deno
  fails "File.pipe? returns true if the file is a pipe" # Expected false == true to be truthy but was false
  fails "File.realpath removes the file element when going one level up" # Errno::ENOTDIR: Not a directory - Not a directory (os error 20): realpath '/home/jan/workspace/opal/tmp/rubyspec_temp/dir_realpath_real/file/../'
  fails "File::Stat#ftype returns fifo when the file is a fifo" # Expected "unknown" == "fifo" to be truthy but was false
  fails "File::Stat#pipe? returns true if the file is a pipe" # Errno::ENOENT: No such file or directory - No such file or directory /home/jan/workspace/opal/tmp/rubyspec_temp/i_am_a_pipe
end
