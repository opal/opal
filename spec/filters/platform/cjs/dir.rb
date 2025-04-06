# NOTE: run bin/format-filters after changing this file
opal_filter "Dir" do
  fails "Dir#initialize calls #to_path on non-String arguments" # NotImplementedError: File.lstat is not available on this platform
  fails "Dir#inspect includes the class name" # NoMethodError: undefined method `close' for nil
  fails "Dir#inspect includes the directory name" # NoMethodError: undefined method `close' for nil
  fails "Dir#inspect returns a String" # NoMethodError: undefined method `close' for nil
  fails "Dir.[] ignores symlinks" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.[] matches multiple recursives" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob accepts a block and yields it with each elements" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob calls #to_path to convert multiple patterns" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob can take an array of patterns" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob handles **/ with base keyword argument" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob handles **/** with base keyword argument and FNM_DOTMATCH" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob handles **/** with base keyword argument" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob handles **/*pattern* with base keyword argument and FNM_DOTMATCH" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob handles **/.* with base keyword argument and FNM_DOTMATCH" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob handles **/.* with base keyword argument" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob handles **/.dotfile with base keyword argument and FNM_DOTMATCH" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob handles **/.dotfile with base keyword argument" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob handles **/glob with base keyword argument and FNM_EXTGLOB" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob handles **/nondotfile with base keyword argument and FNM_DOTMATCH" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob handles **/nondotfile with base keyword argument" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob handles infinite directory wildcards" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob handles simple directory patterns applied to non-directories" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob handles simple directory patterns" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob handles simple filename patterns" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob ignores non-dirs when traversing recursively" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob ignores symlinks" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob matches a list of paths by concatenating their individual results" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob matches any files in the current directory with '**' and option File::FNM_DOTMATCH" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob matches both dot and non-dotfiles with '*' and option File::FNM_DOTMATCH" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob matches files with any beginning with '*<non-special characters>' and option File::FNM_DOTMATCH" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob matches multiple recursives" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob matches nothing when given an empty list of paths" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob matches the literal character '\\' with option File::FNM_NOESCAPE" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob preserves multiple /s before a **" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob recursively matches any subdirectories except './' or '../' with '**/' and option File::FNM_DOTMATCH" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob recursively matches any subdirectories except './' or '../' with '**/' from the current directory and option File::FNM_DOTMATCH" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob recursively matches files and directories in nested dot subdirectory except . with 'nested/**/*' from the current directory and option File::FNM_DOTMATCH" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob returns matching file paths when supplied :base keyword argument" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob returns nil for directories current user has no permission to read" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob will follow symlinks when processing a `*/` pattern." # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob will follow symlinks when testing directory after recursive directory in pattern" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.glob will not follow symlinks when recursively traversing directories" # NotImplementedError: Dir.chdir is not available on this platform
  fails "Dir.home when called without arguments works even if HOME is unset" # Expected ".".start_with? "/" to be truthy but was false
  fails "Dir.mkdir raises a SystemCallError when lacking adequate permissions in the parent dir" # NotImplementedError: File.lstat is not available on this platform
  fails "Dir.pwd correctly handles dirs with unicode characters in them" # NotImplementedError: File.lstat is not available on this platform
end
