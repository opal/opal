# NOTE: run bin/format-filters after changing this file
opal_filter "Dir" do
  fails "Dir.[] :base option passed returns [] if specified path does not exist" # Exception: ENOENT: no such file or directory, scandir '/home/jan/workspace/opal/tmp/rubyspec_temp/dir_glob_mock/fake-name'
  fails "Dir.[] :base option passed returns [] if specified path is a file" # Exception: ENOTDIR: not a directory, scandir '/home/jan/workspace/opal/tmp/rubyspec_temp/dir_glob_mock/a/b/x'
  fails "Dir.[] ignores matching through directories that doesn't exist" # Exception: ENOENT: no such file or directory, scandir 'deeply/notthere'
  fails "Dir.[] ignores symlinks" # Exception: ENOTDIR: not a directory, scandir 'a/x/b/y/b/z/e'
  fails "Dir.[] matches multiple recursives" # Exception: ENOTDIR: not a directory, scandir 'a/x/b/y/b/z/e'
  fails "Dir.[] recursively matches any nondot subdirectories with '**/'" # Exception: ENOTDIR: not a directory, scandir 'brace/a'
  fails "Dir.[] recursively matches any subdirectories except './' or '../' with '**/' from the base directory if that is specified" # Exception: ENOTDIR: not a directory, scandir 'deeply/nested/directory/structure/bar'
  fails "Dir.[] recursively matches directories with '**/<characters>'" # Exception: ENOTDIR: not a directory, scandir 'brace/a'
  fails "Dir.children raises a SystemCallError if called with a nonexistent directory" # Expected SystemCallError but got: Exception (ENOENT: no such file or directory, scandir '/home/jan/workspace/opal/tmp/rubyspec_temp/dir_specs_mock/nonexistent00')
  fails "Dir.each_child raises a SystemCallError if passed a nonexistent directory" # Expected SystemCallError but got: Exception (ENOENT: no such file or directory, scandir '/home/jan/workspace/opal/tmp/rubyspec_temp/dir_specs_mock/nonexistent00')
  fails "Dir.empty? raises ENOENT for nonexistent directories" # Expected Errno::ENOENT but got: Exception (ENOENT: no such file or directory, scandir '/home/jan/workspace/opal/tmp/rubyspec_temp/nonexistent')
  fails "Dir.empty? returns false for a non-directory" # Exception: ENOTDIR: not a directory, scandir 'ruby/core/dir/empty_spec.rb'
  fails "Dir.entries raises a SystemCallError if called with a nonexistent directory" # Expected SystemCallError but got: Exception (ENOENT: no such file or directory, scandir '/home/jan/workspace/opal/tmp/rubyspec_temp/dir_specs_mock/nonexistent00')
  fails "Dir.foreach raises a SystemCallError if passed a nonexistent directory" # Expected SystemCallError but got: Exception (ENOENT: no such file or directory, scandir '/home/jan/workspace/opal/tmp/rubyspec_temp/dir_specs_mock/nonexistent00')
  fails "Dir.glob :base option passed returns [] if specified path does not exist" # Exception: ENOENT: no such file or directory, scandir '/home/jan/workspace/opal/tmp/rubyspec_temp/dir_glob_mock/fake-name'
  fails "Dir.glob :base option passed returns [] if specified path is a file" # Exception: ENOTDIR: not a directory, scandir '/home/jan/workspace/opal/tmp/rubyspec_temp/dir_glob_mock/a/b/x'
  fails "Dir.glob handles **/ with base keyword argument" # Exception: ENOTDIR: not a directory, scandir 'deeply/nested/directory/structure/bar'
  fails "Dir.glob handles **/** with base keyword argument and FNM_DOTMATCH" # Exception: ENOTDIR: not a directory, scandir 'deeply/nested/.dotfile.ext'
  fails "Dir.glob handles **/** with base keyword argument" # Exception: ENOTDIR: not a directory, scandir 'dir/filename_ordering'
  fails "Dir.glob handles **/*pattern* with base keyword argument and FNM_DOTMATCH" # Exception: ENOTDIR: not a directory, scandir 'deeply/nested/.dotfile.ext'
  fails "Dir.glob handles **/.* with base keyword argument and FNM_DOTMATCH" # Exception: ENOTDIR: not a directory, scandir 'deeply/nested/.dotfile.ext'
  fails "Dir.glob handles **/.* with base keyword argument" # Exception: ENOTDIR: not a directory, scandir 'deeply/nested/directory/structure/bar'
  fails "Dir.glob handles **/.dotfile with base keyword argument and FNM_DOTMATCH" # Exception: ENOTDIR: not a directory, scandir '/home/jan/workspace/opal/tmp/rubyspec_temp/dir_specs_mock/.dotfile'
  fails "Dir.glob handles **/.dotfile with base keyword argument" # Exception: ENOTDIR: not a directory, scandir '/home/jan/workspace/opal/tmp/rubyspec_temp/dir_specs_mock/brace/a'
  fails "Dir.glob handles **/glob with base keyword argument and FNM_EXTGLOB" # Exception: ENOTDIR: not a directory, scandir 'deeply/nested/directory/structure/bar'
  fails "Dir.glob handles **/nondotfile with base keyword argument and FNM_DOTMATCH" # Exception: ENOTDIR: not a directory, scandir '/home/jan/workspace/opal/tmp/rubyspec_temp/dir_specs_mock/.dotfile'
  fails "Dir.glob handles **/nondotfile with base keyword argument" # Exception: ENOTDIR: not a directory, scandir '/home/jan/workspace/opal/tmp/rubyspec_temp/dir_specs_mock/brace/a'
  fails "Dir.glob handles infinite directory wildcards" # Exception: ENOTDIR: not a directory, scandir 'brace/a'
  fails "Dir.glob ignores matching through directories that doesn't exist" # Exception: ENOENT: no such file or directory, scandir 'deeply/notthere'
  fails "Dir.glob ignores non-dirs when traversing recursively" # Exception: ENOTDIR: not a directory, scandir 'spec'
  fails "Dir.glob ignores symlinks" # Exception: ENOTDIR: not a directory, scandir 'a/x/b/y/b/z/e'
  fails "Dir.glob matches a list of paths by concatenating their individual results" # Exception: ENOTDIR: not a directory, scandir 'deeply/nested/directory/structure/bar'
  fails "Dir.glob matches multiple recursives" # Exception: ENOTDIR: not a directory, scandir 'a/x/b/y/b/z/e'
  fails "Dir.glob preserves multiple /s before a **" # Exception: ENOTDIR: not a directory, scandir 'deeply//nested/directory/structure/bar'
  fails "Dir.glob recursively matches any nondot subdirectories with '**/'" # Exception: ENOTDIR: not a directory, scandir 'brace/a'
  fails "Dir.glob recursively matches any subdirectories except './' or '../' with '**/' and option File::FNM_DOTMATCH" # Exception: ENOTDIR: not a directory, scandir './.dotfile'
  fails "Dir.glob recursively matches any subdirectories except './' or '../' with '**/' from the base directory if that is specified" # Exception: ENOTDIR: not a directory, scandir 'deeply/nested/directory/structure/bar'
  fails "Dir.glob recursively matches any subdirectories except './' or '../' with '**/' from the current directory and option File::FNM_DOTMATCH" # Exception: ENOTDIR: not a directory, scandir '.dotfile'
  fails "Dir.glob recursively matches directories with '**/<characters>'" # Exception: ENOTDIR: not a directory, scandir 'brace/a'
  fails "Dir.glob recursively matches files and directories in nested dot subdirectory except . with 'nested/**/*' from the current directory and option File::FNM_DOTMATCH" # Exception: ENOTDIR: not a directory, scandir 'nested/.dotsubir/.dotfile'
  fails "Dir.glob returns matching file paths when supplied :base keyword argument" # Exception: ENOTDIR: not a directory, scandir '/home/jan/workspace/opal/tmp/rubyspec_temp/dir_glob_base/lib/bloop.rb'
  fails "Dir.glob returns nil for directories current user has no permission to read" # Exception: EACCES: permission denied, scandir 'no_permission'
  fails "Dir.glob will follow symlinks when testing directory after recursive directory in pattern" # Exception: ENOTDIR: not a directory, scandir 'brace/a'
  fails "Dir.glob will not follow symlinks when recursively traversing directories" # Exception: ENOTDIR: not a directory, scandir 'brace/a'
  fails "Dir.open raises a SystemCallError if the directory does not exist" # Expected SystemCallError but no exception was raised (#<Dir:/home/jan/workspace/opal/tmp/rubyspec_temp/dir_specs_mock/nonexistent00> was returned)
end
