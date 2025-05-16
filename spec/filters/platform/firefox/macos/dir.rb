# NOTE: run bin/format-filters after changing this file
opal_filter "Dir" do
  fails "Dir#read returns all directory entries even when encoding conversion will fail" # Expected 0 == 1 to be truthy but was false
  fails "Dir.chroot as regular user calls #to_path on non-String argument" # Expected Errno::EPERM but no exception was raised (0 was returned)
  fails "Dir.chroot as regular user raises a SystemCallError if the directory doesn't exist" # Expected SystemCallError but no exception was raised (0 was returned)
  fails "Dir.chroot as regular user raises an Errno::EPERM exception if the directory exists" # Expected Errno::EPERM but no exception was raised (0 was returned)
  fails "Dir.delete raises an Errno::EACCES if lacking adequate permissions to remove the directory" # Expected Errno::EACCES but no exception was raised (0 was returned)
  fails "Dir.glob will follow symlinks when processing a `*/` pattern." # Expected [] == ["special/ln/nondotfile"] to be truthy but was false
  fails "Dir.glob will follow symlinks when testing directory after recursive directory in pattern" # Expected ["deeply/nondotfile", "subdir_one/nondotfile", "subdir_two/nondotfile"] == ["deeply/nondotfile",  "special/ln/nondotfile",  "subdir_one/nondotfile",  "subdir_two/nondotfile"] to be truthy but was false
  fails "Dir.mkdir raises a SystemCallError when lacking adequate permissions in the parent dir" # Expected SystemCallError but no exception was raised (0 was returned)
  fails "Dir.mktmpdir when passed a block creates the tmp-dir before yielding" # Expected false to be true
  fails "Dir.mktmpdir when passed no arguments creates a new writable directory in the path provided by Dir.tmpdir" # Expected false to be true
  fails "Dir.pwd correctly handles dirs with unicode characters in them" # Expected "/tmp/rubyspec_temp/あ" == "//tmp/rubyspec_temp/あ" to be truthy but was false
  fails "Dir.rmdir raises an Errno::EACCES if lacking adequate permissions to remove the directory" # Expected Errno::EACCES but no exception was raised (0 was returned)
  fails "Dir.tmpdir returns the path to a writable and readable directory" # Expected false to be true
  fails "Dir.unlink raises an Errno::EACCES if lacking adequate permissions to remove the directory" # Expected Errno::EACCES but no exception was raised (0 was returned)
end
