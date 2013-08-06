opal_filter "Array#rindex" do
  fails "Array#rindex given no argument and no block produces an Enumerator"
  fails "Array#rindex rechecks the array size during iteration"
  fails "Array#rindex ignore the block if there is an argument"
  fails "Array#rindex returns the first index backwards from the end where element == to object"
end
