opal_filter "Array#flatten" do
  fails "Array#flatten raises a TypeError when the passed Object can't be converted to an Integer"
  fails "Array#flatten tries to convert passed Objects to Integers using #to_int"
end

opal_filter "Array#flatten!" do
  fails "Array#flatten! raises a TypeError when the passed Object can't be converted to an Integer"
  fails "Array#flatten! tries to convert passed Objects to Integers using #to_int"
end
