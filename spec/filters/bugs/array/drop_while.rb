opal_filter "Array#drop_while" do
  fails "Array#drop_while removes elements from the start of the array until the block returns false"
  fails "Array#drop_while removes elements from the start of the array until the block returns nil"
  fails "Array#drop_while removes elements from the start of the array while the block evaluates to true"
end
