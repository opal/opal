opal_filter "coerce integers" do
  fails "Array#at raises a TypeError when the passed argument can't be coerced to Integer"
  fails "Array#delete_at tries to convert the passed argument to an Integer using #to_int"
  fails "Array#fetch tries to convert the passed argument to an Integer using #to_int"
  fails "Array#fetch raises a TypeError when the passed argument can't be coerced to Integer"
  fails "Array#first tries to convert the passed argument to an Integer using #to_int"
  fails "Array#first raises a TypeError if the passed argument is not numeric"
  fails "Array#insert tries to convert the passed position argument to an Integer using #to_int"
end
