# NOTE: run bin/format-filters after changing this file
opal_filter "Etc" do
  fails "Etc.getgrnam only accepts strings as argument" # Expected TypeError but no exception was raised (nil was returned)
  fails "Etc.getgrnam returns a Etc::Group struct instance for the given group" # NoMethodError: undefined method `name' for nil
  fails "Etc.group raises a RuntimeError for parallel iteration" # Expected RuntimeError but got: Errno::ENOENT (No such file or directory)
  fails "Etc.group returns a Etc::Group struct" # Errno::ENOENT: No such file or directory
  fails "Etc.passwd returns a Etc::Passwd struct" # Errno::ENOENT: No such file or directory
end
