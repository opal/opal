# NOTE: run bin/format-filters after changing this file
opal_filter "Container root" do
  fails "Dir.chroot as root calls #to_path on non-String argument" # Mock 'path' expected to receive to_path("any_args") exactly 1 times but received it 0 times
  fails "Dir.chroot as root can be escaped from with ../" # NotImplementedError: NotImplementedError
  fails "Dir.chroot as root can be used to change the process' root directory" # Expected to not get Exception but got: NotImplementedError (NotImplementedError)
  fails "Dir.chroot as root raises an Errno::ENOENT exception if the directory doesn't exist" # Expected Errno::ENOENT but got: NotImplementedError (NotImplementedError)
  fails "Dir.chroot as root returns 0 if successful" # NotImplementedError: NotImplementedError
  fails "File.lchown changes the group id of the file" # NotImplementedError: NotImplementedError
  fails "File.lchown changes the owner id of the file" # NotImplementedError: NotImplementedError
  fails "File.lchown does not modify the group id of the file if passed nil or -1" # NotImplementedError: NotImplementedError
  fails "File.lchown does not modify the owner id of the file if passed nil or -1" # NotImplementedError: NotImplementedError
  fails "File.lchown returns the number of files processed" # NotImplementedError: NotImplementedError
  fails "File.readable? when run by a superuser returns true unconditionally" # Expected false == true to be truthy but was false
  fails "File.readable_real? when run by a real superuser returns true unconditionally" # Expected false == true to be truthy but was false
  fails "File.writable? when run by a superuser returns true unconditionally" # Expected false == true to be truthy but was false
  fails "File.writable_real? when run by a real superuser returns true unconditionally" # Expected false == true to be truthy but was false
  fails "File::Stat#readable? when run by a superuser returns true unconditionally" # Expected false == true to be truthy but was false
  fails "File::Stat#readable_real? when run by a real superuser returns true unconditionally" # Expected false == true to be truthy but was false
  fails "File::Stat#writable? when run by a superuser returns true unconditionally" # Expected false == true to be truthy but was false
  fails "File::Stat#writable_real? when run by a real superuser returns true unconditionally" # Expected false == true to be truthy but was false
  fails "FileTest.readable? when run by a superuser returns true unconditionally" # Expected false == true to be truthy but was false
  fails "FileTest.readable_real? when run by a real superuser returns true unconditionally" # Expected false == true to be truthy but was false
  fails "FileTest.writable? when run by a superuser returns true unconditionally" # Expected false == true to be truthy but was false
  fails "FileTest.writable_real? when run by a real superuser returns true unconditionally" # Expected false == true to be truthy but was false
  fails "Process.groups= sets the list of gids of groups in the supplemental group access list" # Expected [0] == [] to be truthy but was false
  fails "Process.uid= if run by a superuser sets the real user id if preceded by Process.euid=id" # Expected exit status is 0 but actual is 1 for command ruby_exe("bundle exec opal -Rnode /root/workspace/opal/tmp/rubyspec_temp/rubyexe.rb") Output:
end
