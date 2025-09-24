# NOTE: run bin/format-filters after changing this file
opal_filter "language" do
  fails "The break statement in a lambda created at the toplevel returns a value when invoking from a block" # NotImplementedError: NotImplementedError
  fails "The break statement in a lambda created at the toplevel returns a value when invoking from the toplevel" # NotImplementedError: NotImplementedError
end
