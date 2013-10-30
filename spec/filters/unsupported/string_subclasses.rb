opal_filter "String subclasses" do
  fails "String#upcase returns a subclass instance for subclasses"
  fails "String#swapcase returns subclass instances when called on a subclass"
end
