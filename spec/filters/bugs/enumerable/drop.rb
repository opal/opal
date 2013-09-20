opal_filter "Enumerable#drop" do
  fails "Enumerable#drop passed a number n as an argument raise ArgumentError if n < 0"
  fails "Enumerable#drop passed a number n as an argument tries to convert n to an Integer using #to_int"
  fails "Enumerable#drop passed a number n as an argument raises a TypeError when the passed n can be coerced to Integer"
end
