# NOTE: run bin/format-filters after changing this file
opal_filter "Dir" do
  fails "Dir#pos= moves the read position to a previously obtained position" # Expected "nested" == ".dotfile" to be truthy but was false
  fails "Dir#rewind resets the next read to start from the first entry" # Expected "nested" == ".dotfile" to be truthy but was false
  fails "Dir#seek moves the read position to a previously obtained position" # Expected "nested" == ".dotfile" to be truthy but was false
  fails "Dir.[] :base option passed accepts both relative and absolute paths" # Expected [] == ["d", "y"] to be truthy but was false
  fails "Dir.[] :base option passed handles '' as current directory path" # Expected [] == ["a"] to be truthy but was false
  fails "Dir.[] :base option passed handles nil as current directory path" # Expected [] == ["a"] to be truthy but was false
  fails "Dir.[] :base option passed matches entries only from within the specified directory" # Expected [] == ["d", "y"] to be truthy but was false
  fails "Dir.[] matches paths with glob patterns" # Expected [] == ["special/test{1}/file[1]"] to be truthy but was false
  fails "Dir.chdir changes to the specified directory for the duration of the block" # Expected ["//tmp/rubyspec_temp/dir_specs_mock", "/tmp/rubyspec_temp/dir_specs_mock"] == ["//tmp/rubyspec_temp/dir_specs_mock", "//tmp/rubyspec_temp/dir_specs_mock"] to be truthy but was false
  fails "Dir.chdir changes to the specified directory" # Expected "/tmp/rubyspec_temp/dir_specs_mock" == "//tmp/rubyspec_temp/dir_specs_mock" to be truthy but was false
  fails "Dir.chdir defaults to $HOME with no arguments" # Errno::ENOENT: No such file or directory
  fails "Dir.chdir defaults to the home directory when given a block but no argument" # Errno::ENOENT: No such file or directory
  fails "Dir.delete raises an Errno::EACCES if lacking adequate permissions to remove the directory" # Expected Errno::EACCES but no exception was raised (0 was returned)
  fails "Dir.delete raises an Errno::ENOENT when trying to remove a non-existing directory" # Expected Errno::ENOENT but no exception was raised (0 was returned)
  fails "Dir.empty? returns false for a non-directory" # Errno::ENOENT: No such file or directory
  fails "Dir.empty? returns false for non-empty directories" # Errno::ENOENT: No such file or directory
  fails "Dir.exist? doesn't expand paths" # Expected false to be true
  fails "Dir.exist? returns false if the argument exists but is a file" # Expected File.exist? "ruby/core/dir/shared/exist.rb" to be truthy but was false
  fails "Dir.exist? returns true if the given directory exists" # Expected false to be true
  fails "Dir.exist? understands relative paths" # Expected false to be true
  fails "Dir.glob :base option passed accepts both relative and absolute paths" # Expected [] == ["d", "y"] to be truthy but was false
  fails "Dir.glob :base option passed handles '' as current directory path" # Expected [] == ["a"] to be truthy but was false
  fails "Dir.glob :base option passed handles nil as current directory path" # Expected [] == ["a"] to be truthy but was false
  fails "Dir.glob :base option passed matches entries only from within the specified directory" # Expected [] == ["d", "y"] to be truthy but was false
  fails "Dir.glob accepts a block and yields it with each elements" # Expected [] == ["file_one.ext", "file_two.ext"] to be truthy but was false
  fails "Dir.glob can take an array of patterns" # Expected [] == ["file_one.ext", "file_two.ext"] to be truthy but was false
  fails "Dir.glob handles **/** with base keyword argument and FNM_DOTMATCH" # Expected [] == [".",  ".dotfile.ext",  "directory",  "directory/structure",  "directory/structure/.ext",  "directory/structure/bar",  "directory/structure/baz",  "directory/structure/file_one",  "directory/structure/file_one.ext",  "directory/structure/foo"] to be truthy but was false
  fails "Dir.glob handles **/*pattern* with base keyword argument and FNM_DOTMATCH" # Expected [] == [".dotfile.ext",  "directory/structure/file_one",  "directory/structure/file_one.ext"] to be truthy but was false
  fails "Dir.glob handles **/.* with base keyword argument and FNM_DOTMATCH" # Expected [] == [".", ".dotfile.ext", "directory/structure/.ext"] to be truthy but was false
  fails "Dir.glob handles **/.dotfile with base keyword argument and FNM_DOTMATCH" # Expected [] == [".dotfile",  ".dotsubdir/.dotfile",  "deeply/.dotfile",  "nested/.dotsubir/.dotfile",  "subdir_one/.dotfile"] to be truthy but was false
  fails "Dir.glob handles **/nondotfile with base keyword argument and FNM_DOTMATCH" # Expected [] == [".dotsubdir/nondotfile",  "deeply/nondotfile",  "nested/.dotsubir/nondotfile",  "nondotfile",  "subdir_one/nondotfile",  "subdir_two/nondotfile"] to be truthy but was false
  fails "Dir.glob matches a list of paths by concatenating their individual results" # Expected [] == ["deeply/",  "deeply/nested/",  "deeply/nested/directory/",  "deeply/nested/directory/structure/",  "subdir_two/nondotfile",  "subdir_two/nondotfile.ext"] to be truthy but was false
  fails "Dir.glob matches paths with glob patterns" # Expected [] == ["special/test{1}/file[1]"] to be truthy but was false
  fails "Dir.glob recursively matches any subdirectories except './' or '../' with '**/' and option File::FNM_DOTMATCH" # Expected [] == ["./",  "./.dotsubdir/",  "./brace/",  "./deeply/",  "./deeply/nested/",  "./deeply/nested/directory/",  "./deeply/nested/directory/structure/",  "./dir/",  "./nested/",  "./nested/.dotsubir/",  "./special/",  "./special/test +()[]{}/",  "./special/test{1}/",  "./special/{}/",  "./subdir_one/",  "./subdir_two/"] to be truthy but was false
  fails "Dir.glob recursively matches files and directories in nested dot subdirectory except . with 'nested/**/*' from the current directory and option File::FNM_DOTMATCH" # Expected [] == ["nested/.",  "nested/.dotsubir",  "nested/.dotsubir/.dotfile",  "nested/.dotsubir/nondotfile"] to be truthy but was false
  fails "Dir.glob will follow symlinks when processing a `*/` pattern." # Expected [] == ["special/ln/nondotfile"] to be truthy but was false
  fails "Dir.glob will follow symlinks when testing directory after recursive directory in pattern" # Expected ["deeply/nondotfile", "subdir_one/nondotfile", "subdir_two/nondotfile"] == ["deeply/nondotfile",  "special/ln/nondotfile",  "subdir_one/nondotfile",  "subdir_two/nondotfile"] to be truthy but was false
  fails "Dir.mkdir creates the named directory with the given permissions" # Expected 0 == 0 to be falsy but was true
  fails "Dir.mkdir raises Errno::EEXIST if the specified directory already exists" # Expected Errno::EEXIST but no exception was raised (0 was returned)
  fails "Dir.mkdir raises a SystemCallError when lacking adequate permissions in the parent dir" # Expected SystemCallError but no exception was raised (0 was returned)
  fails "Dir.pwd correctly handles dirs with unicode characters in them" # Expected "/tmp/rubyspec_temp/あ" == "//tmp/rubyspec_temp/あ" to be truthy but was false
  fails "Dir.rmdir raises an Errno::EACCES if lacking adequate permissions to remove the directory" # Expected Errno::EACCES but no exception was raised (0 was returned)
  fails "Dir.rmdir raises an Errno::ENOENT when trying to remove a non-existing directory" # Expected Errno::ENOENT but no exception was raised (0 was returned)
  fails "Dir.unlink raises an Errno::EACCES if lacking adequate permissions to remove the directory" # Expected Errno::EACCES but no exception was raised (0 was returned)
  fails "Dir.unlink raises an Errno::ENOENT when trying to remove a non-existing directory" # Expected Errno::ENOENT but no exception was raised (0 was returned)
end
