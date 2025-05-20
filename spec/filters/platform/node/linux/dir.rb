# NOTE: run bin/format-filters after changing this file
opal_filter "Dir" do
  fails "Dir#read returns all directory entries even when encoding conversion will fail" # Expected 0 == 1 to be truthy but was false
  fails "Dir.chroot as regular user calls #to_path on non-String argument" # Expected Errno::EPERM but no exception was raised (0 was returned)
  fails "Dir.chroot as regular user raises a SystemCallError if the directory doesn't exist" # Expected SystemCallError but no exception was raised (0 was returned)
  fails "Dir.chroot as regular user raises an Errno::EPERM exception if the directory exists" # Expected Errno::EPERM but no exception was raised (0 was returned)
end
