opal_filter "ruby_exe" do
  fails "The break statement in a lambda created at the toplevel returns a value when invoking from the toplevel"
  fails "The break statement in a lambda created at the toplevel returns a value when invoking from a method"
  fails "The break statement in a lambda created at the toplevel returns a value when invoking from a block"
end
