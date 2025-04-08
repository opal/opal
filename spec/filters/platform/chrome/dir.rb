# NOTE: run bin/format-filters after changing this file
opal_filter "Dir" do
  fails "Dir#initialize calls #to_path on non-String arguments" # Errno::ENOENT: No such file or directory
  fails "Dir#inspect includes the class name" # Errno::ENOENT: No such file or directory
  fails "Dir#inspect includes the directory name" # Errno::ENOENT: No such file or directory
  fails "Dir#inspect returns a String" # Errno::ENOENT: No such file or directory
  fails "Dir.[] ignores symlinks" # Errno::ENOENT: No such file or directory
  fails "Dir.[] matches multiple recursives" # Errno::ENOENT: No such file or directory
  fails "Dir.glob accepts a block and yields it with each elements" # Errno::ENOENT: No such file or directory
  fails "Dir.glob calls #to_path to convert multiple patterns" # Errno::ENOENT: No such file or directory
  fails "Dir.glob can take an array of patterns" # Errno::ENOENT: No such file or directory
  fails "Dir.glob handles **/ with base keyword argument" # Errno::ENOENT: No such file or directory
  fails "Dir.glob handles **/** with base keyword argument and FNM_DOTMATCH" # Errno::ENOENT: No such file or directory
  fails "Dir.glob handles **/** with base keyword argument" # Errno::ENOENT: No such file or directory
  fails "Dir.glob handles **/*pattern* with base keyword argument and FNM_DOTMATCH" # Errno::ENOENT: No such file or directory
  fails "Dir.glob handles **/.* with base keyword argument and FNM_DOTMATCH" # Errno::ENOENT: No such file or directory
  fails "Dir.glob handles **/.* with base keyword argument" # Errno::ENOENT: No such file or directory
  fails "Dir.glob handles **/.dotfile with base keyword argument and FNM_DOTMATCH" # Errno::ENOENT: No such file or directory
  fails "Dir.glob handles **/.dotfile with base keyword argument" # Errno::ENOENT: No such file or directory
  fails "Dir.glob handles **/glob with base keyword argument and FNM_EXTGLOB" # Errno::ENOENT: No such file or directory
  fails "Dir.glob handles **/nondotfile with base keyword argument and FNM_DOTMATCH" # Errno::ENOENT: No such file or directory
  fails "Dir.glob handles **/nondotfile with base keyword argument" # Errno::ENOENT: No such file or directory
  fails "Dir.glob handles infinite directory wildcards" # Errno::ENOENT: No such file or directory
  fails "Dir.glob handles simple directory patterns applied to non-directories" # Errno::ENOENT: No such file or directory
  fails "Dir.glob handles simple directory patterns" # Errno::ENOENT: No such file or directory
  fails "Dir.glob handles simple filename patterns" # Errno::ENOENT: No such file or directory
  fails "Dir.glob ignores non-dirs when traversing recursively" # Errno::ENOENT: No such file or directory
  fails "Dir.glob ignores symlinks" # Errno::ENOENT: No such file or directory
  fails "Dir.glob matches a list of paths by concatenating their individual results" # Errno::ENOENT: No such file or directory
  fails "Dir.glob matches any files in the current directory with '**' and option File::FNM_DOTMATCH" # Errno::ENOENT: No such file or directory
  fails "Dir.glob matches both dot and non-dotfiles with '*' and option File::FNM_DOTMATCH" # Errno::ENOENT: No such file or directory
  fails "Dir.glob matches files with any beginning with '*<non-special characters>' and option File::FNM_DOTMATCH" # Errno::ENOENT: No such file or directory
  fails "Dir.glob matches multiple recursives" # Errno::ENOENT: No such file or directory
  fails "Dir.glob matches nothing when given an empty list of paths" # Errno::ENOENT: No such file or directory
  fails "Dir.glob matches the literal character '\\' with option File::FNM_NOESCAPE" # Errno::ENOENT: No such file or directory
  fails "Dir.glob preserves multiple /s before a **" # Errno::ENOENT: No such file or directory
  fails "Dir.glob recursively matches any subdirectories except './' or '../' with '**/' and option File::FNM_DOTMATCH" # Errno::ENOENT: No such file or directory
  fails "Dir.glob recursively matches any subdirectories except './' or '../' with '**/' from the current directory and option File::FNM_DOTMATCH" # Errno::ENOENT: No such file or directory
  fails "Dir.glob recursively matches files and directories in nested dot subdirectory except . with 'nested/**/*' from the current directory and option File::FNM_DOTMATCH" # Errno::ENOENT: No such file or directory
  fails "Dir.glob returns matching file paths when supplied :base keyword argument" # Errno::ENOENT: No such file or directory
  fails "Dir.glob returns nil for directories current user has no permission to read" # Errno::ENOENT: No such file or directory
  fails "Dir.glob will follow symlinks when processing a `*/` pattern." # Errno::ENOENT: No such file or directory
  fails "Dir.glob will follow symlinks when testing directory after recursive directory in pattern" # Errno::ENOENT: No such file or directory
  fails "Dir.glob will not follow symlinks when recursively traversing directories" # Errno::ENOENT: No such file or directory
  fails "Dir.mkdir raises a SystemCallError when lacking adequate permissions in the parent dir" # Errno::ENOTEMPTY: Directory not empty
  fails "Dir.pwd correctly handles dirs with unicode characters in them" # Errno::ENOENT: No such file or directory
end
