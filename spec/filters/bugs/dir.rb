# NOTE: run bin/format-filters after changing this file
opal_filter "Dir" do
  fails "Dir#read returns all directory entries even when encoding conversion will fail" # Expected 0 == 1 to be truthy but was false
  fails "Dir.[] raises an Encoding::CompatibilityError if the argument encoding is not compatible with US-ASCII" # Expected CompatibilityError but no exception was raised (["file_one.ext", "file_two.ext"] was returned)
  fails "Dir.chdir raises an Errno::ENOENT if the original directory no longer exists" # Expected File.exist? "C:/Users/jan/workspace/opal/tmp/rubyspec_temp/testdir1" to be falsy but was true
  fails "Dir.chroot as regular user calls #to_path on non-String argument" # Expected Errno::EPERM but got: NotImplementedError (chroot is not available on nodejs and compatible platforms)
  fails "Dir.chroot as regular user raises a SystemCallError if the directory doesn't exist" # Expected SystemCallError but got: NotImplementedError (chroot is not available on nodejs and compatible platforms)
  fails "Dir.chroot as regular user raises an Errno::EPERM exception if the directory exists" # Expected Errno::EPERM but got: NotImplementedError (chroot is not available on nodejs and compatible platforms)
  fails "Dir.delete raises an Errno::ENOTDIR when trying to remove a non-directory" # Expected Errno::ENOTDIR but got: Errno::ENOENT (No such file or directory - ENOENT: no such file or directory, rmdir 'C:\Users\jan\workspace\opal\tmp\rubyspec_temp\rmdir_dirs\nonempty\regular')
  fails "Dir.exist? doesn't require the name to have a trailing slash" # NotImplementedError: String#sub! not supported. Mutable String methods are currently not supported in Opal.
  fails "Dir.glob raises an Encoding::CompatibilityError if the argument encoding is not compatible with US-ASCII" # Expected CompatibilityError but no exception was raised ([] was returned)
  fails "Dir.home raises an ArgumentError if the named user doesn't exist" # Expected ArgumentError but no exception was raised ("/rubyspec_home" was returned)
  fails "Dir.home when called without arguments retrieves the directory from HOME, USERPROFILE, HOMEDRIVE/HOMEPATH and the WinAPI in that order" # Expected "C:/Users/jan" == "C:/rubyspec/home1" to be truthy but was false
  fails "Dir.mkdir creates the named directory with the given permissions" # Expected 16822 == 16822 to be falsy but was true
  fails "Dir.rmdir raises an Errno::ENOTDIR when trying to remove a non-directory" # Expected Errno::ENOTDIR but got: Errno::ENOENT (No such file or directory - ENOENT: no such file or directory, rmdir 'C:\Users\jan\workspace\opal\tmp\rubyspec_temp\rmdir_dirs\nonempty\regular')
  fails "Dir.unlink raises an Errno::ENOTDIR when trying to remove a non-directory" # Expected Errno::ENOTDIR but got: Errno::ENOENT (No such file or directory - ENOENT: no such file or directory, rmdir 'C:\Users\jan\workspace\opal\tmp\rubyspec_temp\rmdir_dirs\nonempty\regular')
end
