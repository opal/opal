# NOTE: run bin/format-filters after changing this file
opal_filter "Dir" do
  fails "Dir.delete raises an Errno::EACCES if lacking adequate permissions to remove the directory" # Expected Errno::EACCES but no exception was raised (0 was returned)
  fails "Dir.glob will follow symlinks when processing a `*/` pattern." # Expected [] == ["special/ln/nondotfile"] to be truthy but was false
  fails "Dir.glob will follow symlinks when testing directory after recursive directory in pattern" # Expected ["deeply/nondotfile", "subdir_one/nondotfile", "subdir_two/nondotfile"] == ["deeply/nondotfile",  "special/ln/nondotfile",  "subdir_one/nondotfile",  "subdir_two/nondotfile"] to be truthy but was false
  fails "Dir.mkdir raises a SystemCallError when lacking adequate permissions in the parent dir" # Expected SystemCallError but no exception was raised (0 was returned)
  fails "Dir.pwd correctly handles dirs with unicode characters in them" # Expected "/tmp/rubyspec_temp/あ" == "//tmp/rubyspec_temp/あ" to be truthy but was false
  fails "Dir.rmdir raises an Errno::EACCES if lacking adequate permissions to remove the directory" # Expected Errno::EACCES but no exception was raised (0 was returned)
  fails "Dir.unlink raises an Errno::EACCES if lacking adequate permissions to remove the directory" # Expected Errno::EACCES but no exception was raised (0 was returned)
end
