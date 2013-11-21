opal_filter "String subclasses" do
  fails "String#upcase returns a subclass instance for subclasses"
  fails "String#swapcase returns subclass instances when called on a subclass"
  fails "String#downcase returns a subclass instance for subclasses"
  fails "String#capitalize returns subclass instances when called on a subclass"
  fails "String#center with length, padding returns subclass instances when called on subclasses"
  fails "String#chomp when passed no argument returns subclass instances when called on a subclass"
end
