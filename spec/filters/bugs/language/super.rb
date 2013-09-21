opal_filter "super" do
  fails "The super keyword passes along modified rest args when they were originally empty"
  fails "The super keyword passes along modified rest args when they weren't originally empty"
  fails "The super keyword sees the included version of a module a method is alias from"
  fails "The super keyword can't be used with implicit arguments from a method defined with define_method"
  fails "The super keyword raises an error error when super method does not exist"
  fails "The super keyword calls the correct method when the method visibility is modified"
  fails "The super keyword searches class methods including modules"
  fails "The super keyword calls the method on the calling class"
  fails "The super keyword searches the full inheritence chain"
  fails "The super keyword calls the method on the calling class including modules"
  fails "The super keyword searches the full inheritence chain including modules"
  fails "The super keyword calls the correct method when the superclass argument list is different from the subclass"
end
