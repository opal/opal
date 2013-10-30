opal_filter "Mutable Strings" do
  fails "String#upcase! raises a RuntimeError when self is frozen"
  fails "String#upcase! returns nil if no modifications were made"
  fails "String#upcase! modifies self in place"
end
