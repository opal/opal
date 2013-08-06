opal_filter "Array#*" do
  fails "Array#* with an integer with a subclass of Array returns a subclass instance"
  fails "Array#* with an integer raises an ArgumentError when passed a negative integer"
  fails "Array#* raises a TypeError is the passed argument is nil"
  fails "Array#* converts the passed argument to a String rather than an Integer"
  fails "Array#* raises a TypeError if the argument can neither be converted to a string nor an integer"
  fails "Array#* tires to convert the passed argument to an Integer using #to_int"
  fails "Array#* tries to convert the passed argument to a String using #to_str"
end
