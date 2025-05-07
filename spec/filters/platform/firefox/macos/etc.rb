# NOTE: run bin/format-filters after changing this file
opal_filter "Etc" do
  fails "Etc.getgrnam only accepts strings as argument" # Expected TypeError but no exception was raised (nil was returned)
  fails "Etc.group raises a RuntimeError for parallel iteration" # Expected RuntimeError but got: Errno::ENOENT (No such file or directory)
end
