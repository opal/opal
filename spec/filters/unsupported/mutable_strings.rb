opal_filter "Mutable Strings" do
  fails "String#upcase! raises a RuntimeError when self is frozen"
  fails "String#upcase! returns nil if no modifications were made"
  fails "String#upcase! modifies self in place"
  fails "String#swapcase! modifies self in place"
  fails "String#swapcase! returns nil if no modifications were made"
  fails "String#swapcase! raises a RuntimeError when self is frozen"
  fails "String#reverse! raises a RuntimeError on a frozen instance that would not be modified"
  fails "String#reverse! raises a RuntimeError on a frozen instance that is modified"
  fails "String#reverse! reverses self in place and always returns self"
end
